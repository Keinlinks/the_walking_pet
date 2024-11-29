import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static String _socketUrl = 'https://the-walking-pet-api.onrender.com';
  static const String _socketUrlDebug = 'ws://10.0.2.2:3000';

  late IO.Socket socket;

  SocketService(){    
    // if (kDebugMode){
    //   _socketUrl = _socketUrlDebug;
    // }
    if (kDebugMode) {
      print(_socketUrl);
    }
    print(_socketUrl);
    socket = IO.io(_socketUrl,
      IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build()
    );
    socket.connect();
  }
}
