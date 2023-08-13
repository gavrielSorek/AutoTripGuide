import 'dart:async';

class InternaMapEvents{
  static InternaMapEvents instance = InternaMapEvents._privateConstructor();
  // Private constructor
  InternaMapEvents._privateConstructor();

  StreamController<void> reloadPoisEvent = StreamController<void>.broadcast();
}