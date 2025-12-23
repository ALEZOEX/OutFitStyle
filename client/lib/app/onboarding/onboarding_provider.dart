import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di.dart';

final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final storage = ref.read(onboardingStorageProvider);
  return storage.isDone();
});