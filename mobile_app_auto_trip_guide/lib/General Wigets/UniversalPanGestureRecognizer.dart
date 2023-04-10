
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class UniversalPanGestureRecognizer extends OneSequenceGestureRecognizer {
  final void Function(DragUpdateDetails) onUpdate;

  UniversalPanGestureRecognizer({required this.onUpdate});

  @override
  void addPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      invokeCallback<void>('onUpdate', () => onUpdate(DragUpdateDetails(
        globalPosition: event.position,
        delta: event.delta,
        primaryDelta: null,
        sourceTimeStamp: event.timeStamp,
      )));
    }
    stopTrackingIfPointerNoLongerDown(event);
  }

  @override
  String get debugDescription => 'universalPan';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
