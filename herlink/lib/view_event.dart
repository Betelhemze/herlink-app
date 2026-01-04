import 'package:flutter/material.dart';

class ViewEventPage extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String location;
  final String organizer;

  const ViewEventPage({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.organizer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.purple,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                "https://via.placeholder.com/800x400",
                fit: BoxFit.cover,
              ),
            ),
            leading: IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_back, color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.share_outlined, color: Colors.black)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(category, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 16),
                  
                  // Organizer
                  Row(
                    children: [
                      const CircleAvatar(radius: 16, backgroundColor: Colors.purple, child: Icon(Icons.business, size: 16, color: Colors.white)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Organized by", style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Text(organizer, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date & Location
                  _buildIconText(Icons.calendar_today, date, "10:00 AM - 2:00 PM EST"),
                  const SizedBox(height: 16),
                  _buildIconText(Icons.location_on_outlined, location, "View on Map"),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(),
                  ),

                  // About
                  const Text("About Event", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                    "Join us for an inspiring session designed to help women entrepreneurs scale their businesses. We will cover funding strategies, digital marketing, and team building. Networking session included!",
                    style: TextStyle(color: Colors.grey, height: 1.6),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Speakers
                  const Text("Speakers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildSpeaker("Sarah J.", "Tech CEO"),
                      const SizedBox(width: 16),
                      _buildSpeaker("Dr. Amen", "Investor"),
                      const SizedBox(width: 16),
                      _buildSpeaker("Hanna B.", "Marketer"),
                    ],
                  ),
                  
                  const SizedBox(height: 100), // Space for FAB/Bottom Bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Success"),
                  content: const Text("You have successfully registered for this event!"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Register for Event", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.purple, size: 22),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeaker(String name, String role) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(role, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
