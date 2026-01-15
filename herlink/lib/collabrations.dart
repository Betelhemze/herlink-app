import 'package:flutter/material.dart';
import 'package:herlink/home.dart';
import 'package:herlink/marketplace.dart';
import 'package:herlink/profile.dart';
import 'package:herlink/events.dart';
import 'package:herlink/login.dart';
import 'package:herlink/services/api_services.dart';
import 'package:herlink/services/auth_storage.dart';
import 'package:herlink/models/collaboration_model.dart';
import 'package:herlink/collaboration_details.dart';
import 'dart:convert';

class CollaborationTab extends StatefulWidget {
  const CollaborationTab({super.key});

  @override
  State<CollaborationTab> createState() => _CollaborationTabState();
}

class _CollaborationTabState extends State<CollaborationTab> {
  int _selectedIndex = 3;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  List<Collaboration> _collaborations = [];
  String? _selectedCategory = "All";

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchCollaborations();
  }

  Future<void> _checkLoginStatus() async {
    final token = await AuthStorage.getToken();
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null;
      });
    }
  }

  Future<void> _fetchCollaborations() async {
    setState(() => _isLoading = true);
    try {
      final category = _selectedCategory == "All" ? null : _selectedCategory;
      final response = await ApiService.getCollaborations(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        category: category,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _collaborations = data.map((json) => Collaboration.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching collaborations: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCreateCollaborationDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String type = "Marketing";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Post Collaboration"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: "Description"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: type,
                      items: ["Marketing", "Partnership", "Events", "Tech"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => type = val!),
                      decoration: const InputDecoration(labelText: "Type"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty) return;
                    final res = await ApiService.createCollaboration({
                      "title": titleController.text,
                      "description": descriptionController.text,
                      "type": type,
                    });
                    if (res.statusCode == 201) {
                      _fetchCollaborations();
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text("Post"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search collaborations...",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _fetchCollaborations(),
              )
            : const Text(
                "HerLink",
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 1.2, // Branding style
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _fetchCollaborations();
                }
              });
            },
          ),
          if (!_isLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text("Login / Sign Up"),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2️⃣ Intro / Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                   Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.handshake_outlined, size: 48, color: Colors.purple),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Collaborate with Women Entrepreneurs",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Discover partnership opportunities, projects, and business growth ideas.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (_isLoggedIn) {
                        _showCreateCollaborationDialog();
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: Text(
                      _isLoggedIn ? "Post a Collaboration" : "Join HerLink to Collaborate",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5️⃣ How Collaboration Works (Moved up for better flow/context)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "How it works",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStepItem(Icons.person_add_outlined, "Create Profile"),
                      _buildStepItem(Icons.post_add, "Post/Browse"),
                      _buildStepItem(Icons.chat_bubble_outline, "Connect"),
                      _buildStepItem(Icons.trending_up, "Grow Together"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4️⃣ Categories / Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                   _buildFilterChip("All", _selectedCategory == "All"),
                  _buildFilterChip("Marketing", _selectedCategory == "Marketing"),
                  _buildFilterChip("Partnership", _selectedCategory == "Partnership"),
                  _buildFilterChip("Events", _selectedCategory == "Events"),
                  _buildFilterChip("Tech", _selectedCategory == "Tech"),
                ],
              ),
            ),

            const SizedBox(height: 24),

             // 3️⃣ Featured Collaboration Opportunities
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Featured Opportunities",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                     const Center(child: CircularProgressIndicator(color: Colors.purple))
                  else if (_collaborations.isEmpty)
                     const Center(child: Text("No opportunities found", style: TextStyle(color: Colors.grey)))
                  else
                    ..._collaborations
                        .map((c) => _buildOpportunityCard(
                          title: c.title,
                          business: "Community Post",
                          industry: c.type,
                          type: c.type,
                          description: c.description,
                          onTap: () {
                             if (_isLoggedIn) {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (_) => CollaborationDetailsPage(collaborationId: c.id),
                                 ),
                               ).then((_) => _fetchCollaborations()); // Refresh list to update view count
                             } else {
                               Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                             }
                          },
                        )),
                ],
              ),
            ),
             const SizedBox(height: 24),
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

  Widget _buildStepItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.purple, size: 24),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _selectedCategory = label;
            });
            _fetchCollaborations();
          }
        },
        selectedColor: Colors.purple,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildOpportunityCard({
    required String title,
    required String business,
    required String industry,
    required String type,
    required String description,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Type and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
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
                    style: const TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.green),
                      SizedBox(width: 4),
                      Text("Open", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(business, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
                    Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  industry,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Blurred Action Area hint
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
               border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
            ),
             child: Center(
               child: Text(
                 _isLoggedIn ? "Tap to view details" : "Login to view details",
                 style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
               ),
             ),
          ),
        ],
      ),
    ),
    );
  }
}
