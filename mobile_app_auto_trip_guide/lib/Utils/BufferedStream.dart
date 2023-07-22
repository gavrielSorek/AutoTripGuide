import 'dart:async';

class BufferedStream<T> {
  StreamController<T>? _streamController;
  List<T> _buffer = [];

  void add(T value) {
    if (_streamController?.hasListener ?? false) {
      _streamController?.add(value);
    } else {
      _buffer.add(value);
    }
  }

  Stream<T> get stream {
    if (_streamController == null) {
      _streamController = StreamController<T>(
        onListen: () {
          _buffer.forEach((element) => _streamController?.add(element));
          _buffer.clear();
        },
        onCancel: () {
          _streamController?.close();
          _streamController = null;
        },
      );
    }
    return _streamController!.stream;
  }

  void dispose() {
    _streamController?.close();
  }
}
