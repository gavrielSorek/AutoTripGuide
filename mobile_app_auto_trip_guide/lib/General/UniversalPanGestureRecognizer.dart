import 'package:flutter/gestures.dart';

class UniversalPanGestureRecognizer extends OneSequenceGestureRecognizer {
  final void Function(DragUpdateDetails) onUpdate;
  final double dragStartThreshold;

  Offset? _startPosition;
  double _totalDistance = 0;

  UniversalPanGestureRecognizer({
    required this.onUpdate,
    this.dragStartThreshold = 200.0,
  });

  @override
  void addPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
    _startPosition = event.position;
    _totalDistance = 0;
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      if (_startPosition != null) {
        final distance = (_startPosition! - event.position).distance;
        _totalDistance += distance;
        if (_totalDistance >= dragStartThreshold) {
          invokeCallback<void>('onUpdate', () => onUpdate(DragUpdateDetails(
            globalPosition: event.position,
            delta: event.delta,
            primaryDelta: null,
            sourceTimeStamp: event.timeStamp,
          )));
          _startPosition = null;
        }
      }
    }
    stopTrackingIfPointerNoLongerDown(event);
  }

  @override
  String get debugDescription => 'universalPan';

  @override
  void didStopTrackingLastPointer(int pointer) {
    _startPosition = null;
    _totalDistance = 0;
  }
}
