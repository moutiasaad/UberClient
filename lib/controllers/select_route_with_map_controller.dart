// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prime_taxi_flutter_ui_kit/api/map_service.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_colors.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_icons.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_size.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_strings.dart';
import 'package:http/http.dart' as http;
import 'package:prime_taxi_flutter_ui_kit/controllers/home_controller.dart';

HomeController homeController = Get.put(HomeController());

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? json['description'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
    );
  }
}

class SelectRouteWithMapController extends GetxController {
  RxSet<Marker> markers = <Marker>{}.obs;
  RxString userAddress = ''.obs;
  RxBool like = false.obs;
  BitmapDescriptor? customMarker;
  final MarkerId markerId = const MarkerId(AppStrings.currentLocation);
  // Default to Qatar (Doha)
  LatLng? selectedDestination;
  GoogleMapController? myMapController;
  RxBool isSwapped = false.obs;
  RxList<Widget> routeListTiles = <Widget>[].obs;
  // Default to Qatar (Doha) coordinates
  RxDouble latitude = 25.2854.obs;
  RxDouble longitude = 51.5310.obs;
  Rx<LatLng> initialLocation = const LatLng(25.2854, 51.5310).obs;
  Rx<LatLng> userLocation = const LatLng(0, 0).obs;
  RxInt selectedServiceIndex = 0.obs;
  TextEditingController locationController =
      TextEditingController(text: homeController.userAddress.value);
  TextEditingController destinationController =
      TextEditingController(text: AppStrings.templeDestination);
  TextEditingController addStopController =
      TextEditingController(text: AppStrings.stopDestination);
  RxSet<Polyline> polylines = <Polyline>{}.obs;
  RxBool showPolyline = false.obs;
  final PolylinePoints polylinePoints = PolylinePoints(apiKey: 'AIzaSyAgrMwwCZlfp8Updk7wpl0oBihrvG4QfNc');
  RxBool isTimerElapsed = false.obs;
  RxBool isAppBarColorVisible = false.obs;
  RxBool isAppBarTitleVisible = false.obs;
  RxBool isBodyVisible = false.obs;
  RxBool isBottomSheetOpen = false.obs;
  Timer? timer;

  // 0 = pickup field, 1 = destination field
  RxInt activeFieldIndex = 1.obs;

  // Current zoom level
  double currentZoom = 14.0;

  // Search suggestions
  RxList<PlacePrediction> pickupSuggestions = <PlacePrediction>[].obs;
  RxList<PlacePrediction> destinationSuggestions = <PlacePrediction>[].obs;
  RxBool isSearchingPickup = false.obs;
  RxBool isSearchingDestination = false.obs;
  RxBool showPickupSuggestions = false.obs;
  RxBool showDestinationSuggestions = false.obs;

  // Debounce timers
  Timer? _pickupDebounce;
  Timer? _destinationDebounce;

  // Flag to prevent search when programmatically setting text
  bool _isSelectingPlace = false;

  // Zoom in
  void zoomIn() {
    currentZoom = currentZoom + 1;
    if (currentZoom > 20) currentZoom = 20;
    myMapController?.animateCamera(CameraUpdate.zoomTo(currentZoom));
  }

  // Zoom out
  void zoomOut() {
    currentZoom = currentZoom - 1;
    if (currentZoom < 3) currentZoom = 3;
    myMapController?.animateCamera(CameraUpdate.zoomTo(currentZoom));
  }

  @override
  void onInit() {
    _getCurrentLocation();
    createMarkers();
    loadCustomMarker();
    showPolyline.value = false;
    timer?.cancel();
    timer = Timer(const Duration(seconds: 5), () {
      isTimerElapsed.value = true;
      update();
    });

    // Add listeners for text controllers
    locationController.addListener(_onPickupTextChanged);
    destinationController.addListener(_onDestinationTextChanged);

    super.onInit();
  }

  @override
  void onClose() {
    timer?.cancel();
    _pickupDebounce?.cancel();
    _destinationDebounce?.cancel();
    locationController.removeListener(_onPickupTextChanged);
    destinationController.removeListener(_onDestinationTextChanged);
    showPolyline.value = false;
    super.onClose();
  }

  // Handle pickup text changes with debounce
  void _onPickupTextChanged() {
    // Skip if we're programmatically setting text after selection
    if (_isSelectingPlace) return;

    if (_pickupDebounce?.isActive ?? false) _pickupDebounce!.cancel();
    _pickupDebounce = Timer(const Duration(milliseconds: 500), () {
      final query = locationController.text;
      if (query.length >= 2) {
        searchPlaces(query, isPickup: true);
      } else {
        pickupSuggestions.clear();
        showPickupSuggestions.value = false;
      }
    });
  }

