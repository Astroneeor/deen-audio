#!/usr/bin/env python3
"""Builds assets/quran/*.json from unmodified Tanzil downloads.

The Quran text and translation are copied byte-for-byte from the source
files; this script only re-wraps them as JSON. It never edits ayah text.

1. Download the three sources into an EMPTY directory (not this one):

   curl -L -o tanzil-uthmani-default.txt \
     "https://tanzil.net/pub/download/index.php?marks=true&sajdah=true&tatweel=true&quranType=uthmani&outType=txt-2&agree=true"
   curl -L -o tanzil-en-sahih.txt https://tanzil.net/trans/en.sahih
   curl -L -o tanzil-quran-data.xml \
     https://tanzil.net/res/text/metadata/quran-data.xml

   (The first URL is the tanzil.net/download form with its default options
   for the Uthmani text: pause marks, sajdah signs, tatweel below
   superscript alefs; no rub-el-hizb signs, no sequential tanweens.)

2. Run from the repo root:

   python3 -I tools/build_quran_assets.py <download-dir> assets/quran

Pass --allow-new-version to accept source files whose SHA-256 differs from
the pinned ones (Tanzil publishes corrections; review the diff first).
"""
import hashlib
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

TEXT_FILE = 'tanzil-uthmani-default.txt'
TRANS_FILE = 'tanzil-en-sahih.txt'
META_FILE = 'tanzil-quran-data.xml'

PINNED_SHA256 = {
    TEXT_FILE: '6933e133dd56db778c801bf738848454e43648105a151e8d84d86a7cae39ec5f',
    TRANS_FILE: 'a1778a1a56695d9b59ae910809ec46d9f4a55f05961de51cd56e6ebcf9040883',
}

SURAH_COUNT = 114
AYAH_COUNT = 6236


def fail(msg):
    sys.exit(f'ERROR: {msg}')


def read_verified(path, allow_new):
    data = path.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    pinned = PINNED_SHA256.get(path.name)
    if pinned and digest != pinned:
        msg = f'{path.name}: sha256 {digest} != pinned {pinned}'
        if not allow_new:
            fail(msg + ' (use --allow-new-version after reviewing)')
        print('WARNING: ' + msg)
    return data.decode('utf-8')


def parse_tanzil(raw):
    """Returns ({(surah, ayah): text}, copyright-notice lines)."""
    ayahs, notice = {}, []
    for line in raw.split('\n'):
        if line.startswith('#'):
            notice.append(line)
        elif line:
            surah, ayah, text = line.split('|', 2)
            key = (int(surah), int(ayah))
            if key in ayahs or not text.strip():
                fail(f'duplicate or empty ayah {key}')
            ayahs[key] = text
    return ayahs, notice


def group(ayahs, counts):
    """Checks completeness against [counts] and groups ayahs per surah."""
    if len(ayahs) != AYAH_COUNT:
        fail(f'expected {AYAH_COUNT} ayahs, found {len(ayahs)}')
    out = {}
    for surah, count in counts.items():
        out[surah] = [
            {'number': n, 'text': ayahs.get((surah, n)) or fail(f'missing {surah}:{n}')}
            for n in range(1, count + 1)
        ]
    return out


def dump(path, surahs):
    # One surah per line keeps diffs reviewable; text is written verbatim.
    lines = [json.dumps(s, ensure_ascii=False, separators=(',', ':')) for s in surahs]
    path.write_text('[\n' + ',\n'.join(lines) + '\n]\n', encoding='utf-8')


def main(argv):
    args = [a for a in argv if not a.startswith('--')]
    if len(args) != 2:
        fail('usage: build_quran_assets.py <download-dir> <assets/quran dir>')
    src, dst = Path(args[0]), Path(args[1])
    allow_new = '--allow-new-version' in argv

    text, text_notice = parse_tanzil(read_verified(src / TEXT_FILE, allow_new))
    trans, trans_notice = parse_tanzil(read_verified(src / TRANS_FILE, allow_new))

    meta = ET.parse(src / META_FILE).getroot().findall('./suras/sura')
    if len(meta) != SURAH_COUNT:
        fail(f'expected {SURAH_COUNT} surahs in metadata, found {len(meta)}')
    counts = {int(m.get('index')): int(m.get('ayas')) for m in meta}
    if sorted(counts) != list(range(1, SURAH_COUNT + 1)):
        fail('surah numbers are not 1..114')
    if sum(counts.values()) != AYAH_COUNT:
        fail('metadata ayah counts do not sum to 6236')

    text_by_surah = group(text, counts)
    trans_by_surah = group(trans, counts)

    quran = [{
        'number': int(m.get('index')),
        'name': m.get('name'),
        'englishName': m.get('tname'),
        'englishNameTranslation': m.get('ename'),
        'numberOfAyahs': int(m.get('ayas')),
        'revelationType': m.get('type'),
        'ayahs': text_by_surah[int(m.get('index'))],
    } for m in meta]
    translation = [{'number': n, 'ayahs': trans_by_surah[n]} for n in sorted(counts)]

    dump(dst / 'quran_simple.json', quran)
    dump(dst / 'translation_en.json', translation)
    (dst / 'TANZIL_LICENSE.txt').write_text(
        'The files in this directory are derived, without any change to the\n'
        'text, from the Tanzil Project (https://tanzil.net).\n'
        'Surah metadata: Tanzil quran-data.xml, (C) 2008-2009 Tanzil.info, cc-by.\n'
        '\n== quran_simple.json ==\n' + '\n'.join(text_notice) + '\n'
        '\n== translation_en.json ==\n' + '\n'.join(trans_notice) + '\n',
        encoding='utf-8')
    print(f'Wrote {len(quran)} surahs / {len(text)} ayahs to {dst}')


if __name__ == '__main__':
    main(sys.argv[1:])
