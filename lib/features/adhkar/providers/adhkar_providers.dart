import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/adhkar_repository.dart';

/// Shared repository instance — stateless asset loader.
final adhkarRepositoryProvider = Provider<AdhkarRepository>((ref) {
  return AdhkarRepository();
});

/// Morning adhkar loaded from assets/adhkar/morning.json.
final morningAdhkarProvider = FutureProvider<List<Dhikr>>((ref) {
  return ref.watch(adhkarRepositoryProvider).loadMorning();
});

/// Evening adhkar loaded from assets/adhkar/evening.json.
final eveningAdhkarProvider = FutureProvider<List<Dhikr>>((ref) {
  return ref.watch(adhkarRepositoryProvider).loadEvening();
});
