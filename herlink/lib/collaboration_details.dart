import 'package:flutter/material.dart';
import 'package:herlink/models/collaboration_model.dart';
import 'package:herlink/services/api_services.dart';
import 'dart:convert';

class CollaborationDetailsPage extends StatefulWidget {
  final String collaborationId;
  const CollaborationDetailsPage({super.key, required this.collaborationId});

  @override
  State<CollaborationDetailsPage> createState() => _CollaborationDetailsPageState();
}

class _CollaborationDetailsPageState extends State<CollaborationDetailsPage> {
  Collaboration? _collaboration;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getCollaborationById(widget.collaborationId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _collaboration = Collaboration.fromJson(data);
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching details: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCollaborationRequestDialog() {
    if (_collaboration == null || _collaboration!.initiatorId == null) return;
    
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Expression of Interest"),
        content: TextField(
          controller: messageController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Tell the initiator why you're interested in '${_collaboration!.title}'...",
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (messageController.text.isEmpty) return;
              final res = await ApiService.sendCollaborationRequest({
                "receiver_id": _collaboration!.initiatorId,
                "collaboration_id": _collaboration!.id,
                "message": messageController.text,
              });
              if (res.statusCode == 201) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Your interest has been sent to the initiator!")),
                  );
                }
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collaboration Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : _collaboration == null
              ? const Center(child: Text("Not found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _collaboration!.type,
                          style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _collaboration!.title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("${_collaboration!.viewCount} views", style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 16),
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(_collaboration!.createdAt.toString().split(' ')[0], style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Description",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _collaboration!.description,
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _showCollaborationRequestDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("I'm Interested", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
