import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class LostPersonFormPage extends StatefulWidget {
  const LostPersonFormPage({super.key});

  @override
  State<LostPersonFormPage> createState() => _LostPersonFormPageState();
}

class _LostPersonFormPageState extends State<LostPersonFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _placeLostController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _selectedImage;
  bool _isSubmitting = false;

  final String apiUrl =
      "https://trinetraguard-backend-local.onrender.com/api/v1/lost-persons/";

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select an image")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = http.MultipartRequest("POST", Uri.parse(apiUrl));
      request.fields["name"] = _nameController.text;
      request.fields["aadhar_number"] = _aadharController.text;
      request.fields["contact_number"] = _contactController.text;
      request.fields["place_lost"] = _placeLostController.text;
      request.fields["permanent_address"] = _addressController.text;

      request.files.add(await http.MultipartFile.fromPath(
        "image",
        _selectedImage!.path,
      ));

      final response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lost person report submitted ✅")),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedImage = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Lost Person"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter full name" : null,
              ),
              const SizedBox(height: 12),

              // Aadhaar
              TextFormField(
                controller: _aadharController,
                decoration: const InputDecoration(
                  labelText: "Aadhar Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Please enter Aadhar number" : null,
              ),
              const SizedBox(height: 12),

              // Contact
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: "Contact Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? "Please enter contact number" : null,
              ),
              const SizedBox(height: 12),

              // Place Lost
              TextFormField(
                controller: _placeLostController,
                decoration: const InputDecoration(
                  labelText: "Place Lost",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter place lost" : null,
              ),
              const SizedBox(height: 12),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Permanent Address",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 2,
                validator: (value) =>
                    value!.isEmpty ? "Please enter permanent address" : null,
              ),
              const SizedBox(height: 12),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: _selectedImage == null
                      ? const Center(
                          child: Text("Tap to select image"),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.upload),
                  label: Text(
                    _isSubmitting ? "Submitting..." : "Submit Report",
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
