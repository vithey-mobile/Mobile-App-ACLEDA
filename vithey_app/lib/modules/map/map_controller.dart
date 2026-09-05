import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'map_style.dart';

class PlaceSuggestion {
  final String displayName;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final String category; // e.g. cafe, restaurant, hotel, etc.
  PlaceSuggestion(
      {required this.displayName,
      required this.name,
      required this.address,
      required this.lat,
      required this.lon,
      this.category = ''});
}

class MapController extends GetxController {
  final searchQuery = ''.obs;
  final searchResults = <PlaceSuggestion>[].obs;
  final isSearching = false.obs;
  final isLocationGranted = false.obs;
  final errorMessage = ''.obs;
  final markers = <Marker>{}.obs;
  final localPlaces = <PlaceSuggestion>[].obs;

  // Filter state
  final filterCategory = 'Cafe'.obs;
  final filterRadius = 1000.0.obs; // Default 1km

  final textController = TextEditingController();
  GoogleMapController? mapController;
  Timer? _debounce;
  final _dio = Dio(
    BaseOptions(
      headers: {
        'User-Agent': 'VitheyApp/1.0 (Mobile; Android/iOS)',
        'Accept': 'application/json',
      },
    ),
  );

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
          'limit': 15,
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

          List<String> addrParts = [];
          if (street.toString().isNotEmpty) addrParts.add(street);
          if (district.toString().isNotEmpty) addrParts.add(district);
          if (city.toString().isNotEmpty) addrParts.add(city);
          final address =
              addrParts.isEmpty ? 'Unknown Address' : addrParts.join(', ');
          final finalName =
              name.toString().isNotEmpty ? name.toString() : 'Unknown Place';

          final category = props['osm_value'] ?? '';

