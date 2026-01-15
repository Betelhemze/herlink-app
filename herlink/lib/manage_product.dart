import 'package:flutter/material.dart';
import 'package:herlink/services/api_services.dart';
import 'dart:convert';

class ManageProductPage extends StatefulWidget {
  final String id;
  final String name;
  final String price;
  final double rating;
  final int reviewCount;
  final String description;
  final String? imageUrl;
  final String? category;

  const ManageProductPage({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    this.reviewCount = 0,
    required this.description,
    this.imageUrl,
    this.category,
  });

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  bool _isEditing = false;
  bool _isProcessing = false;

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _priceController = TextEditingController(text: widget.price);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isProcessing = true);
    try {
      final response = await ApiService.updateProduct(widget.id, {
        "title": _nameController.text,
        "description": _descriptionController.text,
        "price": double.tryParse(_priceController.text) ?? 0.0,
        "category": widget.category, // You could add category selection here too
        "image_url": widget.imageUrl ?? "",
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product updated successfully!"), backgroundColor: Colors.green),
          );
          setState(() {
            _isEditing = false;
          });
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['message'] ?? "Failed to update product"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred."), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _deleteProduct() {
    // TODO: Implement delete logic
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isProcessing = true);
              try {
                final response = await ApiService.deleteProduct(widget.id);
                if (response.statusCode == 200) {
                  if (mounted) {
                    Navigator.pop(context, true); // Go back to profile with refresh signal
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Product deleted")),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to delete product"), backgroundColor: Colors.red),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("An error occurred."), backgroundColor: Colors.red),
                  );
                }
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? "Edit Product" : "Manage Product",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteProduct,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (Placeholder)
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[200],
              child: Stack(
                children: [
                   Center(
                    child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                        ? Image.network(widget.imageUrl!, fit: BoxFit.cover, width: double.infinity)
                        : Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  if (_isProcessing)
                    const Center(child: CircularProgressIndicator(color: Colors.purple)),
                ],
              ),
            ),
            
            Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isEditing ? _buildEditForm() : _buildViewDetails(),
                  
                  const SizedBox(height: 30),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isEditing ? _saveChanges : _toggleEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _isEditing ? "Save Changes" : "Edit Details",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.name, // In a real app, bind to current state if updated
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              widget.price,
              style: const TextStyle(fontSize: 20, color: Colors.purple, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 20),
            const SizedBox(width: 4),
            Text(
              widget.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              "(${widget.reviewCount} reviews)",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          "Description",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.description,
          style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _buildTextField(_nameController, "Product Name", Icons.label_outline),
        const SizedBox(height: 16),
        _buildTextField(_priceController, "Price", Icons.attach_money),
        const SizedBox(height: 16),
        _buildTextField(_descriptionController, "Description", Icons.description_outlined, maxLines: 4),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey) : Container(margin: const EdgeInsets.only(bottom: 60), child: Icon(icon, color: Colors.grey)), // Align icon to top for textarea
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
