class ApiUpdateUserLocation{
  String id;
  double latitude;
  double longitude;
  String race;
  String zone;
  String city;

  ApiUpdateUserLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.race,
    required this.zone,
    required this.city,
  });
}