void main() {
  final a = {'name': 'test', 'lat': 1.0, 'lon': 2.0};
  print(a is Map<String, dynamic>);
  print(a is Map);
}
