import 'dart:js_interop';

@JS('requestSerialPort')
external JSPromise requestSerialPort();

@JS('disconnectSerialJS')
external JSPromise disconnectSerialJS();

@JS('window.onSerialLineReceived')
external set onSerialLineReceived(JSFunction callback);

@JS('window.onSerialDisconnect')
external set onSerialDisconnect(JSFunction callback);

bool get isSerialSupported => true;

Future<bool> connectSerial(Function(String) onData, Function() onDisconnect) async {
  try {
    onSerialLineReceived = (JSString line) {
      onData(line.toDart);
    }.toJS;
    onSerialDisconnect = () {
      onDisconnect();
    }.toJS;
    
    final result = await requestSerialPort().toDart;
    return (result as JSBoolean).toDart;
  } catch (e) {
    print('Failed to request serial port: $e');
    return false;
  }
}

void disconnectSerial() {
  disconnectSerialJS();
}
