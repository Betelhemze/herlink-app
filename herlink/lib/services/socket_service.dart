import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:herlink/config/api_config.dart';
import 'package:herlink/services/auth_storage.dart';
import 'package:flutter/foundation.dart';

class SocketService {
  static IO.Socket? _socket;
  static bool get isConnected => _socket?.connected ?? false;

  static void connect() async {
    final token = await AuthStorage.getToken();
    if (token == null) return;

    // Use baseUrl from ApiConfig (removing /api if present for socket connection usually, 
    // but here we just need the domain)
    String domain = ApiConfig.baseUrl.replaceAll("/api", ""); 
    
    // In dev, sometimes it's localhost:3000. 
    
    _socket = IO.io(domain, IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build());

    _socket!.connect();

    _socket!.onConnect((_) async {
       debugPrint('Socket Connected');
       final userId = await AuthStorage.getUserId();
       if (userId != null) {
           _socket!.emit('join_room', userId);
       }
    });

    _socket!.onDisconnect((_) => debugPrint('Socket Disconnected'));
    _socket!.onError((data) => debugPrint('Socket Error: $data'));
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  // Listen for incoming messages
  static void onMessageReceived(Function(dynamic) callback) {
    _socket?.on('receive_message', (data) {
        callback(data);
    });
  }

  // Optional: Emit message directly via socket (if backend supports it fully)
  // For now we use HTTP for persistence and Socket for notification, 
  // but if we used full socket chat:
  static void sendMessage(Map<String, dynamic> data) {
    _socket?.emit('send_message', data);
  }
}
