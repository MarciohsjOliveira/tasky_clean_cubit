import 'dart:async';
import 'package:flutter/foundation.dart';

class StreamRefreshListenable extends ChangeNotifier {
  StreamRefreshListenable(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
