import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin Disposable on Closable {
  final List<StreamSubscription> _subscriptions = [];

  @override
  Future<void> close() async {
    for (final it in _subscriptions) {
      it.cancel();
    }
    _subscriptions.clear();

    super.close();
  }

  @protected
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }
}
