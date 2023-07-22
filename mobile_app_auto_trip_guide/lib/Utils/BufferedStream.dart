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

  void broadcast(T value) {
    if (_streamController == null || _streamController?.isClosed == true) {
      print("StreamController is not available");
      return;
    }

    if (!_streamController!.hasListener) {
      print("No listeners available");
      return;
    }

    _streamController!.add(value);
  }

  Stream<T> get stream {
    if (_streamController == null) {
      _streamController = StreamController<T>.broadcast(
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

  void clear() {
    _streamController?.close();
    _streamController = null;
    _buffer.clear();
  }
}
