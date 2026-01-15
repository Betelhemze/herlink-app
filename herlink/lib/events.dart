import 'package:flutter/material.dart';
import 'package:herlink/home.dart';
import 'package:herlink/marketplace.dart';
import 'package:herlink/collabrations.dart';
import 'package:herlink/profile.dart'; 
import 'package:herlink/manage_event.dart';
import 'package:herlink/view_event.dart';
import 'package:herlink/services/api_services.dart';
import 'package:herlink/models/event_model.dart';
import 'package:herlink/services/auth_storage.dart';
import 'package:herlink/login.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  int _selectedIndex = 2;
  List<Event> _events = [];
  bool _isLoading = true;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getEvents(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _events = data.map((json) => Event.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching events: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search events...",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _fetchEvents(),
              )
            : const Text("Events", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _fetchEvents();
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.purple))
        :RefreshIndicator(
          onRefresh: _fetchEvents,
          child: _events.isEmpty
            ? const Center(child: Text("No upcoming events found."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _events.length,
                itemBuilder: (context, index) => _buildEventCard(_events[index]),
              ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final token = await AuthStorage.getToken();
          if (token == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please login to create an event")),
              );
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            }
            return;
          }
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageEventPage()))
              .then((_) => _fetchEvents());
          }
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
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

  Widget _buildEventCard(Event event) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final String dateStr = dateFormat.format(event.startTime);
    
    // Assign color based on category
    Color accentColor;
    switch (event.category.toLowerCase()) {
      case 'workshop': accentColor = Colors.purple; break;
      case 'webinar': accentColor = Colors.blue; break;
      case 'networking': accentColor = Colors.orange; break;
      default: accentColor = Colors.teal;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewEventPage(
              title: event.title,
              category: event.category,
              date: dateStr,
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
            Stack(
              children: [
               Container(
               height: 150,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: event.bannerUrl != null && event.bannerUrl!.isNotEmpty
                  ? DecorationImage(image: NetworkImage(event.bannerUrl!), fit: BoxFit.cover)
                  : null,
              ),
                child: event.bannerUrl == null || event.bannerUrl!.isEmpty
                ? Center(child: Icon(Icons.event, size: 50, color: accentColor))
                : null,
            ),
             Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                    onTap: () async {
                         try {
                            await ApiService.saveItem("event", event.id); // Assuming event.id is string
                             if(context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved ${event.title} to wishlist!")));
                            }
                         } catch(e) {
                             debugPrint("Error saving event: $e");
                         }
                    },
                    child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite_border, size: 20, color: Colors.purple),
                    ),
                ),
            ),
           ],
        ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(event.category, style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        event.locationMode == 'Online' ? 'Virtual' : event.locationDetails, 
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