  // Handle destination text changes with debounce
  void _onDestinationTextChanged() {
    // Skip if we're programmatically setting text after selection
    if (_isSelectingPlace) return;

    if (_destinationDebounce?.isActive ?? false) _destinationDebounce!.cancel();
    _destinationDebounce = Timer(const Duration(milliseconds: 500), () {
      final query = destinationController.text;
      if (query.length >= 2) {
        searchPlaces(query, isPickup: false);
      } else {
        destinationSuggestions.clear();
        showDestinationSuggestions.value = false;
      }
    });
  }
  Future<void> drawRoute(LatLng origin, LatLng destination) async {
    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isEmpty) {
        showPolyline.value = false;
        return;
      }

      final routePoints = result.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      polylines
        ..clear()
        ..add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: AppColors.primaryColor,
            width: 5,
            points: routePoints,
          ),
        );

      showPolyline.value = true;
      polylines.refresh();

      // Auto-fit camera
      final bounds = LatLngBounds(
        southwest: LatLng(
          origin.latitude < destination.latitude
              ? origin.latitude
              : destination.latitude,
          origin.longitude < destination.longitude
              ? origin.longitude
              : destination.longitude,
        ),
        northeast: LatLng(
          origin.latitude > destination.latitude
              ? origin.latitude
              : destination.latitude,
          origin.longitude > destination.longitude
              ? origin.longitude
              : destination.longitude,
        ),
      );

      myMapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    } catch (e) {
      showPolyline.value = false;
      debugPrint('Route error: $e');
    }
  }

  // Search places using Google Places Autocomplete API
  Future<void> searchPlaces(String query, {required bool isPickup}) async {
    if (query.isEmpty) return;

    if (isPickup) {
      isSearchingPickup.value = true;
    } else {
      isSearchingDestination.value = true;
    }

    const apiKey = AppStrings.key;
    final encodedQuery = Uri.encodeComponent(query);

    // Use current location for location bias
    String locationBias = '';
    if (latitude.value != 0 && longitude.value != 0) {
      locationBias = '&location=${latitude.value},${longitude.value}&radius=50000';
    }

    final apiUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$encodedQuery&key=$apiKey$locationBias';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final predictions = decodedResponse['predictions'] as List<dynamic>? ?? [];

        final suggestions = predictions
            .map((p) => PlacePrediction.fromJson(p))
            .toList();

        if (isPickup) {
          pickupSuggestions.value = suggestions;
          showPickupSuggestions.value = suggestions.isNotEmpty;
        } else {
          destinationSuggestions.value = suggestions;
          showDestinationSuggestions.value = suggestions.isNotEmpty;
        }
      }
    } catch (e) {
      print('Place search error: $e');
    } finally {
      if (isPickup) {
        isSearchingPickup.value = false;
      } else {
        isSearchingDestination.value = false;
      }
    }
  }

  // Select a place from suggestions
  Future<void> selectPlace(PlacePrediction place,
      {required bool isPickup}) async {
    _isSelectingPlace = true;

    clearPickupSuggestions();
    clearDestinationSuggestions();

    final latLng = await _getPlaceDetails(place.placeId);
    if (latLng == null) {
      _isSelectingPlace = false;
      return;
    }

    if (isPickup) {
      locationController.text = place.description;
      initialLocation.value = latLng;

      markers.removeWhere((m) => m.markerId.value == 'pickup_marker');
      addCustomMarker(
        latLng,
        'pickup_marker',
        'Pickup',
        place.description,
        BitmapDescriptor.fromBytes(await getBytesFromAsset(
            path: 'assets/icons/pickup_marker.png',
            height: 80,
            width: 80)),
      );
    } else {
      destinationController.text = place.description;
      selectedDestination = latLng;

      markers.removeWhere(
              (m) => m.markerId.value == AppStrings.destinationMarker);
      addCustomMarker(
        latLng,
        AppStrings.destinationMarker,
        'Destination',
        place.description,
        BitmapDescriptor.fromBytes(await getBytesFromAsset(
            path: 'assets/icons/destination_marker.png',
            height: 80,
            width: 80)),
      );
    }

    // ✅ DRAW ROUTE WHEN BOTH EXIST
    if (selectedDestination != null) {
      await drawRoute(initialLocation.value, selectedDestination!);
    } else {
      myMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15),
      );
    }

    _isSelectingPlace = false;
    update();
  }


  // Get place details (coordinates) from place ID
  Future<LatLng?> _getPlaceDetails(String placeId) async {
    const apiKey = AppStrings.key;
    final apiUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final result = decodedResponse['result'];

        if (result != null && result['geometry'] != null) {
          final location = result['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
    } catch (e) {
      print('Place details error: $e');
    }
    return null;
  }

  // Clear suggestions
  void clearPickupSuggestions() {
    pickupSuggestions.clear();
    showPickupSuggestions.value = false;
  }

  void clearDestinationSuggestions() {
    destinationSuggestions.clear();
    showDestinationSuggestions.value = false;
  }

  Future<void> loadCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      AppIcons.currentLocation,
    );
  }

  Set<Marker> createMarkers() {
    return <Marker>{
      Marker(
        markerId: markerId,
        position: initialLocation.value,
        icon: customMarker ?? BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(title: AppStrings.yourCustomMarker),
        anchor: const Offset(0.8, 0.8),
      ),
    };
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      addCustomMarker(
        LatLng(latitude.value, longitude.value),
        AppStrings.currentLocation,
        '',
        '',
        BitmapDescriptor.fromBytes(await getBytesFromAsset(
            path: AppIcons.myPointIcon,
            height: AppSize.size80.toInt(),
            width: AppSize.size80.toInt())),
      );
      await _getCurrentAddress(latitude.value, longitude.value);
      initialLocation.value = LatLng(latitude.value, longitude.value);
      update();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<String> _getCurrentAddress(double latitude, double longitude) async {
    const apiKey = AppStrings.key;
    final apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);

      final results = decodedResponse['results'] as List<dynamic>;

      if (results.isNotEmpty) {
        final address = results.first['formatted_address'] as String;
        userAddress.value = address;
        return address;
      }
    }

    return '';
  }

  Future<Uint8List> getBytesFromAsset(
      {required String path, int? width, int? height}) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width ?? AppSize.size55.toInt(),
      targetHeight: height ?? AppSize.size55.toInt(),
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  setNearMarker(LatLng cord, String name, List types, String status,
      String address) async {
    final BitmapDescriptor markerIcon;

    if (types.contains('library')) {
      markerIcon = BitmapDescriptor.fromBytes(
          await getBytesFromAsset(path: AppIcons.bikeIcon));
    } else if (types.contains('park')) {
      markerIcon = BitmapDescriptor.fromBytes(
          await getBytesFromAsset(path: AppIcons.autoIcon));
    } else if (types.contains('school')) {
      markerIcon = BitmapDescriptor.fromBytes(
          await getBytesFromAsset(path: AppIcons.carIcon));
    } else {
      markerIcon = BitmapDescriptor.fromBytes(
          await getBytesFromAsset(path: AppIcons.mapIcon));
    }
    addCustomMarker(cord, name, name, address, markerIcon);
    update();
  }

  void addCustomMarker(LatLng latLng, String markerId, String placeName,
      String address, BitmapDescriptor icon) {
    markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: latLng,
        icon: icon,
        infoWindow: InfoWindow(
          title: placeName,
          snippet: address,
        ),
        onTap: () {
          onMarkerTap(latLng);
        },
      ),
    );

    if (selectedDestination != null) {
      // markers.add(
      //   Marker(
      //     markerId: const MarkerId('selectedDestinationMarker'),
      //     position: LatLng(
      //         selectedDestination!.latitude, selectedDestination!.longitude),
      //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      //     infoWindow: const InfoWindow(
      //       title: 'Selected Destination',
      //       snippet: 'Your selected destination',
      //     ),
      //   ),
      // );
    }
    update();
  }

  void onMarkerTap(LatLng latLng) {}
  gMapsFunctionCall(context) {
    // Move camera to Qatar (Doha) on map load
    Timer(const Duration(seconds: 1), () async {
      myMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(const LatLng(25.2854, 51.5310), 12),
      );
    });
  }

  void addPolylineToDestination() async {
    if (selectedDestination != null) {
      LatLng destinationLatLng = selectedDestination!;
      polylines.clear();
      markers.removeWhere(
          (marker) => marker.markerId.value == AppStrings.destinationMarker);
      addCustomMarker(
        destinationLatLng,
        AppStrings.destinationMarker,
        AppStrings.destinationPoint,
        AppStrings.yourDestination,
        BitmapDescriptor.fromBytes(await getBytesFromAsset(
            path: 'assets/icons/destination_marker.png',
            height: 80,
            width: 80)),
      );
      await calculateRouteAndDrawPolyline(
        destinationLatLng,
      );
      showPolyline.value = true;
      update();
    }
  }

  Future<void> calculateRouteAndDrawPolyline(
    LatLng destination,
  ) async {
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
            destination:
                PointLatLng(destination.latitude, destination.longitude),
            origin: PointLatLng(initialLocation.value.latitude, initialLocation.value.longitude),
            mode: TravelMode.driving),
        //googleApiKey: "AIzaSyAgrMwwCZlfp8Updk7wpl0oBihrvG4QfNc",
      );

      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = result.points
            .map((PointLatLng point) => LatLng(point.latitude, point.longitude))
            .toList();

        Polyline polyline = Polyline(
          polylineId: const PolylineId(AppStrings.route),
          color: AppColors.primaryColor,
          points: polylineCoordinates,
          width: 5,
        );
        polylines.clear();
        polylines.add(polyline);
        showPolyline.value = true;
        polylines.refresh();
        update();
      } else {
        showPolyline.value = false;
      }
    } catch (e) {
      showPolyline.value = false;
      print('Route calculation error: $e');
    }
  }

  void swapItems() {
    final temp = routeListTiles[routeListTiles.length - 2];
    routeListTiles[routeListTiles.length - 2] =
        routeListTiles[routeListTiles.length - 1];
    routeListTiles[routeListTiles.length - 1] = temp;

    // Also swap the actual location data
    final tempLocation = initialLocation.value;
    final tempAddress = locationController.text;

    initialLocation.value = selectedDestination ?? const LatLng(0, 0);
    locationController.text = destinationController.text;

    selectedDestination = tempLocation;
    destinationController.text = tempAddress;

    isSwapped.value = !isSwapped.value;

    // Redraw polyline
    if (_isPickupSet() && _isDestinationSet()) {
      calculateRouteFromAddresses(initialLocation.value, selectedDestination!);
    }
  }

  // Set which field is active for map selection
  void setActiveField(int index) {
    activeFieldIndex.value = index;
    // Clear opposite suggestions when switching fields
    if (index == 0) {
      clearDestinationSuggestions();
    } else {
      clearPickupSuggestions();
    }
    update();
  }

  // Handle map tap - update selected field with tapped location
  Future<void> onMapTapped(LatLng tappedLocation) async {
    _isSelectingPlace = true;

    final address = await _reverseGeocode(tappedLocation) ?? '';

    if (activeFieldIndex.value == 0) {
      locationController.text = address;
      initialLocation.value = tappedLocation;

      markers.removeWhere((m) => m.markerId.value == 'pickup_marker');
      addCustomMarker(
        tappedLocation,
        'pickup_marker',
        'Pickup',
        address,
        BitmapDescriptor.fromBytes(await getBytesFromAsset(
            path: 'assets/icons/pickup_marker.png',
            height: 80,
            width: 80)),
      );
    } else {
      destinationController.text = address;
      selectedDestination = tappedLocation;

      markers.removeWhere(
              (m) => m.markerId.value == AppStrings.destinationMarker);
      addCustomMarker(
        tappedLocation,
        AppStrings.destinationMarker,
        'Destination',
        address,
        BitmapDescriptor.fromBytes(await getBytesFromAsset(
            path: 'assets/icons/destination_marker.png',
            height: 80,
            width: 80)),
      );
    }

    if (selectedDestination != null) {
      await drawRoute(initialLocation.value, selectedDestination!);
    }

    _isSelectingPlace = false;
    update();
  }


  // Check if pickup location has been set by user
  bool _isPickupSet() {
    return initialLocation.value.latitude != 25.2854 ||
           initialLocation.value.longitude != 51.5310;
  }

  // Check if destination has been set by user
  bool _isDestinationSet() {
    return selectedDestination != null &&
           (selectedDestination!.latitude != 25.2854 ||
            selectedDestination!.longitude != 51.5310);
  }

  // Reverse geocode - get address from LatLng
  Future<String?> _reverseGeocode(LatLng location) async {
    const apiKey = AppStrings.key;
    final apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final results = decodedResponse['results'] as List<dynamic>;

        if (results.isNotEmpty) {
          return results.first['formatted_address'] as String;
        }
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
    }
    return null;
  }

  // Geocode addresses and show markers on map
  Future<void> geocodeAndShowMarkers(String? pickupAddress, String? destinationAddress) async {
    // Geocode pickup address
    if (pickupAddress != null && pickupAddress.isNotEmpty) {
      LatLng? pickupLatLng = await _geocodeAddress(pickupAddress);
      if (pickupLatLng != null) {
        initialLocation.value = pickupLatLng;
        markers.removeWhere((marker) => marker.markerId.value == 'pickup_marker');
        addCustomMarker(
          pickupLatLng,
          'pickup_marker',
          'Pickup Location',
          pickupAddress,
          BitmapDescriptor.fromBytes(await getBytesFromAsset(
              path: 'assets/icons/pickup_marker.png',
              height: 80,
              width: 80)),
        );
        // Move camera to pickup location
        myMapController?.animateCamera(
          CameraUpdate.newLatLngZoom(pickupLatLng, 14),
        );
      }
    }

    // Geocode destination address
    if (destinationAddress != null && destinationAddress.isNotEmpty) {
      LatLng? destLatLng = await _geocodeAddress(destinationAddress);
      if (destLatLng != null) {
        selectedDestination = destLatLng;
        markers.removeWhere((marker) => marker.markerId.value == AppStrings.destinationMarker);
        addCustomMarker(
          destLatLng,
          AppStrings.destinationMarker,
          'Destination',
          destinationAddress,
          BitmapDescriptor.fromBytes(await getBytesFromAsset(
              path: 'assets/icons/destination_marker.png',
              height: 80,
              width: 80)),
        );

        // Draw polyline between pickup and destination
        if (_isPickupSet()) {
          await calculateRouteFromAddresses(initialLocation.value, destLatLng);
        }
      }
    }
    update();
  }

  // Geocode an address to LatLng
  Future<LatLng?> _geocodeAddress(String address) async {
    const apiKey = AppStrings.key;
    final encodedAddress = Uri.encodeComponent(address);
    final apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final results = decodedResponse['results'] as List<dynamic>;

        if (results.isNotEmpty) {
          final location = results.first['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  // Calculate route between two LatLng points
  Future<void> calculateRouteFromAddresses(LatLng origin, LatLng destination) async {
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
            destination: PointLatLng(destination.latitude, destination.longitude),
            origin: PointLatLng(origin.latitude, origin.longitude),
            mode: TravelMode.driving),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = result.points
            .map((PointLatLng point) => LatLng(point.latitude, point.longitude))
            .toList();

        Polyline polyline = Polyline(
          polylineId: const PolylineId(AppStrings.route),
          color: AppColors.primaryColor,
          points: polylineCoordinates,
          width: 5,
        );
        polylines.clear();
        polylines.add(polyline);
        showPolyline.value = true;
        polylines.refresh();
        update();

        // Fit camera to show both markers
        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(
            origin.latitude < destination.latitude ? origin.latitude : destination.latitude,
            origin.longitude < destination.longitude ? origin.longitude : destination.longitude,
          ),
          northeast: LatLng(
            origin.latitude > destination.latitude ? origin.latitude : destination.latitude,
            origin.longitude > destination.longitude ? origin.longitude : destination.longitude,
          ),
        );
        myMapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
      } else {
        showPolyline.value = false;
      }
    } catch (e) {
      showPolyline.value = false;
      print('Route calculation error: $e');
    }
  }

  // Use current location for pickup
  Future<void> useCurrentLocationForPickup() async {
    try {
      // Check if we already have location
      if (latitude.value != 0 && longitude.value != 0) {
        await _setPickupFromLocation(latitude.value, longitude.value);
        return;
      }

      // Otherwise try to get current location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Location services are disabled',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permission denied',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Location permission permanently denied. Please enable in settings.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      await _setPickupFromLocation(position.latitude, position.longitude);
    } catch (e) {
      Get.snackbar('Error', 'Could not get current location',
          snackPosition: SnackPosition.BOTTOM);
      print('Error getting location: $e');
    }
  }

  Future<void> _setPickupFromLocation(double lat, double lng) async {
    final address = await _reverseGeocode(LatLng(lat, lng));
    locationController.text = address ?? '';
    initialLocation.value = LatLng(lat, lng);

    // Update pickup marker
    markers.removeWhere((marker) => marker.markerId.value == 'pickup_marker');
    addCustomMarker(
      LatLng(lat, lng),
      'pickup_marker',
      'Pickup Location',
      address ?? '',
      BitmapDescriptor.fromBytes(await getBytesFromAsset(
          path: 'assets/icons/pickup_marker.png',
          height: 80,
          width: 80)),
    );

    // Draw polyline if destination is set
    if (_isDestinationSet()) {
      await calculateRouteFromAddresses(initialLocation.value, selectedDestination!);
    }

    clearPickupSuggestions();
    update();
  }
}
