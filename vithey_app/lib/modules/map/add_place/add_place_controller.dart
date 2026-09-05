import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        final latLng = LatLng(position.latitude, position.longitude);
        initialLocation.value = latLng;
        selectedLocation.value = latLng;

        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16.0));
      } catch (_) {
        // Keep default Phnom Penh center.
      }
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
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

    final lat = selectedLocation.value.latitude;
    final lng = selectedLocation.value.longitude;

    Get.back(result: {
      'name': nameController.text.trim(),
      'lat': lat,
      'lng': lng,
      'lon': lng,
      'category': selectedCategory.value,
      'address': addressController.text.trim(),
    });

    Get.snackbar(
      'Success',
      'Added ${nameController.text}!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
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
