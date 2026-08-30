import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'map_style.dart';

class PlaceSuggestion {
  final String displayName;
  final double lat;
  final double lon;
  PlaceSuggestion(
      {required this.displayName, required this.lat, required this.lon});
}

class MapController extends GetxController {
  final searchQuery = ''.obs;
  final searchResults = <PlaceSuggestion>[].obs;
  final isSearching = false.obs;
  final isLocationGranted = false.obs;
  final errorMessage = ''.obs;
  final markers = <Marker>{}.obs;
  final localPlaces = <PlaceSuggestion>[].obs;

  final textController = TextEditingController();
  GoogleMapController? mapController;
  Timer? _debounce;
  final _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      isLocationGranted.value = true;
      goToCurrentLocation();
    }
  }

  Future<void> goToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15.0, // zoom level
        ),
      );
    } catch (e) {
      print("Could not get current location: $e");
    }
  }

  @override
  void onClose() {
    textController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller, bool isDarkMode) {
    mapController = controller;
    if (isDarkMode) {
      controller.setMapStyle(darkMapStyle);
    } else {
      controller.setMapStyle(null);
    }

    if (isLocationGranted.value) {
      goToCurrentLocation();
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (value.trim().isEmpty) {
      searchResults.clear();
      errorMessage.value = ''; // also clear error
      return;
    }

    // Reduced from 500ms to 250ms for faster, smoother autocomplete
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      isSearching.value = true;
      errorMessage.value = '';
      try {
        final Map<String, dynamic> queryParams = {
          'q': value.trim(),
          'limit': 5,
        };

        // Bias search to the current map view center
        if (mapController != null) {
          final bounds = await mapController!.getVisibleRegion();
          final lat =
              (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
          final lon =
              (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
          // Format precisely to avoid exponential notation or excessive decimals
          queryParams['lat'] = lat.toStringAsFixed(6);
          queryParams['lon'] = lon.toStringAsFixed(6);
        }

        final response = await _dio.get(
          'https://photon.komoot.io/api/',
          queryParameters: queryParams,
          options: Options(
            headers: {
              'User-Agent': 'VitheyApp/1.0 (Mobile)',
            },
          ),
        );

        final List features = response.data['features'];
        final apiResults = features.map((feature) {
          final props = feature['properties'];
          final coords = feature['geometry']['coordinates'];

          // Build a highly detailed display name
          final name = props['name'] ?? '';
          final street = props['street'] ?? '';
          final district = props['district'] ?? '';
          final city = props['city'] ?? props['state'] ?? '';

          List<String> parts = [];
          if (name.toString().isNotEmpty) parts.add(name);
          if (street.toString().isNotEmpty) parts.add(street);
          if (district.toString().isNotEmpty) parts.add(district);
          if (city.toString().isNotEmpty) parts.add(city);

          final displayName =
              parts.isEmpty ? 'Unknown Location' : parts.join(', ');

          return PlaceSuggestion(
            displayName: displayName,
            lat: (coords[1] as num).toDouble(),
            lon: (coords[0] as num).toDouble(),
          );
        }).toList();

        final localMatches = localPlaces
            .where((p) => p.displayName
                .toLowerCase()
                .contains(value.trim().toLowerCase()))
            .toList();

        searchResults.value = [...localMatches, ...apiResults];
        errorMessage.value = ''; // clear error on success
      } catch (e) {
        if (e is DioException) {
          final errorData = e.response?.data;
          errorMessage.value =
              "API Error: ${e.response?.statusCode} - $errorData";
          print("Photon Search Error Data: $errorData");
        } else {
          errorMessage.value = e.toString();
        }
        print("Photon Search Error: $e");
        searchResults.clear();
      } finally {
        isSearching.value = false;
      }
    });
  }

  void onSuggestionSelected(PlaceSuggestion suggestion) {
    searchResults.clear();
    searchQuery.value = suggestion.displayName;
    textController.text = suggestion.displayName;
    FocusManager.instance.primaryFocus?.unfocus(); // dismiss keyboard

    final position = LatLng(suggestion.lat, suggestion.lon);

    // Drop a pin!
    markers.clear();
    markers.add(Marker(
      markerId: const MarkerId('selected_location'),
      position: position,
      infoWindow: InfoWindow(
        title: suggestion.displayName,
        snippet: 'Tap pin again to remove it',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      onTap: () {
        // Clear the search and remove the pin when tapped
        clearSearch();
        Get.snackbar(
          'Pin Removed',
          '${suggestion.displayName} was removed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.teal,
          colorText: Colors.white,
        );
      },
    ));
    markers.refresh(); // Force UI update

    // Smoothly animate closer to the pin (Zoom 17.0 is nicer)
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, 17.0),
    );
  }

  Future<void> onSearchSubmitted(String value) async {
    if (searchResults.isNotEmpty) {
      onSuggestionSelected(searchResults.first);
    }
  }

  void clearSearch() {
    textController.clear();
    searchQuery.value = '';
    searchResults.clear();
    errorMessage.value = '';
    markers.clear();
    markers.refresh(); // Force UI update to remove the pin
  }

  Future<void> openAddPlace() async {
    print("Opening Add Place Screen...");
    final result = await Get.toNamed(AppRoutes.addPlace);
    print("Returned from Add Place Screen! Result: $result");

    if (result != null && result is Map<String, dynamic>) {
      print("Valid result! Adding pin...");
      final newPlace = PlaceSuggestion(
        displayName: result['name'],
        lat: result['lat'],
        lon: result['lon'],
      );
      localPlaces.add(newPlace);
      onSuggestionSelected(newPlace);
    } else {
      print("Result was null or invalid type.");
    }
  }

  void goBack() {
    Get.back();
  }
}
