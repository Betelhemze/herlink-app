import 'package:flutter/material.dart';
import 'package:herlink/message.dart';
import 'package:herlink/services/api_services.dart';
import 'package:herlink/models/message_model.dart';
import 'dart:convert';

class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key});

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getConversations();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _conversations = data.map((json) => Conversation.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching conversations: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Messages", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchConversations,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : _conversations.isEmpty
            ? const Center(child: Text("No messages yet."))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final conv = _conversations[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: conv.otherAvatar != null ? NetworkImage(conv.otherAvatar!) : null,
                      child: conv.otherAvatar == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(conv.otherName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(conv.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(
                      _formatTime(conv.createdAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MessagePage(
                            recipientId: conv.otherId,
                            recipientName: conv.otherName,
                            recipientAvatar: conv.otherAvatar,
                          ),
                        ),
                      ).then((_) => _fetchConversations());
                    },
                  );
                },
              ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day}/${date.month}";
  }
}
