import 'package:flutter/material.dart';
import 'package:herlink/view_product.dart';
import 'package:herlink/services/api_services.dart';
import 'package:herlink/message.dart';
import 'package:herlink/models/user_model.dart';
import 'package:herlink/models/product_model.dart';
import 'package:herlink/models/event_model.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ViewUserPage extends StatefulWidget {
  final String id;
  final String name;
  final String business;
  final String industry;
  final String role; // e.g. Entrepreneur, Business

  const ViewUserPage({
    super.key,
    required this.id,
    required this.name,
    required this.business,
    required this.industry,
    this.role = "Entrepreneur",
  });

  @override
  State<ViewUserPage> createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {
  User? _user;
  List<Product> _products = [];
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch User Profile
      final userRes = await ApiService.getUserById(widget.id);
      if (userRes.statusCode == 200) {
        _user = User.fromJson(jsonDecode(userRes.body));
      }

      // 2. Fetch User Products
      final productsRes = await ApiService.getProducts(sellerId: widget.id);
      if (productsRes.statusCode == 200) {
        final List<dynamic> pData = jsonDecode(productsRes.body);
        _products = pData.map((json) => Product.fromJson(json)).toList();
      }

      // 3. Fetch User Events
      final eventsRes = await ApiService.getUserEvents(widget.id);
      if (eventsRes.statusCode == 200) {
        final List<dynamic> eData = jsonDecode(eventsRes.body);
        _events = eData.map((json) => Event.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCollaborationRequestDialog(BuildContext context) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Connect with ${_user?.fullName ?? widget.name}"),
        content: TextField(
          controller: messageController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Enter your collaboration proposal...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (messageController.text.isEmpty) return;
              final res = await ApiService.sendCollaborationRequest({
                "receiver_id": widget.id,
                "message": messageController.text,
              });
              if (res.statusCode == 201) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Collaboration request sent!")),
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
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _user?.businessName ?? (widget.business.isNotEmpty ? widget.business : widget.name),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.purple))
        : SingleChildScrollView(
        child: Column(
          children: [
            // 1. Profile Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.purple,
                    backgroundImage: _user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty
                        ? NetworkImage(_user!.avatarUrl!)
                        : null,
                    child: (_user?.avatarUrl == null || _user!.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user?.businessName ?? (widget.business.isNotEmpty ? widget.business : widget.name),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      _buildBadge(_user?.role ?? widget.role, Colors.purple),
                      _buildBadge(_user?.industry ?? widget.industry, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("Addis Ababa, Ethiopia", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      const Text("4.8 (24)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MessagePage(
                                  recipientId: widget.id,
                                  recipientName: _user?.fullName ?? widget.name,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.purple),
                            foregroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Message", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showCollaborationRequestDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 0,
                          ),
                          child: const Text("Connect", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text("Save Profile"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. About Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    _user?.bio ?? "No biography available.",
                    style: TextStyle(height: 1.5, color: Colors.grey[800], fontSize: 14),
                  ),
                  if (_user?.lookFor != null && _user!.lookFor!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text("What we look for:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    ...(_user!.lookFor!.split(',').map((item) => _buildBulletPoint(item.trim()))),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Collaboration Interests
            if (_user?.interests != null && _user!.interests!.isNotEmpty)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Collaboration Interests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...(_user!.interests!.split(',').map((item) => _buildInterestChip(item.trim()))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
             // 4. Products View
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Products", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                         TextButton(
                          onPressed: () {
                            // Navigate to marketplace filtered by this seller
                          },
                          child: const Text("View Shop", style: TextStyle(color: Colors.purple)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: _products.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text("No products yet.", style: TextStyle(color: Colors.grey[500])),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return _buildProductCard(
                                context,
                                product.id,
                                product.title,
                                "${product.price} Birr",
                                product.description,
                                _user?.fullName ?? widget.name,
                                rating: product.avgRating,
                                imageUrl: product.imageUrl,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: 12),

            // 5. Reviews (Simple mock)
             Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildReviewItem("Helen K.", "Great partner to work with! Professional and timely.", 5),
                  const Divider(height: 24),
                  _buildReviewItem("Metasebia T.", "Wonderful workshop experience.", 5),
                   const SizedBox(height: 16),
                   Center(
                     child: TextButton(onPressed: (){}, child: const Text("View all reviews", style: TextStyle(color: Colors.purple))),
                   )
                ],
              ),
            ),

            const SizedBox(height: 12),
            // 6. Events Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text("Upcoming Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (_events.isEmpty)
                      Text("No upcoming events.", style: TextStyle(color: Colors.grey[500])),
                    ..._events.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildEventItem(e.title, DateFormat('MMM dd').format(e.startTime), e.locationMode),
                    )),
                 ],
               ),
             ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
        ],
      ),
    );
  }

 Widget _buildInterestChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, String productId, String name, String price, String description, String sellerName, {String? imageUrl, double rating = 0.0}) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewProductPage(
                id: productId,
                name: name,
                price: price,
                rating: rating,
                description: description,
                sellerName: sellerName,
                imageUrl: imageUrl, // Pass it to view page
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: imageUrl != null && imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? const Center(child: Icon(Icons.card_giftcard, color: Colors.grey))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(price, style: const TextStyle(fontSize: 12, color: Colors.purple)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String user, String comment, int stars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: List.generate(5, (index) => Icon(Icons.star, size: 14, color: index < stars ? Colors.orange : Colors.grey[300])),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(comment, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }

  Widget _buildEventItem(String title, String date, String mode) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
           const Icon(Icons.event, color: Colors.purple),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                 Text("$date • $mode", style: const TextStyle(color: Colors.grey, fontSize: 12)),
               ],
             ),
           ),
           const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
