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
import 'package:herlink/services/api_services.dart';
import 'package:herlink/services/auth_storage.dart';
import 'package:herlink/models/user_model.dart';
import 'package:herlink/collaboration_inbox.dart';
import 'package:herlink/conversations_list.dart';
import 'package:herlink/models/product_model.dart';
import 'package:herlink/models/event_model.dart';
import 'package:herlink/view_event.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:herlink/payment_history.dart';
import 'package:herlink/view_product.dart';
import 'package:herlink/models/user_model.dart' as model_user; // Prefixing just in case of conflict if needed, but not required yet
import 'package:herlink/view_user.dart'; // Just in case missing in some contexts
import 'package:herlink/models/post_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 4; // Profile is now index 4
  User? _user;
  bool _isLoading = true;
  List<dynamic> _savedItems = [];
  List<Event> _hostedEvents = [];
  List<Event> _joinedEvents = [];
  List<Product> _userProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // 6 tabs including Saved
    _tabController.index = 0;
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final profileResponse = await ApiService.getMyProfile();
      final eventsResponse = await ApiService.getMyEvents();
      final savedResponse = await ApiService.getSavedItems();

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);
        _user = User.fromJson(profileData);
      }

      if (eventsResponse.statusCode == 200) {
        final eventsData = jsonDecode(eventsResponse.body);
        final List<dynamic> hosted = eventsData['hosted'] ?? [];
        final List<dynamic> joined = eventsData['joined'] ?? [];
        _hostedEvents = hosted.map((json) => Event.fromJson(json)).toList();
        _joinedEvents = joined.map((json) => Event.fromJson(json)).toList();
      }

      if (savedResponse.statusCode == 200) {
          _savedItems = jsonDecode(savedResponse.body);
      }

      if (_user != null) {
        final productsResponse = await ApiService.getProducts(sellerId: _user!.id);
        if (productsResponse.statusCode == 200) {
          final List<dynamic> productsData = jsonDecode(productsResponse.body);
          _userProducts = productsData.map((json) => Product.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())); break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MarketplacePage())); break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EventsPage())); break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CollaborationTab())); break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage())); break; } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.purple),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryPage()));
            },
            tooltip: "Payment History",
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
          children: [
            if (_isLoading)
              const LinearProgressIndicator(color: Colors.purple, backgroundColor: Colors.transparent),
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
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.purpleAccent,
                  backgroundImage: _user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty
                      ? NetworkImage(_user!.avatarUrl!)
                      : null,
                  child: (_user?.avatarUrl == null || _user!.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user?.fullName ?? "Loading...",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.role ?? _user?.businessName ?? "Entrepreneur",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.location ?? "Unknown Location",
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
              _buildStat("${_user?.followersCount ?? 0}", "Products"), 
              _buildStat("${_user?.ratingAvg ?? 0.0}", "Rating"),
              _buildStat("${_user?.followersCount ?? 0}", "Followers"),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfilePage(user: _user)),
                );
                if (result == true) {
                  _fetchProfile();
                }
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
    isScrollable: true,
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
    Tab(text: "Saved"),
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
    children: [
    _InfoField(label: "Bio", content: _user?.bio ?? "No bio available."),
    _InfoField(label: "Location", content: _user?.location ?? "N/A"),
    _InfoField(label: "Industry", content: _user?.industry ?? "N/A"),
    _InfoField(label: "Email", content: _user?.email ?? "N/A"),
    ],
    ),
    ),

    // Products Tab
    _userProducts.isEmpty
    ? const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Text("No products uploaded yet."),
      ))
    : GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: _userProducts.length,
        itemBuilder: (context, index) {
          final product = _userProducts[index];
          return _productCard(
            product.id,
            product.title,
            "${product.price} birr",
            product.avgRating,
            reviewCount: product.reviewCount,
            imageUrl: product.imageUrl,
            category: product.category,
            description: product.description,
          );
        },
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
    const _reviewItem(
    "Sarah Williams",
    "2 days ago",
    5,
    "Absolutely love the designs! Very clean and easy to use.",
    ),
    // ... more reviews
    ],
    ),
    ),

    // Collaboration Tab
    Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.handshake_outlined, size: 64, color: Colors.purple.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            "Manage your communications and requests here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConversationListPage()),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text("DMs", style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CollaborationInboxPage()),
                    );
                  },
                  icon: const Icon(Icons.inbox_outlined, size: 18),
                  label: const Text("Inbox", style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
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
          if (_hostedEvents.isEmpty)
             const Text("No hosted events", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ..._hostedEvents.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _eventListCard(
              event: e,
              isHost: true),
          )),
          const SizedBox(height: 24),
          const Text("Joined Events", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          if (_joinedEvents.isEmpty)
            const Text("No joined events", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ..._joinedEvents.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _eventListCard(
              event: e,
              isHost: false),
          )),
        ],
      ),
    ),

    // Saved Items Tab
     Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _savedItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("No saved items yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: _savedItems.length,
              itemBuilder: (context, index) {
                final item = _savedItems[index];
                final bool isProduct = item['entity_type'] == 'product';
                final String title = item['title'] ?? "Unknown Title";
                final String? imageUrl = item['image_url'];
                final String? detail = isProduct ? "ETB ${item['price']}" : (item['start_time'] != null ? DateFormat('MMM dd, yyyy').format(DateTime.parse(item['start_time'])) : "Event");

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    onTap: () {
                        if (isProduct) {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProductPage(
                                 name: title,
                                 id: item['entity_id'].toString(),
                                 price: item['price']?.toString() ?? "0",
                                 rating: (item['avg_rating'] as num?)?.toDouble() ?? 0.0,
                                 description: item['description'] ?? "No description",
                                 imageUrl: imageUrl, 
                                 category: "Market",
                                 sellerId: null,
                             )));
                        } else {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => ViewEventPage(
                                 title: title,
                                 category: "Event",
                                 date: item['start_time'] != null ? DateFormat('MMM dd, yyyy').format(DateTime.parse(item['start_time'])) : "TBA",
                                 location: "See details",
                                 organizer: "Organized via HerLink",
                                 description: item['description'] ?? "No description",
                                 bannerUrl: imageUrl,
                                 eventId: item['entity_id'].toString(),
                             )));
                        }
                    },
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
                      ),
                      child: imageUrl == null ? Icon(isProduct ? Icons.shopping_bag : Icons.event, color: Colors.purple[200]) : null,
                    ),
                    title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                        detail ?? "",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.purple, size: 20),
                      onPressed: () async {
                         await ApiService.unsaveItem(item['entity_type'], item['entity_id'].toString());
                         _fetchProfile();
                      },
                    ),
                  ),
                );
              },
            ),
    ),
    ],
    ),
    ),
    ],
    ),

    floatingActionButton: _tabController.index == 1
    ? FloatingActionButton(
    onPressed: () async {}, // ... existing add product logic
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
  Widget _eventListCard({required Event event, required bool isHost}) {
    final dateFormat = DateFormat('MMM dd');
    String dayMonth = dateFormat.format(event.startTime);
    List<String> dateParts = dayMonth.split(" ");
    String month = dateParts.length > 0 ? dateParts[0] : "";
    String day = dateParts.length > 1 ? dateParts[1] : "";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewEventPage(
              title: event.title,
              category: event.category,
              date: DateFormat('MMM dd, yyyy').format(event.startTime),
              location: event.locationDetails,
              organizer: event.organizerName ?? "HerLink Partner",
              description: event.description,
              bannerUrl: event.bannerUrl,
              eventId: event.id,
            ),
          ),
        );
      },
      child: Container(
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
              width: 60,
              decoration: BoxDecoration(
                color: isHost ? Colors.purple.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(day, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isHost ? Colors.purple : Colors.blue)),
                  Text(month.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isHost ? Colors.purple : Colors.blue)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                   const SizedBox(height: 4),
                   Row(
                     children: [
                       Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                       const SizedBox(width: 4),
                       Expanded(child: Text(event.locationDetails, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                     ],
                   ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  // ✅ Product card widget
  Widget _productCard(String id, String name, String price, double rating, {String? imageUrl, String? category, String? description, int reviewCount = 0}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ManageProductPage(
              id: id,
              name: name,
              price: price,
              rating: rating,
              reviewCount: reviewCount,
              description: description ?? "This is a detailed description of $name. It is a very high quality product.",
              imageUrl: imageUrl,
              category: category,
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
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
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

