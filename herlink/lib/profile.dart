import 'package:flutter/material.dart';
import 'package:herlink/edit_profile.dart';
import 'package:herlink/collabrations.dart';
import 'package:herlink/home.dart';
import 'package:herlink/marketplace.dart';
import 'package:herlink/addproduct.dart';
import 'package:herlink/manage_product.dart';
import 'package:herlink/events.dart';
import 'package:herlink/notifications.dart';
import 'package:herlink/settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 4; // Profile is now index 4

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 5 tabs including Events
    _tabController.index = 0; // Default to About tab
    _tabController.addListener(() {
      setState(() {}); // Rebuild to remove/add FAB based on index
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()),
        ); break;
      case 1:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MarketplacePage()),
        ); break;
      case 2:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const EventsPage()),
        ); break;
      case 3:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const CollaborationTab()),
        ); break;
      case 4:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ProfilePage()),
        ); break; } }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
          children: [
      // Profile Header
      Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.purpleAccent,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "User Name",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "UI/UX Designer • Tech Enthusiast",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "San Francisco, CA",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("120", "Products"),
              _buildStat("4.8", "Rating"),
              _buildStat("1.2k", "Followers"),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Edit Profile",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),

    // Tabs
    Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    child: TabBar(
    controller: _tabController,
    labelColor: Colors.purple,
    unselectedLabelColor: Colors.grey,
    indicatorColor: Colors.transparent,
    indicator: BoxDecoration(
    color: Colors.purple.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    ),
    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
    padding: const EdgeInsets.all(4),
    tabs: const [
    Tab(text: "About"),
    Tab(text: "Product"),
    Tab(text: "Reviews"),
    Tab(text: "Collab"),
    Tab(text: "Events"),
    ],
    ),
    ),

    const SizedBox(height: 16),

    // Tab Views
    Expanded(
    child: TabBarView(
    controller: _tabController,
    children: [
    // About Tab
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ListView(
    padding: const EdgeInsets.only(bottom: 20),
    children: const [
    _InfoField(label: "Bio", content: "Passionate about creating intuitive and beautiful user interfaces."),
    _InfoField(label: "Location", content: "San Francisco, CA"),
    _InfoField(label: "Industry", content: "Technology"),
    _InfoField(label: "Email", content: "user@example.com"),
    _InfoField(label: "Website", content: "www.portfolio.com"),
    ],
    ),
    ),

    // Products Tab
    GridView.count(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 0.75,
    children: List.generate(6, (index) {
    return _productCard("Design Template ${index + 1}", "\$${(index + 1) * 25}", 4.5);
    }),
    ),

    // Reviews Tab
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ListView(
    padding: const EdgeInsets.only(bottom: 20),
    children: [
    // Header
    Container(
    padding: const EdgeInsets.all(16),
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
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: const [
    Text(
    "Total Reviews",
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    ),
    Text(
    "4.8",
    style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.purple,
    ),
    ),
    ],
    ),
    const SizedBox(height: 16),
    _ratingBar(5, 78),
    _ratingBar(4, 24),
    _ratingBar(3, 8),
    _ratingBar(2, 4),
    _ratingBar(1, 2),
    ],
    ),
    ),
    const SizedBox(height: 24),

    const Text(
    "Recent Reviews",
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    ),
    const SizedBox(height: 16),

    // Reviews list
    const _reviewItem(
    "Sarah Williams",
    "2 days ago",
    5,
    "Absolutely love the designs! Very clean and easy to use.",
    ),
    const _reviewItem(
    "Mike Johnson",
    "5 days ago",
    4,
    "Great product, but documentation could be improved.",
    ),
    const _reviewItem(
    "Emily Davis",
    "1 week ago",
    5,
    "Exceeded my expectations. Will buy again!",
    ),
    ],
    ),
    ),

    // Collaboration Tab
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.handshake_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No collaborations yet",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    ),

    // Events Tab
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          const Text("Hosted Events", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _eventListCard(title: "Tech Workshop", date: "Oct 12", location: "Virtual", isHost: true),
          const SizedBox(height: 24),
          const Text("Joined Events", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _eventListCard(title: "Marketing Summit", date: "Nov 05", location: "Addis Ababa", isHost: false),
        ],
      ),
    ),
    ],
    ),
    ),
    ],
    ),

    floatingActionButton: _tabController.index == 1
    ? FloatingActionButton(
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddProductPage()),
    );
    },
    backgroundColor: Colors.purple,
    child: const Icon(Icons.add, color: Colors.white),
    )
        : null,
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

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  // ✅ Events List Card Widget
  Widget _eventListCard({required String title, required String date, required String location, required bool isHost}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isHost ? Colors.purple.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(date.split(" ")[1], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isHost ? Colors.purple : Colors.blue)),
                Text(date.split(" ")[0], style: TextStyle(fontSize: 12, color: isHost ? Colors.purple : Colors.blue)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          if (isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text("Host", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // ✅ Product card widget
  Widget _productCard(String name, String price, double rating) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ManageProductPage(
              name: name,
              price: price,
              rating: rating,
              description: "This is a detailed description of $name. It is a very high quality product.",
            ),
          ),
        );
      },
      child: Container(
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
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  color: Colors.grey[100],
                  child: Center(
                    child: Icon(Icons.image_outlined, size: 50, color: Colors.grey[400]),
                  ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                  ),
                  const SizedBox(height: 4),
                  Text(price, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.orange[400]),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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

// ✅ Reusable info field widget
class _InfoField extends StatelessWidget {
  final String label;
  final String content;
  const _InfoField({required this.label, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Rating bar widget
Widget _ratingBar(int stars, int count) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text("$stars", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 4),
        const Icon(Icons.star, size: 14, color: Colors.orange),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / 100,
              backgroundColor: Colors.grey[100],
              color: Colors.orange,
              minHeight: 8,
            ),
          ),
        ),
      ],
    ),
  );
}

// ✅ Review item widget
class _reviewItem extends StatelessWidget {
  final String username;
  final String time;
  final int rating;
  final String text;

  const _reviewItem(this.username, this.time, this.rating, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purpleAccent,
                    ),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(rating.toString(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 13)),
        ],
      ),
    );
  }
}

