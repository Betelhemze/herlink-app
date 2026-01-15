import 'package:flutter/material.dart';
import 'package:herlink/home.dart';
import 'package:herlink/marketplace.dart';
import 'package:herlink/collabrations.dart'; // Using the same import as ProfilePage
import 'package:herlink/profile.dart';

import 'package:herlink/models/user_model.dart';
import 'package:herlink/services/api_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final User? user;
  const EditProfilePage({super.key, this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  late TextEditingController _industryController;
  late TextEditingController _bioController;
  late TextEditingController _businessNameController;
  late TextEditingController _roleController;
  late TextEditingController _interestsController;
  late TextEditingController _lookForController;

  String? _avatarUrl;
  bool _isSaving = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.fullName);
    _emailController = TextEditingController(text: widget.user?.email);
    _locationController = TextEditingController(text: widget.user?.location);
    _industryController = TextEditingController(text: widget.user?.industry);
    _bioController = TextEditingController(text: widget.user?.bio);
    _businessNameController = TextEditingController(text: widget.user?.businessName);
    _roleController = TextEditingController(text: widget.user?.role);
    _interestsController = TextEditingController(text: widget.user?.interests);
    _lookForController = TextEditingController(text: widget.user?.lookFor);
    _avatarUrl = widget.user?.avatarUrl;
  }

  int _selectedIndex = 3; // Profile tab is active

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _industryController.dispose();
    _bioController.dispose();
    _businessNameController.dispose();
    _roleController.dispose();
    _interestsController.dispose();
    _lookForController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final response = await ApiService.uploadImage(image.path);
        
        // Check if response is JSON
        if (response.body.trim().startsWith("<")) {
           if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Server error: ${response.statusCode}. Please try again later.")),
            );
          }
           debugPrint("Server returned HTML: ${response.body}");
           return;
        }

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          setState(() {
            _avatarUrl = data['imageUrl'];
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Image uploaded successfully!")),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(data['message'] ?? "Upload failed")),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error uploading image: $e")),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final response = await ApiService.updateProfile({
        "full_name": _usernameController.text.trim(),
        "business_name": _businessNameController.text.trim(),
        "role": _roleController.text.trim(),
        "location": _locationController.text.trim(),
        "industry": _industryController.text.trim(),
        "bio": _bioController.text.trim(),
        "interests": _interestsController.text.trim(),
        "look_for": _lookForController.text.trim(),
        "avatar_url": _avatarUrl,
      });

      if (response.statusCode == 200) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate reload needed
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update profile")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CollaborationTab()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Premium light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.purpleAccent,
                      backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                          ? (_isUploading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Icon(Icons.person, size: 50, color: Colors.white))
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploading ? null : _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: _isUploading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 32),

            // Form Fields
            _buildField(_usernameController, "Full Name", Icons.person_outline),
            const SizedBox(height: 16),
            _buildField(_emailController, "Email (Read Only)", Icons.email_outlined, enabled: false),
            const SizedBox(height: 16),
            _buildField(_businessNameController, "Business Name", Icons.business_outlined),
            const SizedBox(height: 16),
            _buildField(_roleController, "Professional Role / Job Title", Icons.badge_outlined),
            const SizedBox(height: 16),
            _buildField(_locationController, "Location", Icons.location_on_outlined),
            const SizedBox(height: 16),
            _buildField(_industryController, "Industry / Profession", Icons.work_outline),
            const SizedBox(height: 16),
             _buildField(_bioController, "Bio", Icons.description_outlined),
            const SizedBox(height: 16),
            _buildField(_interestsController, "Collaboration Interests (comma separated)", Icons.interests_outlined),
            const SizedBox(height: 16),
            _buildField(_lookForController, "What we look for (comma separated)", Icons.search_outlined),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: Colors.purple.withOpacity(0.4),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
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
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: "Marketplace"),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: "Collaborate"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool obscure = false, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.purple.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
