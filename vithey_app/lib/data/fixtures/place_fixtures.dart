import 'dart:math' as math;

import 'package:aub_connect_app/data/models/place_models.dart';

class PlaceFixtures {
  PlaceFixtures._();

  /// Phnom Penh default center (Aeon / BKK area).
  static const double defaultLat = 11.5564;
  static const double defaultLng = 104.9282;

  static final List<PlaceCard> _places = [
    // ACLEDA Bank Head Office & Branches
    const PlaceCard(
      googlePlaceId: 'mock-acleda-head-office',
      name: 'ACLEDA Bank Head Office',
      address: '#61, Preah Monivong Blvd, Sangkat Srah Chork, Khan Daun Penh',
      category: 'bank',
      latitude: 11.5750,
      longitude: 104.9218,
      rating: 4.8,
      userRatingCount: 1540,
      priceLevel: 1,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-acleda-tk',
      name: 'ACLEDA Bank Toul Kork Branch',
      address: 'Street 289, Toul Kork, Phnom Penh',
      category: 'bank',
      latitude: 11.5645,
      longitude: 104.9080,
      rating: 4.6,
      userRatingCount: 420,
      priceLevel: 1,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-acleda-bkk',
      name: 'ACLEDA Bank BKK Branch',
      address: 'Street 63 corner Mao Tse Toung, BKK1, Phnom Penh',
      category: 'bank',
      latitude: 11.5450,
      longitude: 104.9260,
      rating: 4.7,
      userRatingCount: 380,
      priceLevel: 1,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-acleda-sen-sok',
      name: 'ACLEDA Bank Sen Sok Branch',
      address: 'St 1003, Sangkat Phnom Penh Thmey, Khan Sen Sok',
      category: 'bank',
      latitude: 11.5890,
      longitude: 104.8870,
      rating: 4.6,
      userRatingCount: 290,
      priceLevel: 1,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-acleda-atm-central',
      name: 'ACLEDA ATM Central Market',
      address: 'Near Phsar Thmey, Daun Penh, Phnom Penh',
      category: 'atm',
      latitude: 11.5690,
      longitude: 104.9225,
      rating: 4.5,
      userRatingCount: 120,
      priceLevel: 0,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-acleda-atm-aeon',
      name: 'ACLEDA ATM AEON Mall',
      address: 'Ground Floor, AEON Mall Phnom Penh',
      category: 'atm',
      latitude: 11.5490,
      longitude: 104.9340,
      rating: 4.6,
      userRatingCount: 95,
      priceLevel: 0,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-aba-atm',
      name: 'ABA Bank ATM',
      address: 'Street 271, Chamkarmon, Phnom Penh',
      category: 'atm',
      latitude: 11.5540,
      longitude: 104.9250,
      rating: 4.2,
      userRatingCount: 40,
      priceLevel: 0,
      openNow: true,
    ),

    // Cafes & Coffee Shops
    const PlaceCard(
      googlePlaceId: 'mock-brown-aeon',
      name: 'Brown Coffee AEON',
      address: 'Aeon Mall Phnom Penh',
      category: 'cafe',
      latitude: 11.5501,
      longitude: 104.9312,
      rating: 4.5,
      userRatingCount: 320,
      priceLevel: 2,
      openNow: true,
      photoUrl: null,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-brown-bkk',
      name: 'Brown Coffee BKK 57',
      address: 'Street 57, corner Street 294, BKK1, Phnom Penh',
      category: 'cafe',
      latitude: 11.5480,
      longitude: 104.9270,
      rating: 4.6,
      userRatingCount: 890,
      priceLevel: 2,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-starbucks-tk',
      name: 'Starbucks The Peak',
      address: 'Olympic, Phnom Penh',
      category: 'cafe',
      latitude: 11.5560,
      longitude: 104.9215,
      rating: 4.3,
      userRatingCount: 210,
      priceLevel: 3,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-starbucks-bokor',
      name: 'Starbucks Bokor',
      address: 'Mao Tse Toung Blvd, Sangkat Olympic, Phnom Penh',
      category: 'cafe',
      latitude: 11.5420,
      longitude: 104.9200,
      rating: 4.4,
      userRatingCount: 340,
      priceLevel: 3,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-cafe-amazon-tk',
      name: 'Cafe Amazon Toul Kork',
      address: 'Street 315, Toul Kork, Phnom Penh',
      category: 'cafe',
      latitude: 11.5670,
      longitude: 104.9050,
      rating: 4.3,
      userRatingCount: 310,
      priceLevel: 2,
      openNow: true,
    ),

    // Restaurants & Fast Food
    const PlaceCard(
      googlePlaceId: 'mock-kfc-tk',
      name: 'KFC Toul Kork',
      address: 'Street 289, Phnom Penh',
      category: 'restaurant',
      latitude: 11.5620,
      longitude: 104.9100,
      rating: 4.1,
      userRatingCount: 540,
      priceLevel: 2,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-kfc-monivong',
      name: 'KFC Monivong',
      address: 'Preah Monivong Blvd, Phnom Penh',
      category: 'restaurant',
      latitude: 11.5550,
      longitude: 104.9230,
      rating: 4.2,
      userRatingCount: 420,
      priceLevel: 2,
      openNow: true,
    ),

    // Supermarkets & Markets
    const PlaceCard(
      googlePlaceId: 'mock-lucky-supermarket',
      name: 'Lucky Supermarket Sihanouk',
      address: 'Sihanouk Blvd, Phnom Penh',
      category: 'supermarket',
      latitude: 11.5515,
      longitude: 104.9220,
      rating: 4.0,
      userRatingCount: 180,
      priceLevel: 2,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-lucky-tk',
      name: 'Lucky Supermarket Toul Kork',
      address: 'Street 315, Toul Kork, Phnom Penh',
      category: 'supermarket',
      latitude: 11.5680,
      longitude: 104.9030,
      rating: 4.2,
      userRatingCount: 310,
      priceLevel: 2,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-central-market',
      name: 'Central Market (Phsar Thmey)',
      address: 'Calmette St, Daun Penh, Phnom Penh',
      category: 'supermarket',
      latitude: 11.5698,
      longitude: 104.9215,
      rating: 4.4,
      userRatingCount: 4500,
      priceLevel: 1,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-russian-market',
      name: 'Russian Market (Phsar Toul Tompoung)',
      address: 'Street 155, Toul Tompoung 1, Chamkarmon, Phnom Penh',
      category: 'supermarket',
      latitude: 11.5405,
      longitude: 104.9150,
      rating: 4.3,
      userRatingCount: 2800,
      priceLevel: 1,
      openNow: true,
    ),

    // Shopping Malls
    const PlaceCard(
      googlePlaceId: 'mock-aeon-mall',
      name: 'AEON Mall Phnom Penh',
      address: 'Samdach Sothearos Blvd, Phnom Penh',
      category: 'shopping_mall',
      latitude: 11.5485,
      longitude: 104.9350,
      rating: 4.6,
      userRatingCount: 2100,
      priceLevel: 3,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-aeon-sen-sok',
      name: 'AEON Mall Sen Sok City (AEON 2)',
      address: 'Street 1003, Bayab Village, Sen Sok, Phnom Penh',
      category: 'shopping_mall',
      latitude: 11.5950,
      longitude: 104.8820,
      rating: 4.7,
      userRatingCount: 3200,
      priceLevel: 3,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-chip-mong-271',
      name: 'Chip Mong 271 Mega Mall',
      address: 'Street 271, Sangkat Boeung Tumpun, Khan Meanchey',
      category: 'shopping_mall',
      latitude: 11.5280,
      longitude: 104.9120,
      rating: 4.5,
      userRatingCount: 1600,
      priceLevel: 3,
      openNow: true,
    ),

    // Universities & Education
    const PlaceCard(
      googlePlaceId: 'mock-aub',
      name: 'ACLEDA University of Business (AUB)',
      address:
          'Phnom Penh - Hanoi Friendship Blvd, Phum Anlong Kngan, Sangkat Kouk Khleang, Khan Sen Sok, Phnom Penh',
      category: 'university',
      latitude: 11.5975,
      longitude: 104.8690,
      rating: 4.9,
      userRatingCount: 880,
      priceLevel: null,
      openNow: true,
      photoUrl:
          'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=1200&q=80',
    ),
    const PlaceCard(
      googlePlaceId: 'mock-aub-library',
      name: 'AUB Library & Innovation Center (ACLEDA University)',
      address:
          'Building B, ACLEDA University of Business (AUB), Hanoi Blvd, Sen Sok, Phnom Penh',
      category: 'university',
      latitude: 11.5978,
      longitude: 104.8694,
      rating: 4.8,
      userRatingCount: 340,
      priceLevel: null,
      openNow: true,
      photoUrl:
          'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=1200&q=80',
    ),
    const PlaceCard(
      googlePlaceId: 'mock-aub-canteen',
      name: 'AUB University Canteen & Student Lounge',
      address:
          'Student Hub Ground Floor, ACLEDA University of Business (AUB), Sen Sok',
      category: 'cafe',
      latitude: 11.5972,
      longitude: 104.8687,
      rating: 4.6,
      userRatingCount: 215,
      priceLevel: 1,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-aupp',
      name: 'American University of Phnom Penh (AUPP)',
      address:
          '#278H, Street 201R, Kroalkor Village, Sangkat Kilometer 6, Khan Russey Keo, Phnom Penh',
      category: 'university',
      latitude: 11.6065,
      longitude: 104.9125,
      rating: 4.7,
      userRatingCount: 430,
      priceLevel: null,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-rupp',
      name: 'Royal University of Phnom Penh (RUPP)',
      address:
          'Russian Confederation Blvd, Sangkat Teuk Laak I, Khan Toul Kork, Phnom Penh',
      category: 'university',
      latitude: 11.5688,
      longitude: 104.8935,
      rating: 4.6,
      userRatingCount: 1420,
      priceLevel: null,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-itc',
      name: 'Institute of Technology of Cambodia (ITC)',
      address:
          'Russian Confederation Blvd, Sangkat Teuk Laak I, Khan Toul Kork, Phnom Penh',
      category: 'university',
      latitude: 11.5705,
      longitude: 104.8990,
      rating: 4.7,
      userRatingCount: 980,
      priceLevel: null,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-num',
      name: 'National University of Management (NUM)',
      address:
          'St. 96, Sangkat Wat Phnom, Khan Daun Penh, Phnom Penh',
      category: 'university',
      latitude: 11.5746,
      longitude: 104.9212,
      rating: 4.5,
      userRatingCount: 650,
      priceLevel: null,
      openNow: true,
    ),

    // Health & Pharmacy
    const PlaceCard(
      googlePlaceId: 'mock-pharmacy-pp',
      name: 'Pharmacie De La Gare',
      address: 'Near Central Market, Phnom Penh',
      category: 'pharmacy',
      latitude: 11.5695,
      longitude: 104.9210,
      rating: 4.4,
      userRatingCount: 95,
      priceLevel: 1,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-calmette-hospital',
      name: 'Calmette Hospital',
      address: '#3, Preah Monivong Blvd, Daun Penh, Phnom Penh',
      category: 'hospital',
      latitude: 11.5830,
      longitude: 104.9190,
      rating: 4.1,
      userRatingCount: 650,
      priceLevel: 2,
      openNow: true,
    ),

    // Services & Gas Stations
    const PlaceCard(
      googlePlaceId: 'mock-phone-shop',
      name: 'Cellcard Store Soriya Mall',
      address: 'Soriya Mall, Phnom Penh',
      category: 'other',
      latitude: 11.5605,
      longitude: 104.9180,
      rating: 3.9,
      userRatingCount: 70,
      priceLevel: 2,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-gas-caltex',
      name: 'Caltex Station Russian Blvd',
      address: 'Russian Blvd, Phnom Penh',
      category: 'gas_station',
      latitude: 11.5650,
      longitude: 104.9000,
      rating: 4.0,
      userRatingCount: 55,
      priceLevel: 2,
      openNow: true,
    ),
  ];

