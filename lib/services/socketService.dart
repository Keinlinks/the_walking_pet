import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:the_walking_pet/entities/User.dart';


class SocketService {
  static const String _socketUrl = 'ws://localhost:3000';

  late IO.Socket socket;

  SocketService(){
    socket = IO.io(_socketUrl);
    socket.connect();
  }

  void identify(User userData){
    socket.emit("identify", userData);
  }

  
  
}
