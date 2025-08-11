import 'package:flutter_riverpod/flutter_riverpod.dart';

class BgNotifier extends StateNotifier<bool> {
  BgNotifier() : super(false); // default light mode

  void toggleTheme() {
    state = !state;
  }
}

final bgProvider = StateNotifierProvider<BgNotifier, bool>((ref) {
  return BgNotifier();
});
