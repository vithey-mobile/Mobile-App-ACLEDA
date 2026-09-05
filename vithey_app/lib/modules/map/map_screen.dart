import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/place_models.dart';
import 'package:aub_connect_app/modules/map/map_controller.dart';
import 'package:aub_connect_app/modules/map/map_style.dart';
import 'package:aub_connect_app/core/widgets/vithey_search_pill.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends GetView<MapController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.appColors;

    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => GoogleMap(
              onMapCreated: controller.onMapCreated,
              style: Theme.of(context).brightness == Brightness.dark
                  ? darkMapStyle
                  : null,
              initialCameraPosition: CameraPosition(
                target: controller.searchCenter.value,
                zoom: 14,
              ),
              myLocationEnabled: controller.isLocationGranted.value,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: controller.markers.toSet(),
              onCameraMove: controller.onCameraMove,
              onCameraIdle: controller.onCameraIdle,
              onLongPress: controller.onMapLongPress,
              padding: EdgeInsets.only(top: 96, bottom: bottomPadding + 88),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Material(
                        color: colors.cardSurface,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: AppColors.primary),
                          onPressed: controller.goBack,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller.textController,
                          builder: (context, value, _) => Obx(
                            () => VitheySearchPill(
                              controller: controller.textController,
                              hintText: 'Search shops nearby',
                              onChanged: controller.onSearchChanged,
                              onSubmitted: controller.onSearchSubmitted,
                              onClear: controller.clearSearch,
                              trailing: [
                                if (controller.isSearching.value)
                                  const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.tune,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: controller.openFilterModal,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (controller.errorMessage.value.isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8, left: 48),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      );
                    }
                    if (controller.suggestions.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.only(top: 8, left: 48),
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: colors.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: controller.suggestions.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: colors.border,
                        ),
                        itemBuilder: (context, index) {
                          final s = controller.suggestions[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.place_outlined,
                              color: AppColors.primary,
                            ),
                            title: Text(s.primaryText),
                            subtitle: s.secondaryText == null
                                ? null
                                : Text(s.secondaryText!),
                            onTap: () => controller.selectSuggestion(s),
                          );
                        },
                      ),
                    );
                  }),
                  Obx(() {
                    final category = controller.filter.value.category;
                    if (category == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, left: 48),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: Text(PlaceCategories.label(category)),
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.12),
                          side: BorderSide.none,
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => controller.updateFilter(
                            controller.filter.value.copyWith(
                              clearCategory: true,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Obx(() {
            if (!controller.showSearchThisArea.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: MediaQuery.of(context).padding.top + 72,
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(24),
                  color: colors.cardSurface,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: controller.searchThisArea,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        'Search this area',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          Obx(() {
            if (!controller.isLoadingPlaces.value) {
              return const SizedBox.shrink();
            }
            return const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.primary,
              ),
            );
          }),
          Positioned(
            right: 16,
            bottom: bottomPadding + 88,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'addPlaceBtn',
                  mini: true,
                  backgroundColor: colors.cardSurface,
                  foregroundColor: AppColors.primary,
                  onPressed: controller.openAddPlace,
                  child: const Icon(Icons.add_location_alt_outlined),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => GestureDetector(
                    onLongPress: controller.onMyLocationLongPress,
                    child: FloatingActionButton(
                      heroTag: 'myLocationBtn',
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      onPressed: controller.onMyLocationTap,
                      child: Icon(
                        controller.isFollowingGps.value
                            ? Icons.my_location
                            : Icons.gps_not_fixed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
