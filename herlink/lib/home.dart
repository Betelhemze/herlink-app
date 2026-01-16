import 'package:flutter/material.dart';
import 'package:herlink/collabrations.dart';
import 'package:herlink/profile.dart';
import 'package:herlink/marketplace.dart';
import 'package:herlink/view_product.dart';
import 'package:herlink/notifications.dart';
import 'package:herlink/addproduct.dart'; // For Quick Action
import 'package:herlink/view_user.dart';
import 'package:herlink/events.dart';
import 'package:herlink/services/api_services.dart';
import 'package:herlink/services/auth_storage.dart';
import 'package:herlink/models/user_model.dart';
import 'package:herlink/login.dart';
import 'package:herlink/conversations_list.dart';
import 'package:herlink/models/product_model.dart';
import 'package:herlink/models/event_model.dart';
import 'package:herlink/models/collaboration_model.dart';
import 'package:herlink/models/post_model.dart';
import 'package:herlink/collaboration_details.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  User? _user;
  bool _isLoading = false;
  bool _isUsersLoading = false;
  bool _isProductsLoading = false;
  bool _isPostsLoading = false;
  List<Collaboration> _suggestedCollaborations = [];
  List<Product> _featuredProducts = [];
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchSuggestedUsers();
    _fetchFeaturedProducts();
    _fetchPosts();
  }

  Future<void> _fetchFeaturedProducts() async {
    if (!mounted) return;
    setState(() => _isProductsLoading = true);
    try {
      final response = await ApiService.getProducts();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            // Get first 10 products for featured
            _featuredProducts = data.take(10).map((json) => Product.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching featured products: $e");
    } finally {
      if (mounted) setState(() => _isProductsLoading = false);
    }
  }

  Future<void> _fetchSuggestedUsers() async {
    setState(() => _isUsersLoading = true);
    try {
      final response = await ApiService.getCollaborations();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _suggestedCollaborations = data.map((json) => Collaboration.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching collaborations: $e");
    } finally {
      if (mounted) setState(() => _isUsersLoading = false);
    }
  }

  Future<void> _fetchPosts() async {
    setState(() => _isPostsLoading = true);
    try {
      final response = await ApiService.getPosts();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _posts = data.map((json) => Post.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching posts: $e");
    } finally {
      if (mounted) setState(() => _isPostsLoading = false);
    }
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getMyProfile();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _user = User.fromJson(data);
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile on home: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to respective page
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MarketplacePage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EventsPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CollaborationTab()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'product launch':
        return Colors.blue;
      case 'collaboration request':
        return Colors.orange;
      case 'event':
        return Colors.purple;
      case 'update':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showCreatePostDialog() {
    final contentController = TextEditingController();
    String selectedType = "Update";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Create Post"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: "What's on your mind?",
                        hintText: "Share your thoughts...",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      items: ["Update", "Product Launch", "Collaboration Request", "Event"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedType = val!),
                      decoration: const InputDecoration(
                        labelText: "Post Type",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (contentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter some content")),
                      );
                      return;
                    }

                    try {
                      final response = await ApiService.createPost({
                        "content": contentController.text.trim(),
                        "type": selectedType,
                      });

                      debugPrint("Post creation response status: ${response.statusCode}");
                      debugPrint("Post creation response body: ${response.body}");

                      if (response.statusCode == 201) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Post created successfully!")),
                          );
                          _fetchPosts(); // Refresh the feed
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to create post: ${response.statusCode} - ${response.body}")),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint("Error creating post: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("An error occurred: $e")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Post"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCommentsDialog(String postId, int initialCommentsCount) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Comments"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: FutureBuilder(
                        future: ApiService.getPostComments(postId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Colors.purple));
                          }
                          
                          if (snapshot.hasError) {
                            return Center(child: Text("Error loading comments: ${snapshot.error}"));
                          }

                          if (snapshot.hasData) {
                            final response = snapshot.data!;
                            if (response.statusCode == 200) {
                              final List<dynamic> comments = jsonDecode(response.body);
                              
                              if (comments.isEmpty) {
                                return const Center(child: Text("No comments yet. Be the first!"));
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.purple,
                                      child: Text(
                                        (comment['full_name'] ?? 'U')[0].toUpperCase(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      comment['full_name'] ?? 'Unknown',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    subtitle: Text(comment['content'] ?? ''),
                                  );
                                },
                              );
                            }
                          }

                          return const Center(child: Text("Failed to load comments"));
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: "Add a comment",
                        hintText: "Write your comment...",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a comment")),
                      );
                      return;
                    }

                    try {
                      final response = await ApiService.addComment(
                        postId,
                        commentController.text.trim(),
                      );

                      if (response.statusCode == 201) {
                        commentController.clear();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Comment added!")),
                          );
                          Navigator.pop(context);
                          _fetchPosts(); // Refresh to update count
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to add comment")),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint("Error adding comment: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Comment"),
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
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purple, width: 2),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.purpleAccent,
                backgroundImage: _user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty
                    ? NetworkImage(_user!.avatarUrl!)
                    : null,
                child: (_user?.avatarUrl == null || _user!.avatarUrl!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome back,",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  _user?.fullName ?? "User Name",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.purple, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConversationListPage()),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Quick Action Bar
            const SizedBox(height: 16),
            _buildQuickActionBar(),


            // 2. Networking Feed
            _buildSectionHeader("Networking Feeds", "See all", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CollaborationTab()),
              );
            }),
            _isPostsLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: Colors.purple)),
                  )
                : _posts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            "No posts yet. Be the first to share!",
                            style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                        ),
                      )
                    : Column(
                        children: _posts.take(3).map((post) {
                          return _feedCard(
                            name: post.authorName,
                            role: "Entrepreneur",
                            industry: post.type,
                            time: _getTimeAgo(post.createdAt),
                            content: post.content,
                            contentType: post.type,
                            contentTypeColor: _getTypeColor(post.type),
                            hasImage: post.imageUrl != null,
                            imageUrl: post.imageUrl,
                            postId: post.id,
                            likesCount: post.likesCount,
                            commentsCount: post.commentsCount,
                            shareCount: post.shareCount,
                            authorId: post.authorId,
                          );
                        }).toList(),
                      ),

            // 3. Suggested Collaborations
            _buildSectionHeader("Suggested for You", "See all", () {
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CollaborationTab()),
              );
            }),
            SizedBox(
              height: 210,
              child: _isUsersLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                  : _suggestedCollaborations.isEmpty
                      ? Center(
                          child: Text(
                            "No collaboration opportunities available.",
                            style: TextStyle(color: Colors.grey[500], fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _suggestedCollaborations.length,
                          itemBuilder: (context, index) {
                            final collab = _suggestedCollaborations[index];
                            return _collabCard(
                              id: collab.id,
                              title: collab.title,
                              description: collab.description,
                              type: collab.type,
                              industry: collab.type, // Reusing type for industry if not available
                            );
                          },
                        ),
            ),

            // 4. Product Discovery
            _buildSectionHeader("Featured Products", "View Marketplace", () {
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MarketplacePage()),
              );
            }),
            SizedBox(
              height: 240,
              child: _isProductsLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                  : _featuredProducts.isEmpty
                      ? Center(
                          child: Text(
                            "No products available.",
                            style: TextStyle(color: Colors.grey[500], fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _featuredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _featuredProducts[index];
                            return _productCard(
                              product.title,
                              "${product.price} Birr",
                              product.avgRating,
                              product.sellerName ?? "HerLink Seller",
                              context,
                              id: product.id,
                              description: product.description,
                              imageUrl: product.imageUrl,
                            );
                          },
                        ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
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

  Widget _buildSectionHeader(String title, String actionText, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: [
                Text(actionText, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 16, color: Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _quickActionItem(Icons.post_add, "Create Post", Colors.blue, () {
            _showCreatePostDialog();
          }),
          _quickActionItem(Icons.add_business_outlined, "Add Product", Colors.orange, () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
              );
          }),
          _quickActionItem(Icons.handshake_outlined, "Start Collab", Colors.purple, () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CollaborationTab()),
              );
          }),
        ],
      ),
    );
  }

  Widget _quickActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _feedCard({
    required String name,
    required String role,
    required String industry,
    required String time,
    required String content,
    required String contentType,
    required Color contentTypeColor,
    required bool hasImage,
    String? imageUrl,
    required String postId,
    required int likesCount,
    required int commentsCount,
    required int shareCount,
    String? authorId,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(color: Colors.grey[800], fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "•  $industry",
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                 // Edit/Delete Menu (only if author)
                if (authorId != null && _user != null && authorId == _user!.id.toString())
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final contentController = TextEditingController(text: content);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Edit Post"),
                            content: TextField(
                              controller: contentController,
                              maxLines: 4,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                              ElevatedButton(onPressed: () async {
                                  try {
                                      await ApiService.editPost(postId, contentController.text, imageUrl); 
                                      if(context.mounted) {
                                          Navigator.pop(context);
                                          _fetchPosts();
                                      }
                                  } catch (e) {
                                      debugPrint("Error editing: $e");
                                  }
                              }, child: const Text("Save"))
                            ],
                          ),
                        );
                      } else if (value == 'delete') {
                        // Confirm deletion
                         showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Post"),
                            content: const Text("Are you sure you want to delete this post?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () async {
                                  try {
                                      await ApiService.deletePost(postId);
                                      if(context.mounted) {
                                          Navigator.pop(context);
                                          _fetchPosts();
                                      }
                                  } catch (e) {
                                      debugPrint("Error deleting: $e");
                                  }
                              }, child: const Text("Delete", style: TextStyle(color: Colors.white)))
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),

                if (authorId == null || _user == null || authorId != _user!.id.toString())
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                     const SizedBox(height: 4),
                     Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: contentTypeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.label_important, size: 10, color: contentTypeColor),
                          const SizedBox(width: 4),
                          Text(
                            contentType,
                            style: TextStyle(color: contentTypeColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),
            if (hasImage && imageUrl != null) ...[
              const SizedBox(height: 12),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                     image: NetworkImage(imageUrl),
                     fit: BoxFit.cover,
                  ),
                ),
                child: null,
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Smart Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                     InkWell(
                       onTap: () async {
                         try {
                           await ApiService.likePost(postId);
                           if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text("Post liked!")),
                             );
                             _fetchPosts(); // Refresh to update count
                           }
                         } catch (e) {
                           debugPrint("Error liking post: $e");
                         }
                       },
                       child: Row(
                         children: [
                           const Icon(Icons.favorite_border, size: 20, color: Colors.red),
                           const SizedBox(width: 6),
                           Text(
                             "$likesCount",
                             style: const TextStyle(
                               fontSize: 13,
                               fontWeight: FontWeight.bold,
                               color: Colors.black87,
                             ),
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(width: 24),
                     InkWell(
                       onTap: () {
                         _showCommentsDialog(postId, commentsCount);
                       },
                       child: Row(
                         children: [
                           const Icon(Icons.comment_outlined, size: 20, color: Colors.blue),
                           const SizedBox(width: 6),
                           Text(
                             "$commentsCount",
                             style: const TextStyle(
                               fontSize: 13,
                               fontWeight: FontWeight.bold,
                               color: Colors.black87,
                             ),
                           ),
                         ],
                       ),
                     ),
                  ],
                ),
                Row(
                  children: [
                     IconButton(
                       icon: const Icon(Icons.share_outlined, size: 20, color: Colors.grey),
                       onPressed: () async {
                         try {
                           await ApiService.sharePost(postId);
                           if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text("Post shared!")),
                             );
                             _fetchPosts(); // Refresh to update count
                           }
                         } catch (e) {
                           debugPrint("Error sharing post: $e");
                         }
                       },
                       tooltip: "Share ($shareCount)",
                     ),
                     IconButton(
                       icon: const Icon(Icons.person_add_alt, size: 20, color: Colors.purple),
                       onPressed: () {
                         if (authorId != null && authorId.isNotEmpty) {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (_) => ViewUserPage(
                                 id: authorId,
                                 name: name,
                                 business: "Entrepreneur",
                                 role: role,
                                 industry: industry,
                               ),
                             ),
                           );
                         }
                       },
                       tooltip: "View Profile",
                     ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, {bool isActive = false}) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, size: 20, color: isActive ? Colors.black87 : Colors.grey),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _collabCard({
    required String id,
    required String title,
    required String description,
    required String type,
    required String industry,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CollaborationDetailsPage(collaborationId: id),
          ),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.handshake_outlined, size: 18, color: Colors.purple[300]),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  industry,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Row(
                  children: [
                    Text(
                      "View Details",
                      style: TextStyle(color: Colors.purple[700], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: Colors.purple[700]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(String name, String price, double rating, String businessName, BuildContext context, {String? id, String? description, String? imageUrl}) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewProductPage(
                  id: id ?? "",
                  name: name,
                  price: price,
                  rating: rating,
                  description: description ?? "Experience the quality of our $name.",
                  sellerName: businessName,
                  imageUrl: imageUrl,
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: imageUrl != null && imageUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: imageUrl == null || imageUrl.isEmpty
                    ? const Center(child: Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey))
                    : Stack(
                        children: [
                             Positioned.fill(child: Image.network(imageUrl, fit: BoxFit.cover)),
                             Positioned(
                                 top: 8,
                                 right: 8,
                                 child: InkWell(
                                     onTap: () async {
                                         // Save item
                                         try {
                                             // Id is optional in signature but we need it. Assuming it's passed or available.
                                             if (id != null) {
                                                await ApiService.saveItem("product", id);
                                                if(context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved $name to wishlist!")));
                                                }
                                             }
                                         } catch(e) {
                                             debugPrint("Error saving: $e");
                                         }
                                     },
                                     child: Container(
                                         padding: const EdgeInsets.all(4),
                                         decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                         child: const Icon(Icons.favorite_border, size: 16, color: Colors.purple),
                                     ),
                                 )
                             )
                        ],
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    businessName,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.orange),
                          const SizedBox(width: 2),
                          Text(
                            rating.toString(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