          return PlaceSuggestion(
            displayName: displayName,
            name: finalName,
            address: address,
            lat: (coords[1] as num).toDouble(),
            lon: (coords[0] as num).toDouble(),
            category: category,
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

  Future<void> onSuggestionSelected(PlaceSuggestion suggestion) async {
    searchResults.clear();
    searchQuery.value = suggestion.displayName;
    textController.text = suggestion.displayName;
    FocusManager.instance.primaryFocus?.unfocus(); // dismiss keyboard

    final position = LatLng(suggestion.lat, suggestion.lon);
    final customIcon = await _createCustomMarkerIcon(suggestion.category);

    // Drop a pin!
    markers.clear();
    markers.add(Marker(
      markerId: const MarkerId('selected_location'),
      position: position,
      icon: customIcon,
      onTap: () {
        _showPlaceDetails(suggestion);
      },
    ));
    markers.refresh(); // Force UI update

    // Smoothly animate closer to the pin (Zoom 17.0 is nicer)
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, 17.0),
    );
  }

  Future<void> onSearchSubmitted(String value) async {
    if (searchResults.isEmpty) return;

    // Show ALL results on the map!
    markers.clear();
    FocusManager.instance.primaryFocus?.unfocus(); // dismiss keyboard

    double minLat = searchResults.first.lat;
    double maxLat = searchResults.first.lat;
    double minLon = searchResults.first.lon;
    double maxLon = searchResults.first.lon;

    for (var i = 0; i < searchResults.length; i++) {
      final place = searchResults[i];
      final position = LatLng(place.lat, place.lon);

      // Update bounding box
      if (place.lat < minLat) minLat = place.lat;
      if (place.lat > maxLat) maxLat = place.lat;
      if (place.lon < minLon) minLon = place.lon;
      if (place.lon > maxLon) maxLon = place.lon;

      final customIcon = await _createCustomMarkerIcon(place.category);

      markers.add(Marker(
        markerId: MarkerId('search_result_$i'),
        position: position,
        icon: customIcon,
        onTap: () {
          _showPlaceDetails(place);
        },
      ));
    }

    markers.refresh(); // Force UI update

    // Hide the dropdown list since we are showing pins on the map
    final currentResults = List<PlaceSuggestion>.from(searchResults);
    searchResults.clear();
    searchQuery.value = value;
    textController.text = value;

    // Smoothly animate camera to fit all the pins on the screen!
    if (currentResults.length == 1) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(minLat, minLon), 17.0),
      );
    } else {
      // Ensure min and max bounds are not identical to prevent exceptions in Google Maps SDK
      if ((maxLat - minLat).abs() < 0.002) {
        minLat -= 0.002;
        maxLat += 0.002;
      }
      if ((maxLon - minLon).abs() < 0.002) {
        minLon -= 0.002;
        maxLon += 0.002;
      }

      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLon),
            northeast: LatLng(maxLat, maxLon),
          ),
          80.0, // padding in pixels
        ),
      );
    }
  }

  Future<BitmapDescriptor> _createCustomMarkerIcon(String category) async {
    IconData iconData;
    Color color;

    switch (category.toLowerCase()) {
      case 'cafe':
      case 'coffee':
      case 'tea':
        iconData = Icons.local_cafe;
        color = Colors.orange;
        break;
      case 'restaurant':
      case 'fast_food':
      case 'food':
        iconData = Icons.restaurant;
        color = Colors.amber;
        break;
      case 'hotel':
      case 'motel':
      case 'guest_house':
        iconData = Icons.hotel;
        color = Colors.blue;
        break;
      case 'bank':
      case 'atm':
        iconData = Icons.local_atm;
        color = Colors.green;
        break;
      case 'hospital':
      case 'pharmacy':
      case 'clinic':
        iconData = Icons.local_hospital;
        color = Colors.pink;
        break;
      case 'supermarket':
      case 'convenience':
      case 'mall':
        iconData = Icons.shopping_cart;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.location_on;
        color = Colors.red;
        break;
    }

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 110.0;

    // Draw outer circle
    final Paint paint = Paint()..color = color;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

    // Draw white inner border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(
        const Offset(size / 2, size / 2), (size / 2) - 3, borderPaint);

    // Draw the icon
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size * 0.6,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
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
        name: result['name'],
        address: 'Custom Location',
        lat: result['lat'],
        lon: result['lon'],
        category: 'other',
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

  void _showPlaceDetails(PlaceSuggestion place) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image header
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                'https://loremflickr.com/600/300/${place.category.isNotEmpty ? place.category : 'city'}',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (place.category.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      place.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          place.address,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.directions, color: Colors.white),
                      label: const Text(
                        'Get Directions',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async {
                        final url = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${place.lat},${place.lon}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          Get.snackbar(
                              'Error', 'Could not open maps application.');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void openFilterModal() {
    FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Filter Nearby Places',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Category',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Cafe',
                        'Restaurant',
                        'Hotel',
                        'Bank',
                        'Hospital',
                        'Supermarket',
                      ].map((cat) {
                        final isSelected = filterCategory.value.toLowerCase() ==
                            cat.toLowerCase();
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              filterCategory.value = cat;
                            }
                          },
                          selectedColor: Colors.teal.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.teal : null,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    )),
                const SizedBox(height: 20),
                const Text(
                  'Radius Distance',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        {'label': '500m', 'val': 500.0},
                        {'label': '1km', 'val': 1000.0},
                        {'label': '3km', 'val': 3000.0},
                        {'label': '5km', 'val': 5000.0},
                        {'label': '10km', 'val': 10000.0},
                      ].map((r) {
                        final label = r['label'] as String;
                        final val = r['val'] as double;
                        final isSelected =
                            (filterRadius.value - val).abs() < 1.0;
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) filterRadius.value = val;
                          },
                          selectedColor: Colors.teal.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.teal : null,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    )),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Get.back();
                      applyFilter();
                    },
                    child: const Text(
                      'Apply Filter & Search',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> applyFilter() async {
    if (filterCategory.value.isEmpty) {
      filterCategory.value = 'Cafe';
    }

    // Get current map center
    double centerLat = 11.5564;
    double centerLon = 104.9282;

    if (mapController != null) {
      try {
        final region = await mapController!.getVisibleRegion();
        centerLat = (region.northeast.latitude + region.southwest.latitude) / 2;
        centerLon =
            (region.northeast.longitude + region.southwest.longitude) / 2;
      } catch (_) {}
    }

    // Calculate bounding box based on radius
    final double radiusMeters = filterRadius.value;
    final double latDelta = radiusMeters / 111320.0;
    final double cosLat = math.cos(centerLat * math.pi / 180.0);
    final double lonDelta = radiusMeters /
        (40075000.0 * (cosLat.abs() < 0.0001 ? 1.0 : cosLat) / 360.0);

    final double minLat = centerLat - latDelta;
    final double maxLat = centerLat + latDelta;
    final double minLon = centerLon - lonDelta;
    final double maxLon = centerLon + lonDelta;

    final bbox =
        '${minLon.toStringAsFixed(6)},${minLat.toStringAsFixed(6)},${maxLon.toStringAsFixed(6)},${maxLat.toStringAsFixed(6)}';

    isSearching.value = true;
    try {
      final Map<String, dynamic> queryParams = {
        'q': filterCategory.value.toLowerCase(),
        'limit': 20,
        'lat': centerLat.toStringAsFixed(6),
        'lon': centerLon.toStringAsFixed(6),
        'bbox': bbox,
      };

      var response = await _dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: queryParams,
      );

      List features = response.data['features'] ?? [];

      // If strict bbox returned 0 results, fallback to location biased query without bbox
      if (features.isEmpty) {
        final fallbackParams = {
          'q': filterCategory.value.toLowerCase(),
          'limit': 20,
          'lat': centerLat.toStringAsFixed(6),
          'lon': centerLon.toStringAsFixed(6),
        };
        final fallbackResponse = await _dio.get(
          'https://photon.komoot.io/api/',
          queryParameters: fallbackParams,
        );
        features = fallbackResponse.data['features'] ?? [];
      }

      if (features.isEmpty) {
        Get.snackbar('No Results', 'No ${filterCategory.value} found nearby.');
        isSearching.value = false;
        return;
      }

      final apiResults = features.map((feature) {
        final props = feature['properties'] ?? {};
        final coords = feature['geometry']['coordinates'];

        final name = props['name'] ?? '';
        final street = props['street'] ?? '';
        final district = props['district'] ?? '';
        final city = props['city'] ?? props['state'] ?? '';

        List<String> parts = [];
        if (name.toString().isNotEmpty) parts.add(name.toString());
        if (street.toString().isNotEmpty) parts.add(street.toString());
        if (district.toString().isNotEmpty) parts.add(district.toString());
        if (city.toString().isNotEmpty) parts.add(city.toString());

        final displayName =
            parts.isEmpty ? 'Unknown Location' : parts.join(', ');

        List<String> addrParts = [];
        if (street.toString().isNotEmpty) addrParts.add(street.toString());
        if (district.toString().isNotEmpty) addrParts.add(district.toString());
        if (city.toString().isNotEmpty) addrParts.add(city.toString());
        final address =
            addrParts.isEmpty ? 'Unknown Address' : addrParts.join(', ');
        final finalName =
            name.toString().isNotEmpty ? name.toString() : 'Unknown Place';

        final category =
            props['osm_value'] ?? filterCategory.value.toLowerCase();

        return PlaceSuggestion(
          displayName: displayName,
          name: finalName,
          address: address,
          lat: (coords[1] as num).toDouble(),
          lon: (coords[0] as num).toDouble(),
          category: category.toString(),
        );
      }).toList();

      searchResults.value = apiResults;
      searchQuery.value = filterCategory.value;
      textController.text = filterCategory.value;

      // Drop all pins and fit camera smoothly!
      await onSearchSubmitted(filterCategory.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load nearby places: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSearching.value = false;
    }
  }
}
