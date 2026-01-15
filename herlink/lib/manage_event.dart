import 'package:flutter/material.dart';
import 'package:herlink/services/api_services.dart';
import 'package:herlink/services/auth_storage.dart';
import 'package:herlink/login.dart';
import 'dart:convert';

class ManageEventPage extends StatefulWidget {
  const ManageEventPage({super.key});

  @override
  State<ManageEventPage> createState() => _ManageEventPageState();
}

class _ManageEventPageState extends State<ManageEventPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Workshop';
  bool _isOnline = true;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  bool _isPublishing = false;

  Future<void> _publishEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await AuthStorage.getToken();
    if (token == null) {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final DateTime startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      // For now, let's assume events last 2 hours
      final DateTime endDateTime = startDateTime.add(const Duration(hours: 2));

      final eventData = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "category": _selectedCategory,
        "start_time": startDateTime.toIso8601String(),
        "end_time": endDateTime.toIso8601String(),
        "location_mode": _isOnline ? "Online" : "Physical",
        "location_details": _locationController.text,
        "banner_url": "", // Placeholder for image upload
      };

      final response = await ApiService.createEvent(eventData);

      if (mounted) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Event Published Successfully!")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response.body}")),
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
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Event", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isPublishing 
          ? const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple))))
          : TextButton(
            onPressed: _publishEvent,
            child: const Text("Publish", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner placeholder
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Add Event Banner", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildLabel("Event Title"),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration("e.g. Women in Tech Summit"),
              ),
              const SizedBox(height: 20),

              _buildLabel("Category"),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ["Workshop", "Webinar", "Networking", "Product Launch"].map((e) => 
                  DropdownMenuItem(value: e, child: Text(e))
                ).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: _inputDecoration("Select Category"),
              ),
               const SizedBox(height: 20),

               Row(
                 children: [
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         _buildLabel("Date"),
                         InkWell(
                           onTap: () async {
                             final picked = await showDatePicker(
                               context: context, 
                               initialDate: _selectedDate, 
                               firstDate: DateTime.now(), 
                               lastDate: DateTime(2030),
                             );
                             if(picked != null) setState(() => _selectedDate = picked);
                           },
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                             decoration: BoxDecoration(
                               border: Border.all(color: Colors.grey[300]!),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Row(
                               children: [
                                 const Icon(Icons.calendar_today, size: 18, color: Colors.purple),
                                 const SizedBox(width: 8),
                                 Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                               ],
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(width: 16),
                    Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         _buildLabel("Time"),
                         InkWell(
                           onTap: () async {
                             final picked = await showTimePicker(
                               context: context,
                               initialTime: _selectedTime,
                             );
                             if(picked != null) setState(() => _selectedTime = picked);
                           },
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                             decoration: BoxDecoration(
                               border: Border.all(color: Colors.grey[300]!),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Row(
                               children: [
                                 const Icon(Icons.access_time, size: 18, color: Colors.purple),
                                 const SizedBox(width: 8),
                                 Text(_selectedTime.format(context)),
                               ],
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
              const SizedBox(height: 20),

              _buildLabel("Location Mode"),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text("Online"),
                    selected: _isOnline,
                    onSelected: (val) => setState(() => _isOnline = true),
                    selectedColor: Colors.purple.withOpacity(0.2),
                    labelStyle: TextStyle(color: _isOnline ? Colors.purple : Colors.black),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text("Physical"),
                    selected: !_isOnline,
                    onSelected: (val) => setState(() => _isOnline = false),
                    selectedColor: Colors.purple.withOpacity(0.2),
                    labelStyle: TextStyle(color: !_isOnline ? Colors.purple : Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if(_isOnline)
                TextFormField(
                  controller: _locationController,
                  decoration: _inputDecoration("Meeting Link (e.g. Zoom/Meet)"),
                )
              else
                TextFormField(
                  controller: _locationController,
                  decoration: _inputDecoration("Address / Venue Name"),
                ),

              const SizedBox(height: 20),
              
              _buildLabel("Description"),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration("What is this event about?"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.purple)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}
