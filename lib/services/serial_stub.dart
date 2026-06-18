bool get isSerialSupported => false;

Future<bool> connectSerial(Function(String) onData, Function() onDisconnect) async {
  return false;
}

void disconnectSerial() {}
