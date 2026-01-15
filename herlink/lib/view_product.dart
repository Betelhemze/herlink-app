import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:herlink/home.dart';
import 'package:herlink/marketplace.dart';
import 'package:herlink/collab_inbox.dart';
import 'package:herlink/profile.dart';
import 'package:herlink/events.dart';
import 'package:herlink/message.dart';
import 'package:herlink/services/auth_storage.dart';
import 'package:herlink/services/api_services.dart';
import 'package:herlink/login.dart';
import 'package:herlink/collabrations.dart'; 
import 'package:herlink/models/review_model.dart';
import 'package:intl/intl.dart';

class ViewProductPage extends StatefulWidget {
  final String? id;
  final String name;
  final String price;
  final double rating;
  final String description;
  final String? imageUrl;
  final String? category;
  final String? sellerId;
  final String? sellerName;

  const ViewProductPage({
    super.key,
    this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.description,
    this.imageUrl,
    this.category,
    this.sellerId,
    this.sellerName,
  });

  @override
  State<ViewProductPage> createState() => _ViewProductPageState();
}

class _ViewProductPageState extends State<ViewProductPage> {
  int _selectedIndex = 1;
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _fetchReviews();
    }
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final response = await ApiService.getProductReviews(widget.id!);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _reviews = data.map((json) => Review.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MarketplacePage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EventsPage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CollaborationTab()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
  }

  void _showAddReviewDialog() {
    final commentController = TextEditingController();
    double selectedRating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Write a Review"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: "Your Experience",
                      hintText: "Share your thoughts about this product...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please write a comment")),
                      );
                      return;
                    }

                    try {
                      final response = await ApiService.addProductReview(
                        widget.id!,
                        {
                          "rating": selectedRating,
                          "comment": commentController.text.trim(),
                        },
                      );

                      if (response.statusCode == 201) {
                         if (context.mounted) {
                           Navigator.pop(context);
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text("Review submitted!")),
                           );
                           _fetchReviews();
                         }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text("Failed to submit review")),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint("Error submitting review: $e");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Product Image Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              color: Colors.grey[200],
              child: Hero(
                tag: widget.name,
                child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                    ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
          ),

          // 2. Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          // 3. Content Details Sheet
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.category ?? "General",
                                  style: const TextStyle(
                                    color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 18),
                                  const SizedBox(width: 4),
                                  // Use calculated average if available from review fetch, else widget param
                                  Text(
                                    (_reviews.isNotEmpty
                                            ? (_reviews.fold(0.0, (sum, r) => sum + r.rating) / _reviews.length).toStringAsFixed(1)
                                            : widget.rating.toString()),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    " (${_reviews.length} reviews)",
                                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.name,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.price,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.purple),
                          ),
                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 24),
                          const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            widget.description,
                            style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 30),
                          
                          // Seller Info
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.purple, // Use purple for consistency
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.sellerName ?? "Authentic Seller", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text("Verified Seller", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Divider(),
                          
                          // Reviews Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: _showAddReviewDialog,
                                child: const Text("Write a Review", style: TextStyle(color: Colors.purple)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _isLoadingReviews
                              ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                              : _reviews.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Text("No reviews yet.", style: TextStyle(color: Colors.grey[500])),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _reviews.length,
                                      separatorBuilder: (context, index) => const Divider(height: 32),
                                      itemBuilder: (context, index) {
                                        final review = _reviews[index];
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: Colors.grey[200],
                                                  backgroundImage: review.authorAvatar != null 
                                                    ? NetworkImage(review.authorAvatar!) 
                                                    : null,
                                                  child: review.authorAvatar == null 
                                                    ? Text(review.authorName[0].toUpperCase(), style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold))
                                                    : null,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(review.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                const Spacer(),
                                                Text(
                                                  DateFormat('MMM dd, yyyy').format(review.createdAt),
                                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: List.generate(5, (starIndex) {
                                                return Icon(
                                                  starIndex < review.rating ? Icons.star : Icons.star_border,
                                                  size: 14,
                                                  color: Colors.orange,
                                                );
                                              }),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(review.comment, style: TextStyle(color: Colors.grey[800])),
                                          ],
                                        );
                                      },
                                    ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Sticky Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                         if (widget.sellerId == null) return;
                          final token = await AuthStorage.getToken();
                          if (token == null) {
                            if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                            return;
                          }
                          if (mounted) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => MessagePage(recipientId: widget.sellerId!, recipientName: widget.sellerName ?? "Seller")));
                          }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Contact", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                         // ... Payment logic ...
                         // (Keeping payment logic minimal for brevity in this replacement, relying on previous impl if complex, 
                         // but I must include it to avoid breaking the button)
                         
                         // RE-IMPLEMENTING MOCK PAYMENT LOGIC to ensure it works
                        final token = await AuthStorage.getToken();
                        if (token == null) {
                          if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                          return;
                        }

                        final priceStr = widget.price.replaceAll(RegExp(r'[^0-9.]'), '');
                        final priceDouble = double.tryParse(priceStr) ?? 0.0;
                        final amount = priceDouble.round();

                         if (amount <= 0) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid price')));
                           return;
                         }

                         final referenceId = 'prd_${widget.id ?? 'unknown'}_${DateTime.now().millisecondsSinceEpoch}';

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Purchase'),
                            content: Text('Pay $amount birr to purchase "${widget.name}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Pay')),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.purple)));

                        try {
                           final initRes = await ApiService.initiatePayment(amount, referenceId, 'product_purchase');
                           if (!mounted) return;
                           Navigator.pop(context); // close progress

                           if (initRes.statusCode == 201) {
                             final data = jsonDecode(initRes.body);
                             final transactionId = data['transaction_id'];

                              final success = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Simulate Payment'),
                                  content: const Text('Simulate provider response for this mock purchase.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Fail')),
                                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Succeed')),
                                  ],
                                ),
                              );
                              
                              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.purple)));
                              final verifyRes = await ApiService.verifyPayment(transactionId, success == true);
                              if(!mounted) return;
                              Navigator.pop(context);

                              if (verifyRes.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Verification Failed')));
                              }

                           } else {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to initiate payment')));
                           }
                        } catch(e) {
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text("Purchase", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: "Market"),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined), activeIcon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: "Collab"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
