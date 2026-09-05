import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../map/map_style.dart';

class AddPlaceController extends GetxController {
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  final categories = ['Coffee Shop', 'Restaurant', 'Library', 'Other'];
  final selectedCategory = 'Coffee Shop'.obs;

  GoogleMapController? mapController;
  final initialLocation =
      const LatLng(11.5564, 104.9282).obs; // Default Phnom Penh
  final selectedLocation = const LatLng(11.5564, 104.9282).obs;

  @override
  void onInit() {
    super.onInit();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final latLng = LatLng(position.latitude, position.longitude);
        initialLocation.value = latLng;
        selectedLocation.value = latLng;

        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16.0));
      } catch (e) {
        print("Could not get location: \$e");
      }
    }
  }

  void onMapCreated(GoogleMapController controller, bool isDarkMode) {
    mapController = controller;
    if (isDarkMode) {
      controller.setMapStyle(darkMapStyle);
    } else {
      controller.setMapStyle(null);
    }
  }

  void onCameraMove(CameraPosition position) {
    selectedLocation.value = position.target;
  }

  void onCategoryChanged(String? value) {
    if (value != null) {
      selectedCategory.value = value;
    }
  }

  void submit() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a place name');
      return;
    }

    // We now have the exact dragged location!
    final lat = selectedLocation.value.latitude;
    final lon = selectedLocation.value.longitude;

    // Pop the screen and return the result FIRST
    Get.back(result: {
      'name': nameController.text.trim(),
      'lat': lat,
      'lon': lon,
    });
    
    // Then show the snackbar so it doesn't intercept the Get.back() call
    Get.snackbar(
      'Success', 
      'Added ${nameController.text}!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.teal,
      colorText: Colors.white,
    );
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
