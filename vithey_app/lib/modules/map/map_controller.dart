import 'dart:async';

import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/fixtures/place_fixtures.dart';
import 'package:aub_connect_app/data/models/place_models.dart';
import 'package:aub_connect_app/data/repositories/place_repository.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/core/widgets/vithey_filter_chips.dart';
import 'package:aub_connect_app/core/widgets/vithey_switch.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class MapController extends GetxController {
  MapController({PlaceRepository? repository})
      : _repository = repository ?? Get.find<PlaceRepository>();

  final PlaceRepository _repository;

  final searchQuery = ''.obs;
  final suggestions = <PlaceAutocompleteSuggestion>[].obs;
  final places = <PlaceCard>[].obs;
  final markers = <Marker>{}.obs;
  final isSearching = false.obs;
  final isLoadingPlaces = false.obs;
  final isLocationGranted = false.obs;
  final isFollowingGps = true.obs;
  final showSearchThisArea = false.obs;
  final errorMessage = ''.obs;
  final selectedPlace = Rxn<PlaceCard>();
  final filter = const PlaceFilter(category: 'cafe').obs;

  final gpsLatLng = Rxn<LatLng>();
  final searchCenter = LatLng(
    PlaceFixtures.defaultLat,
    PlaceFixtures.defaultLng,
  ).obs;

  final textController = TextEditingController();
  GoogleMapController? mapController;
  Timer? _debounce;
  LatLng? _pendingLongPress;
  Marker? _searchFromHereMarker;

  static const _searchFromHereId = MarkerId('search_from_here');

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String && args.trim().isNotEmpty) {
      textController.text = args.trim();
      searchQuery.value = args.trim();
    }
    _checkLocationPermission();
  }

  @override
  void onClose() {
    textController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      isLocationGranted.value = true;
      await goToCurrentLocation(runNearby: true);
    } else {
      isLocationGranted.value = false;
      await loadNearby();
    }
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    if (isLocationGranted.value) {
      await goToCurrentLocation(runNearby: places.isEmpty);
    } else if (places.isEmpty) {
      await loadNearby();
    } else {
      _rebuildMarkers();
    }
  }

  Future<void> goToCurrentLocation({bool runNearby = true}) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      gpsLatLng.value = latLng;
      searchCenter.value = latLng;
      isFollowingGps.value = true;
      showSearchThisArea.value = false;
      await mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15),
      );
      if (runNearby) await loadNearby();
    } catch (_) {
      Get.snackbar(
        AppStrings.appName,
        'Could not get current location',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> onMyLocationTap() async {
    final status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      final next = await Permission.locationWhenInUse.request();
      if (!next.isGranted) {
        Get.snackbar(
          AppStrings.appName,
          'Location permission needed. Open settings to enable.',
          snackPosition: SnackPosition.BOTTOM,
          // GetX types SnackbarController.mainButton as TextButton?;
          // VitheyTextLink extends TextButton so it satisfies the type.
          mainButton: VitheyTextLink(
            label: 'Settings',
            onPressed: openAppSettings,
          ),
        );
        return;
      }
      isLocationGranted.value = true;
    }
    await goToCurrentLocation(runNearby: true);
  }

  Future<void> onMyLocationLongPress() async {
    await goToCurrentLocation(runNearby: true);
    Get.snackbar(
      AppStrings.appName,
      'Back to my location',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void onCameraMove(CameraPosition position) {
    if (!isFollowingGps.value) return;
    final center = searchCenter.value;
    final moved = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          position.target.latitude,
          position.target.longitude,
        ) >
        80;
    if (moved) {
      isFollowingGps.value = false;
      showSearchThisArea.value = true;
    }
  }

  void onCameraIdle() {
    // no-op; Search this area is explicit
  }

  Future<void> searchThisArea() async {
    if (mapController == null) return;
    final bounds = await mapController!.getVisibleRegion();
    final lat =
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
    final lng =
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
    await setSearchCenter(LatLng(lat, lng), fromGps: false);
  }

  Future<void> setSearchCenter(
    LatLng center, {
    required bool fromGps,
    String? label,
  }) async {
    searchCenter.value = center;
    isFollowingGps.value = fromGps;
    showSearchThisArea.value = false;
    if (!fromGps) {
      _searchFromHereMarker = Marker(
        markerId: _searchFromHereId,
        position: center,
        infoWindow: InfoWindow(title: label ?? 'Search from here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    } else {
      _searchFromHereMarker = null;
    }
    await mapController?.animateCamera(CameraUpdate.newLatLngZoom(center, 15));
    await loadNearby();
  }

  Future<void> onMapLongPress(LatLng position) async {
    _pendingLongPress = position;
    final confirm = await Get.bottomSheet<bool>(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Search around here?',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set this pin as your search center and find nearby places.',
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Search around here',
                onPressed: () => Get.back(result: true),
              ),
              CustomButton(
                label: 'Cancel',
                onPressed: () => Get.back(result: false),
                variant: CustomButtonVariant.ghost,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
    if (confirm == true && _pendingLongPress != null) {
      await setSearchCenter(_pendingLongPress!, fromGps: false);
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      suggestions.clear();
      errorMessage.value = '';
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      await _runAutocomplete(value.trim());
    });
  }

  Future<void> onSearchSubmitted(String value) async {
    final q = value.trim();
    if (q.length < 2) return;
    suggestions.clear();
    await loadSearch(q);
  }

  void clearSearch() {
    textController.clear();
    searchQuery.value = '';
    suggestions.clear();
    errorMessage.value = '';
  }

  Future<void> _runAutocomplete(String input) async {
    isSearching.value = true;
    errorMessage.value = '';
    try {
      final center = searchCenter.value;
      suggestions.value = await _repository.autocomplete(
        input: input,
        lat: center.latitude,
        lng: center.longitude,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      suggestions.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> selectSuggestion(PlaceAutocompleteSuggestion suggestion) async {
    suggestions.clear();
    textController.text = suggestion.primaryText;
    searchQuery.value = suggestion.primaryText;

    double? lat = suggestion.latitude;
    double? lng = suggestion.longitude;
    if (lat == null || lng == null) {
      try {
        final detail = await _repository.detail(suggestion.googlePlaceId);
        lat = detail.latitude;
        lng = detail.longitude;
      } catch (_) {
        // fall through to text search
      }
    }

    if (lat != null && lng != null) {
      await setSearchCenter(
        LatLng(lat, lng),
        fromGps: false,
        label: suggestion.primaryText,
      );
    } else {
      await loadSearch(suggestion.primaryText);
    }
  }

  Future<void> loadNearby() async {
    isLoadingPlaces.value = true;
    errorMessage.value = '';
    try {
      final center = searchCenter.value;
      final result = await _repository.nearby(
        lat: center.latitude,
        lng: center.longitude,
        filter: filter.value,
      );
      places.assignAll(result.places);
      _rebuildMarkers();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingPlaces.value = false;
    }
  }

  Future<void> loadSearch(String query) async {
    isLoadingPlaces.value = true;
    errorMessage.value = '';
    try {
      final center = searchCenter.value;
      final result = await _repository.search(
        query: query,
        lat: center.latitude,
        lng: center.longitude,
        filter: filter.value,
      );
      places.assignAll(result.places);
      _rebuildMarkers();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingPlaces.value = false;
    }
  }

  void updateFilter(PlaceFilter next) {
    filter.value = next;
    final q = searchQuery.value.trim();
    if (q.length >= 2) {
      loadSearch(q);
    } else {
      loadNearby();
    }
  }

  void openFilterModal() {
    final current = filter.value;
    final category = (current.category ?? '').obs;
    final radius = current.radiusM.toDouble().obs;
    final openNow = (current.openNow ?? false).obs;
    final minRating = (current.minRating ?? 0.0).obs;

    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Filters',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                VitheyFilterChips(
                  items: [
                    const VitheyFilterChipItem(id: '', label: 'All'),
                    ...PlaceCategories.all.map(
                      (c) => VitheyFilterChipItem(
                        id: c,
                        label: PlaceCategories.label(c),
                        selected: category.value == c,
                      ),
                    ),
                  ],
                  onSelected: (id) => category.value = id,
                ),
                const SizedBox(height: 12),
                Text('Radius: ${radius.value.round()} m'),
                Slider(
                  value: radius.value,
                  min: 500,
                  max: 5000,
                  divisions: 9,
                  activeColor: AppColors.primary,
                  onChanged: (v) => radius.value = v,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Expanded(child: Text('Open now')),
                      VitheySwitch(
                        value: openNow.value,
                        onChanged: (v) => openNow.value = v,
                      ),
                    ],
                  ),
                ),
                Text('Min rating: ${minRating.value.toStringAsFixed(1)}'),
                Slider(
                  value: minRating.value,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  activeColor: AppColors.primary,
                  onChanged: (v) => minRating.value = v,
                ),
                const SizedBox(height: 8),
                CustomButton(
                  label: 'Apply',
                  onPressed: () {
                    updateFilter(
                      PlaceFilter(
                        category:
                            category.value.isEmpty ? null : category.value,
                        radiusM: radius.value.round(),
                        openNow: openNow.value ? true : null,
                        minRating:
                            minRating.value <= 0 ? null : minRating.value,
                      ),
                    );
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  void _rebuildMarkers() {
    final next = <Marker>{};
    if (_searchFromHereMarker != null) {
      next.add(_searchFromHereMarker!);
    }
    for (final place in places) {
      next.add(
        Marker(
          markerId: MarkerId(place.googlePlaceId),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.address,
          ),
          onTap: () => openPlaceSheet(place),
        ),
      );
    }
    markers.assignAll(next);
  }

  Future<void> openPlaceSheet(PlaceCard place) async {
    selectedPlace.value = place;
    PlaceCard current = place;
    await Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return VitheyCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Text(
                    current.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (current.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      current.address!,
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (current.rating != null)
                        Text('★ ${current.rating!.toStringAsFixed(1)}'),
                      if (current.distanceM != null)
                        Text('${current.distanceM} m'),
                      if (current.category != null)
                        Text(PlaceCategories.label(current.category!)),
                      if (current.openNow == true)
                        const Text(
                          'Open now',
                          style: TextStyle(color: AppColors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: current.isFavorite ? 'Saved' : 'Favorite',
                          icon: current.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          variant: CustomButtonVariant.outline,
                          onPressed: () async {
                            final updated =
                                await _repository.toggleFavorite(current);
                            current = updated;
                            selectedPlace.value = updated;
                            final idx = places.indexWhere(
                              (p) =>
                                  p.googlePlaceId == updated.googlePlaceId,
                            );
                            if (idx >= 0) places[idx] = updated;
                            setModalState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          label: 'Directions',
                          icon: Icons.directions,
                          onPressed: () => openDirections(current),
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Future<void> openDirections(PlaceCard place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openAddPlace() async {
    final result = await Get.toNamed(AppRoutes.addPlace);
    if (result is Map) {
      final name = result['name']?.toString() ?? 'My place';
      final lat = (result['lat'] as num?)?.toDouble();
      final lng = (result['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        final local = PlaceCard(
          googlePlaceId: 'local-${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          address: result['address']?.toString(),
          category: result['category']?.toString() ?? 'other',
          latitude: lat,
          longitude: lng,
        );
        places.insert(0, local);
        _rebuildMarkers();
      }
    }
  }

  void goBack() => Get.back();
}
