import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 tabs
    _tabController.index = 1; // Default to Products tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4E1), // light pink background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Avatar + Info
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          const Text(
            "User name",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text("Role", style: TextStyle(color: Colors.grey)),
          const Text("Short info", style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.purple,
            tabs: const [
              Tab(text: "About"),
              Tab(text: "Products"),
              Tab(text: "Review"),
              Tab(text: "Collaboration"),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // About Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: const [
                      _InfoField(label: "Description"),
                      _InfoField(label: "Location"),
                      _InfoField(label: "Industry Name"),
                      _InfoField(label: "Email"),
                    ],
                  ),
                ),

                // Products Tab
                GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  children: List.generate(6, (index) {
                    return _productCard("Product ${index + 1}", "50 birr", 3.2);
                  }),
                ),

                // Review Tab
                const Center(child: Text("Reviews will be shown here")),

                // Collaboration Tab
                const Center(
                  child: Text("Collaboration options will be shown here"),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile tab active
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: "Marketplace",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Collaborate",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // Product card widget
  static Widget _productCard(String name, String price, double rating) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image, size: 50)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(price, style: const TextStyle(color: Colors.green)),
                Row(
                  children: [
                    Text(
                      rating.toString(),
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable info field widget
class _InfoField extends StatelessWidget {
  final String label;
  const _InfoField({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(""),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
