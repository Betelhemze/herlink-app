import 'package:flutter/material.dart';
import 'package:herlink/services/api_services.dart';
import 'package:herlink/services/auth_storage.dart';
import 'package:herlink/services/socket_service.dart';
import 'package:herlink/models/message_model.dart';
import 'dart:convert';
import 'dart:async';

class MessagePage extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String? recipientAvatar;

  const MessagePage({
    super.key, 
    required this.recipientId, 
    required this.recipientName,
    this.recipientAvatar,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _connectSocket();
  }

  void _connectSocket() {
      // Ensure socket is connected
      if (!SocketService.isConnected) {
          SocketService.connect();
      }

      // Listen for new messages
      SocketService.onMessageReceived((data) {
          if (mounted) {
              // Check if message is for this chat
              // data: { receiverId, content, senderId, ... }
              if (data['senderId'].toString() == widget.recipientId.toString()) {
                  setState(() {
                       _messages.add(ChatMessage(
                           id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
                           senderId: data['senderId'].toString(),
                           receiverId: data['receiverId'].toString(),
                           content: data['content'],
                           createdAt: DateTime.now(),
                       ));
                  });
                  // Scroll to bottom?
              }
          }
      });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final response = await ApiService.getChat(widget.recipientId);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _messages = data.map((json) => ChatMessage.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching messages: $e");
    } finally {
      if (mounted && !silent) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;
    
    final content = _messageController.text;
    _messageController.clear();

    // Optimistic UI update
    final tempMsg = ChatMessage(
        id: "-1", 
        senderId: "me", // Placeholder, will be replaced by refresh or assumes layout handles 'me' check logic correctly if senderId != recipientId
        receiverId: widget.recipientId, 
        content: content, 
        createdAt: DateTime.now()
    );
    
    // We need to know 'my' ID for the layout logic (isMe check) typically. 
    // The current layout logic: isMe = msg.senderId != widget.recipientId;
    // So if I set senderId to anything other than recipientId, it shows as me.
    setState(() {
        _messages.add(tempMsg);
    });

    try {
      final response = await ApiService.sendMessage(widget.recipientId, content);
      if (response.statusCode == 201) {
        // Prepare socket data to send to receiver
        final myId = await AuthStorage.getUserId();
        if (myId != null) {
            SocketService.sendMessage({
                "receiverId": widget.recipientId,
                "content": content,
                "senderId": myId,
                "senderName": "User", // Ideally fetch name
            });
        }
      } else {
        // Revert on failure?
        if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send")));
        }
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.recipientAvatar != null ? NetworkImage(widget.recipientAvatar!) : null,
              child: widget.recipientAvatar == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Text(
              widget.recipientName,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.purple))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg.senderId != widget.recipientId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.purple : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          msg.content,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.purple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
