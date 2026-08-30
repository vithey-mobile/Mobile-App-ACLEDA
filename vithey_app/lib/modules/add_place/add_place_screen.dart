import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'add_place_controller.dart';

class AddPlaceScreen extends GetView<AddPlaceController> {
  const AddPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: controller.goBack,
        ),
        title: Text(
          'Add Place',
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                hintText: 'Place name',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text('Category',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: Theme.of(context).cardColor,
                    value: controller.selectedCategory.value,
                    items: controller.categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category,
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color)),
                      );
                    }).toList(),
                    onChanged: controller.onCategoryChanged,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text('Pin Location',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            const Text('Drag the map to pinpoint the exact location.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),

            // Map for selecting location
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Obx(() => GoogleMap(
                          onMapCreated: (mapCtrl) => controller.onMapCreated(
                            mapCtrl,
                            Theme.of(context).brightness == Brightness.dark,
                          ),
                          initialCameraPosition: CameraPosition(
                            target: controller.initialLocation.value,
                            zoom: 15.0,
                          ),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: false,
                          onCameraMove: controller.onCameraMove,
                          gestureRecognizers: {
                            Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                            ),
                          },
                        )),
                    // Center Pin Overlay
                    const IgnorePointer(
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 40.0), // offset so pin tip points at center
                        child: Icon(Icons.location_pin,
                            size: 50, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF00BFA5), // Teal color from mockup
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: controller.submit,
                child: const Text(
                  'Submit',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
