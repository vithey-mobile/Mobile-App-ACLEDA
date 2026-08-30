import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_controller.dart';

class MapScreen extends GetView<MapController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the safe area at the bottom for phones with gesture bars
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      body: Stack(
        children: [
          // Google Map Background
          Obx(() => GoogleMap(
            onMapCreated: (mapCtrl) => controller.onMapCreated(
              mapCtrl, 
              Theme.of(context).brightness == Brightness.dark,
            ),
            initialCameraPosition: const CameraPosition(
              target: LatLng(11.5564, 104.9282), // Phnom Penh default
              zoom: 14.0,
            ),
            myLocationEnabled: controller.isLocationGranted.value,
            myLocationButtonEnabled: false, // Hide default button to use custom one
            zoomControlsEnabled: false,
            markers: controller.markers.toSet(), // Ensures Obx tracks the changes properly
            padding: EdgeInsets.only(top: 80, bottom: bottomPadding + 40),
          )),
          
          // Top Search Bar & Suggestions
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.teal),
                        onPressed: controller.goBack,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: controller.textController,
                            onChanged: controller.onSearchChanged,
                            onSubmitted: controller.onSearchSubmitted,
                            textInputAction: TextInputAction.search,
                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(color: Theme.of(context).hintColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              suffixIcon: Obx(() {
                                if (controller.isSearching.value) {
                                  return const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal)
                                    )
                                  );
                                } else if (controller.searchQuery.value.isNotEmpty) {
                                  return IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: controller.clearSearch,
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Autocomplete Dropdown
                  Obx(() {
                    if (controller.errorMessage.value.isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8, left: 48),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Text(
                          "Error: ${controller.errorMessage.value}",
                          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                        ),
                      );
                    }
                    
                    if (controller.searchResults.isEmpty) return const SizedBox.shrink();
                    
                    return Container(
                      margin: const EdgeInsets.only(top: 8, left: 48), // Align with TextField
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 250), // Don't let it grow too long
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: controller.searchResults.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Theme.of(context).dividerColor),
                        itemBuilder: (context, index) {
                          final place = controller.searchResults[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.teal),
                            title: Text(
                              place.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            onTap: () {
                              controller.onSuggestionSelected(place);
                            },
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          
          // Bottom Right Custom Action Buttons
          Positioned(
            right: 16,
            bottom: bottomPadding > 0 ? bottomPadding + 16 : 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current Location Button
                FloatingActionButton(
                  heroTag: 'currentLocationBtn',
                  backgroundColor: Theme.of(context).cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onPressed: controller.goToCurrentLocation,
                  child: const Icon(Icons.my_location, color: Colors.blueAccent),
                ),
                const SizedBox(height: 16),
                // Add New Place Button
                FloatingActionButton(
                  heroTag: 'addPlaceBtn',
                  backgroundColor: Colors.teal, // Pop of color
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onPressed: controller.openAddPlace,
                  child: const Icon(Icons.add_location_alt, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
