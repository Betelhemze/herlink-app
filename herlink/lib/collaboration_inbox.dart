import 'package:flutter/material.dart';
import 'package:herlink/models/collaboration_request_model.dart';
import 'package:herlink/services/api_services.dart';
import 'dart:convert';

class CollaborationInboxPage extends StatefulWidget {
  const CollaborationInboxPage({super.key});

  @override
  State<CollaborationInboxPage> createState() => _CollaborationInboxPageState();
}

class _CollaborationInboxPageState extends State<CollaborationInboxPage> {
  List<CollaborationRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInbox();
  }

  Future<void> _fetchInbox() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getCollaborationInbox();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _requests = data.map((json) => CollaborationRequest.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching inbox: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      final response = await ApiService.updateCollaborationRequestStatus(id, status);
      if (response.statusCode == 200) {
        _fetchInbox(); // Refresh
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Request $status")),
          );
        }
      }
    } catch (e) {
       debugPrint("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Collaboration Inbox", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInbox,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : _requests.isEmpty
            ? const Center(child: Text("No collaboration requests yet."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final req = _requests[index];
                  return _buildRequestCard(req);
                },
              ),
      ),
    );
  }

  Widget _buildRequestCard(CollaborationRequest req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.purple,
                  backgroundImage: req.senderAvatar != null ? NetworkImage(req.senderAvatar!) : null,
                  child: req.senderAvatar == null ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.senderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (req.collaborationTitle != null)
                        Text("Re: ${req.collaborationTitle}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                _buildStatusBadge(req.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              req.message,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            if (req.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(req.id, 'rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Reject"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(req.id, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Accept"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'accepted') color = Colors.green;
    if (status == 'rejected') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