  static int distanceBetweenM(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return _distanceM(lat1, lng1, lat2, lng2);
  }

  static int _distanceM(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (r * c).round();
  }

  static double _rad(double deg) => deg * math.pi / 180;

  static PlaceSearchResult nearby({
    required double lat,
    required double lng,
    PlaceFilter filter = const PlaceFilter(),
    Set<String> favoriteIds = const {},
  }) {
    var list = _places.map((p) {
      final d = _distanceM(lat, lng, p.latitude, p.longitude);
      return p.copyWith(
        distanceM: d,
        isFavorite: favoriteIds.contains(p.googlePlaceId),
      );
    }).where((p) {
      if (filter.category != null &&
          filter.category!.isNotEmpty &&
          p.category != filter.category) {
        return false;
      }
      if (filter.openNow == true && p.openNow != true) return false;
      if (filter.minRating != null &&
          (p.rating == null || p.rating! < filter.minRating!)) {
        return false;
      }
      if (filter.priceLevel != null && p.priceLevel != filter.priceLevel) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => (a.distanceM ?? 0).compareTo(b.distanceM ?? 0));

    // Prefer places within radius, but fall back gracefully so map never shows empty
    final effectiveRadius = math.max(filter.radiusM, 5000);
    final inRadius = list.where((p) => (p.distanceM ?? 0) <= effectiveRadius).toList();
    if (inRadius.isNotEmpty) {
      list = inRadius;
    }

    if (list.length > filter.limit) {
      list = list.take(filter.limit).toList();
    }

    return PlaceSearchResult(
      centerLat: lat,
      centerLng: lng,
      radiusM: effectiveRadius,
      places: list,
    );
  }

  static bool _matchesToken(
    String token,
    String name,
    String address,
    String cat,
    String catLabel,
  ) {
    if (name.contains(token) ||
        address.contains(token) ||
        cat.contains(token) ||
        catLabel.contains(token)) {
      return true;
    }
    // University acronyms and abbreviations
    if (token == 'aub' &&
        (name.contains('aub') || name.contains('acleda university'))) {
      return true;
    }
    if (token == 'acleda' &&
        (name.contains('acleda') || name.contains('aub'))) {
      return true;
    }
    if (token == 'aupp' && name.contains('aupp')) {
      return true;
    }
    if (token == 'rupp' && name.contains('rupp')) {
      return true;
    }
    if (token == 'itc' && name.contains('itc')) {
      return true;
    }
    if (token == 'num' && name.contains('num')) {
      return true;
    }
    if ((token == 'uni' || token == 'univ') &&
        (cat == 'university' || name.contains('university'))) {
      return true;
    }
    return false;
  }

  static int _relevanceScore(
    String fullQuery,
    List<String> tokens,
    String name,
    String address,
    String cat, {
    String? id,
  }) {
    int score = 0;
    final q = fullQuery.trim().toLowerCase();
    final n = name.toLowerCase();
    final a = address.toLowerCase();

    // Exact full name match
    if (n == q) {
      score += 2000;
    } else if (n.startsWith(q)) {
      score += 1000;
    } else if (n.contains(q)) {
      score += 600;
    }

    // Word boundary or parenthesized acronym match e.g. "(AUB)" or "AUB"
    final boundaryRegex =
        RegExp(r'(^|\s|\(|\/|-)' + RegExp.escape(q) + r'($|\s|\)|\/-)');
    if (boundaryRegex.hasMatch(n)) {
      score += 800;
    }

    for (final token in tokens) {
      final tRegex =
          RegExp(r'(^|\s|\(|\/|-)' + RegExp.escape(token) + r'($|\s|\)|\/-)');
      if (tRegex.hasMatch(n)) {
        score += 400;
      } else if (n.contains(token)) {
        score += 200;
      }
      if (cat.contains(token)) {
        score += 100;
      }
      if (a.contains(token)) {
        score += 40;
      }
      if ((token == 'aub' || token == 'acleda') &&
          (n.contains('aub') || n.contains('acleda'))) {
        score += 300;
      }
    }

    // Main university campus has higher priority than sub-facilities (library, canteen)
    if (id == 'mock-aub' ||
        (n.contains('aub') &&
            n.contains('acleda') &&
            !n.contains('library') &&
            !n.contains('canteen'))) {
      score += 800;
    }

    return score;
  }

  static PlaceSearchResult search({
    required String query,
    required double lat,
    required double lng,
    PlaceFilter filter = const PlaceFilter(),
    Set<String> favoriteIds = const {},
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return nearby(
        lat: lat,
        lng: lng,
        filter: filter,
        favoriteIds: favoriteIds,
      );
    }
    final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    var list = _places.map((p) {
      final d = _distanceM(lat, lng, p.latitude, p.longitude);
      return p.copyWith(
        distanceM: d,
        isFavorite: favoriteIds.contains(p.googlePlaceId),
      );
    }).where((p) {
      final name = p.name.toLowerCase();
      final address = (p.address ?? '').toLowerCase();
      final cat = (p.category ?? '').toLowerCase();
      final catLabel = PlaceCategories.label(p.category ?? '').toLowerCase();

      final matchesQuery = tokens.every((token) =>
          _matchesToken(token, name, address, cat, catLabel));

      if (!matchesQuery) return false;

      // When searching university/campus (e.g. AUB), do not include sub-venues (library, canteen)
      // unless the user query explicitly mentions them
      if (p.googlePlaceId == 'mock-aub-library' ||
          p.googlePlaceId == 'mock-aub-canteen') {
        final mentionsLibrary =
            tokens.any((t) => t.contains('lib') || t.contains('innov'));
        final mentionsCanteen = tokens.any(
            (t) => t.contains('cant') || t.contains('food') || t.contains('lounge'));
        if (p.googlePlaceId == 'mock-aub-library' && !mentionsLibrary) return false;
        if (p.googlePlaceId == 'mock-aub-canteen' && !mentionsCanteen) return false;
      }

      // Only apply explicit user filter if provided
      if (filter.category != null &&
          filter.category!.isNotEmpty &&
          p.category != filter.category) {
        return false;
      }
      if (filter.openNow == true && p.openNow != true) return false;
      if (filter.minRating != null &&
          (p.rating == null || p.rating! < filter.minRating!)) {
        return false;
      }
      if (filter.priceLevel != null && p.priceLevel != filter.priceLevel) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final scoreA = _relevanceScore(
          q,
          tokens,
          a.name,
          a.address ?? '',
          a.category ?? '',
          id: a.googlePlaceId,
        );
        final scoreB = _relevanceScore(
          q,
          tokens,
          b.name,
          b.address ?? '',
          b.category ?? '',
          id: b.googlePlaceId,
        );
        if (scoreA != scoreB) {
          return scoreB.compareTo(scoreA);
        }
        return (a.distanceM ?? 0).compareTo(b.distanceM ?? 0);
      });

    return PlaceSearchResult(
      centerLat: lat,
      centerLng: lng,
      radiusM: 50000,
      places: list,
    );
  }

  static List<PlaceAutocompleteSuggestion> autocomplete({
    required String input,
    required double lat,
    required double lng,
  }) {
    final q = input.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    final suggestions = _places
        .where((p) {
          final name = p.name.toLowerCase();
          final address = (p.address ?? '').toLowerCase();
          final cat = (p.category ?? '').toLowerCase();
          final catLabel =
              PlaceCategories.label(p.category ?? '').toLowerCase();

          return tokens.every((token) =>
              _matchesToken(token, name, address, cat, catLabel));
        })
        .map(
          (p) => PlaceAutocompleteSuggestion(
            googlePlaceId: p.googlePlaceId,
            primaryText: p.name,
            secondaryText: p.address ?? PlaceCategories.label(p.category ?? ''),
            distanceM: _distanceM(lat, lng, p.latitude, p.longitude),
            latitude: p.latitude,
            longitude: p.longitude,
          ),
        )
        .toList()
      ..sort((a, b) {
        final scoreA = _relevanceScore(
          q,
          tokens,
          a.primaryText,
          a.secondaryText ?? '',
          '',
          id: a.googlePlaceId,
        );
        final scoreB = _relevanceScore(
          q,
          tokens,
          b.primaryText,
          b.secondaryText ?? '',
          '',
          id: b.googlePlaceId,
        );
        if (scoreA != scoreB) {
          return scoreB.compareTo(scoreA);
        }
        return (a.distanceM ?? 0).compareTo(b.distanceM ?? 0);
      });

    return suggestions.take(8).toList();
  }

  static PlaceDetail? detail(String id, {Set<String> favoriteIds = const {}}) {
    final p = _places.cast<PlaceCard?>().firstWhere(
          (e) => e!.googlePlaceId == id,
          orElse: () => null,
        );
    if (p == null) return null;
    return PlaceDetail(
      googlePlaceId: p.googlePlaceId,
      name: p.name,
      address: p.address,
      category: p.category,
      latitude: p.latitude,
      longitude: p.longitude,
      rating: p.rating,
      userRatingCount: p.userRatingCount,
      priceLevel: p.priceLevel,
      openNow: p.openNow,
      openingHours: const ['Mon–Sun 07:30–21:00'],
      photoUrls: p.photoUrl == null ? const [] : [p.photoUrl!],
      isFavorite: favoriteIds.contains(p.googlePlaceId),
      googleMapsUri:
          'https://www.google.com/maps/search/?api=1&query=${p.latitude},${p.longitude}',
    );
  }

  static PlaceCard? byId(String id) {
    try {
      return _places.firstWhere((p) => p.googlePlaceId == id);
    } catch (_) {
      return null;
    }
  }
}
