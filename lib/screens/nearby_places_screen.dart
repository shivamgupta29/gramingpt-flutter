import 'package:flutter/material.dart';
import '../services/api_service.dart'; // 1. Import the new ApiService

// A simple data model for a healthcare place.
class HealthPlace {
  final String name;
  final String vicinity; // address or locality

  HealthPlace({required this.name, required this.vicinity});

  // 2. Add a factory constructor to easily create a HealthPlace from the API's JSON response.
  factory HealthPlace.fromJson(Map<String, dynamic> json) {
    return HealthPlace(
      name: json['name'] ?? 'Unnamed Place',
      vicinity: json['vicinity'] ?? 'Address not available',
    );
  }
}

class NearbyPlacesScreen extends StatefulWidget {
  const NearbyPlacesScreen({super.key});

  @override
  State<NearbyPlacesScreen> createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  // State variables
  bool _isLoading = false;
  String _selectedCategory = ''; // To track which button is selected
  List<HealthPlace> _places = []; // The list of places to display

  // 3. UPDATED: This function now makes a real API call using the ApiService.
  Future<void> _fetchPlaces(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
      _places = [];
    });

    try {
      // Call the ApiService to get the real data from the backend.
      final List<dynamic> placesData = await ApiService.findNearbyPlaces(category);
      if (mounted) {
        setState(() {
          // Convert the raw data from the API into our HealthPlace model.
          _places = placesData.map((data) => HealthPlace.fromJson(data)).toList();
        });
      }
    } catch (e) {
      // If there's an error (no internet, server down), show a message.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('आस-पास के स्वास्थ्य केंद्र'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // The row of category buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton('hospital', 'अस्पताल', Icons.local_hospital),
                _buildCategoryButton('pharmacy', 'फार्मेसी', Icons.local_pharmacy),
                _buildCategoryButton('clinic', 'क्लिनिक', Icons.medical_services),
              ],
            ),
          ),
          const Divider(),
          // The results area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _places.isEmpty
                ? Center(
              child: Text(
                _selectedCategory.isEmpty
                    ? 'कृपया ऊपर एक श्रेणी चुनें।' // "Please select a category above."
                    : 'इस श्रेणी में कोई स्थान नहीं मिला।', // "No places found in this category."
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _places.length,
              itemBuilder: (context, index) {
                final place = _places[index];
                return ListTile(
                  leading: const Icon(Icons.place, color: Colors.green),
                  title: Text(place.name),
                  subtitle: Text(place.vicinity),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // A helper widget to build the category buttons
  Widget _buildCategoryButton(String category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return ElevatedButton.icon(
      onPressed: () => _fetchPlaces(category),
      icon: Icon(icon, color: isSelected ? Colors.white : Colors.green[700]),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green[600] : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.green[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
