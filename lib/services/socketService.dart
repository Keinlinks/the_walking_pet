import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:the_walking_pet/entities/User.dart';


class SocketService {
  static const String _socketUrl = 'http://10.0.2.2:3000';

  late IO.Socket socket;

  SocketService(){
    socket = IO.io(_socketUrl,
      IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build()
    );
    socket.connect();

    socket.onDisconnect((_){
        print("Disconnected");
      });
    socket.onError((data) => print("Error conectando: $data"));
  }

  void identify(String userData){
    socket.emit("identify", userData);
  }

  
  
}
