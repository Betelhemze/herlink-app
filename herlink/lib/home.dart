import 'package:flutter/material.dart';
import 'package:herlink/collabrations.dart';
import 'package:herlink/profile.dart';
import 'package:herlink/marketplace.dart';
import 'package:herlink/view_product.dart';
import 'package:herlink/notifications.dart';
import 'package:herlink/addproduct.dart'; // For Quick Action
import 'package:herlink/view_user.dart';
import 'package:herlink/events.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.purpleAccent,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Welcome back,",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "User Name",
                  style: TextStyle(
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
              icon: const Icon(Icons.notifications_outlined, color: Colors.black),
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
            _buildSectionHeader("Networking Feeds", "See all", () {}),
            _feedCard(
              name: "Sarah Jenkins",
              role: "Entrepreneur",
              industry: "Tech",
              time: "2h ago",
              content: "Excited to share that our new AI tool is finally live! 🚀 Check it out and let me know your thoughts.",
              contentType: "Product Launch",
              contentTypeColor: Colors.blue,
              hasImage: true,
            ),
            _feedCard(
              name: "Emily Chen",
              role: "Business Owner",
              industry: "Fashion",
              time: "5h ago",
              content: "Looking for a sustainable fabric supplier for our upcoming summer collection. Any recommendations?",
              contentType: "Collaboration Request",
              contentTypeColor: Colors.orange,
              hasImage: false,
            ),

            // 3. Suggested Collaborations
            _buildSectionHeader("Suggested for You", "See all", () {}),
            SizedBox(
              height: 210, // Adjusted height
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _collabCard(
                    name: "Anna Rivera",
                    business: "Rivera Designs",
                    type: "Product Partnership",
                    description: "Seeking textile artists for a joint collection.",
                    industry: "Design",
                  ),
                  _collabCard(
                    name: "TechStart Hub",
                    business: "TechStart",
                    type: "Event Co-Hosting",
                    description: "Looking for speakers for our Women in Tech summit.",
                    industry: "Education",
                  ),
                  _collabCard(
                    name: "GreenLife",
                    business: "Eco Store",
                    type: "Marketing",
                    description: "Cross-promotion opportunity for eco-friendly brands.",
                    industry: "Retail",
                  ),
                ],
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
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                   _productCard("Vintage Jacket", "1200 Birr", 4.8, "RetroStyle", context),
                   _productCard("Handmade Vase", "850 Birr", 4.5, "ClayWorks", context),
                   _productCard("Organic Soap", "250 Birr/set", 5.0, "PureNature", context),
                ],
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
          _quickActionItem(Icons.post_add, "Create Post", Colors.blue, () {}),
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
            if (hasImage) ...[
              const SizedBox(height: 12),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                     // Placeholder image
                     image: NetworkImage("https://via.placeholder.com/400x200"),
                     fit: BoxFit.cover,
                  ),
                ),
                // Fallback icon if image fails (though NetworkImage won't show in basic implementation without error handling)
                child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
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
                     _actionButton(Icons.favorite_border, "Like", isActive: true),
                     const SizedBox(width: 24),
                     _actionButton(Icons.comment_outlined, "Comment", isActive: true),
                  ],
                ),
                Row(
                  children: [
                     IconButton(
                       icon: const Icon(Icons.share_outlined, size: 20, color: Colors.grey),
                       onPressed: () {},
                       tooltip: "Share",
                     ),
                     IconButton(
                       icon: const Icon(Icons.person_add_alt, size: 20, color: Colors.grey),
                       onPressed: () {},
                       tooltip: "Connect",
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
    required String name,
    required String business,
    required String type,
    required String description,
    required String industry,
  }) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16, bottom: 8), // Bottom margin for shadow
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
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.purple,
                child: Icon(Icons.business, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      name,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(
               color: Colors.purple.withOpacity(0.05),
               borderRadius: BorderRadius.circular(6),
             ),
             child: Text(
               type,
               style: const TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold),
             ),
          ),
           const SizedBox(height: 8),
           Text(
            description,
            style: const TextStyle(fontSize: 13, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
           ),
           const Spacer(),
           SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (_) => ViewUserPage(
                       name: name,
                       business: business,
                       role: type,
                       industry: industry,
                     ),
                   ),
                 );
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.white,
                 foregroundColor: Colors.purple,
                 side: const BorderSide(color: Colors.purple),
                 elevation: 0,
                 padding: const EdgeInsets.symmetric(vertical: 0),
                 minimumSize: const Size(0, 32),
               ),
               child: const Text("View & Connect", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
             ),
           ),
        ],
      ),
    );
  }

  Widget _productCard(String name, String price, double rating, String businessName, BuildContext context) {
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
                  name: name,
                  price: price,
                  rating: rating,
                  description: "Experience the quality of our $name. Sourced from the best materials.",
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
                ),
                child: const Center(
                  child: Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey),
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
