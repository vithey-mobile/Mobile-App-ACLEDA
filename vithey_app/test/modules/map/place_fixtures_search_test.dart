import 'package:flutter_test/flutter_test.dart';
import 'package:aub_connect_app/data/fixtures/place_fixtures.dart';

void main() {
  group('PlaceFixtures Search & Autocomplete', () {
    const lat = PlaceFixtures.defaultLat;
    const lng = PlaceFixtures.defaultLng;

    test('search finds ACLEDA Bank branches and ATMs', () {
      final res = PlaceFixtures.search(query: 'acleda', lat: lat, lng: lng);
      expect(res.places, isNotEmpty);
      expect(res.places.any((p) => p.name.contains('ACLEDA')), isTrue);
    });

    test('search finds cafes by category or keyword', () {
      final res = PlaceFixtures.search(query: 'cafe', lat: lat, lng: lng);
      expect(res.places, isNotEmpty);
      expect(res.places.any((p) => p.name.contains('Coffee') || p.name.contains('Cafe')), isTrue);
    });

    test('search finds restaurants like KFC', () {
      final res = PlaceFixtures.search(query: 'kfc', lat: lat, lng: lng);
      expect(res.places, isNotEmpty);
      expect(res.places.any((p) => p.name.contains('KFC')), isTrue);
    });

    test('search finds supermarkets and markets', () {
      final res = PlaceFixtures.search(query: 'market', lat: lat, lng: lng);
      expect(res.places, isNotEmpty);
      expect(res.places.any((p) => p.name.contains('Market')), isTrue);
    });

    test('search finds places regardless of distance without dropping', () {
      final res = PlaceFixtures.search(query: 'aeon', lat: 12.0, lng: 105.0);
      expect(res.places, isNotEmpty);
      expect(res.places.any((p) => p.name.contains('AEON')), isTrue);
    });

    test('autocomplete provides suggestions for partial keywords', () {
      final suggestions = PlaceFixtures.autocomplete(input: 'bank', lat: lat, lng: lng);
      expect(suggestions, isNotEmpty);
      expect(suggestions.any((s) => s.primaryText.toLowerCase().contains('bank') || s.secondaryText?.toLowerCase().contains('bank') == true), isTrue);
    });

    test('nearby does not return empty even on distant coordinates', () {
      final res = PlaceFixtures.nearby(lat: 37.422, lng: -122.084);
      expect(res.places, isNotEmpty);
    });

    test('search finds ACLEDA University of Business (AUB) when querying "AUB"', () {
      final res = PlaceFixtures.search(query: 'AUB', lat: lat, lng: lng);
      expect(res.places, isNotEmpty);
      expect(res.places.length, equals(1)); // Only the main campus, no sub-venues or bank branches
      expect(res.places.first.name, contains('AUB'));
      expect(res.places.first.name, contains('ACLEDA University of Business'));
      expect(res.places.first.category, equals('university'));
      expect(res.places.any((p) => p.category == 'bank' || p.category == 'atm'), isFalse);
    });

    test('search finds AUB when querying "aub university"', () {
      final res = PlaceFixtures.search(query: 'aub university', lat: lat, lng: lng);
      expect(res.places, isNotEmpty);
      expect(res.places.length, equals(1)); // Only the main campus
      expect(res.places.any((p) => p.name.contains('ACLEDA University of Business (AUB)')), isTrue);
    });

    test('search finds AUB when querying "acleda university"', () {
      final res = PlaceFixtures.search(query: 'acleda university', lat: lat, lng: lng);
      expect(res.places, isNotEmpty);
      expect(res.places.any((p) => p.name.contains('ACLEDA University of Business (AUB)')), isTrue);
    });

    test('search finds AUB campus library when querying "AUB library"', () {
      final res = PlaceFixtures.search(query: 'AUB library', lat: lat, lng: lng);
      expect(res.places, isNotEmpty);
      expect(res.places.first.name, contains('Library'));
      expect(res.places.first.name, contains('AUB'));
    });

    test('autocomplete returns AUB as top suggestion when typing "aub"', () {
      final suggestions = PlaceFixtures.autocomplete(input: 'aub', lat: lat, lng: lng);
      expect(suggestions, isNotEmpty);
      expect(suggestions.first.primaryText, contains('ACLEDA University of Business (AUB)'));
    });

    test('search finds other Phnom Penh universities: AUPP, RUPP, ITC, NUM', () {
      final aupp = PlaceFixtures.search(query: 'aupp', lat: lat, lng: lng);
      expect(aupp.places.any((p) => p.name.contains('AUPP')), isTrue);

      final rupp = PlaceFixtures.search(query: 'rupp', lat: lat, lng: lng);
      expect(rupp.places.any((p) => p.name.contains('RUPP')), isTrue);

      final itc = PlaceFixtures.search(query: 'itc', lat: lat, lng: lng);
      expect(itc.places.any((p) => p.name.contains('ITC')), isTrue);

      final num = PlaceFixtures.search(query: 'num', lat: lat, lng: lng);
      expect(num.places.any((p) => p.name.contains('NUM')), isTrue);
    });
  });
}
