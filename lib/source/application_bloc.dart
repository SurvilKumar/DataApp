import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_first_app/glocator/geolocatore.dart';

class Applicationbloc with ChangeNotifier {
  final geoLocatoreService = GeolocatoreService();

  Position? currentLocation;
  Applicationbloc() {
    setCurrentLocation();
  }

  setCurrentLocation() async {
    currentLocation = await geoLocatoreService.getCurrantLocation();
    notifyListeners();
  }
}
