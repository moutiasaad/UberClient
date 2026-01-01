// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../api/map_service.dart';
import '../api/services/ride_service.dart';
import '../api/client/api_client.dart';
import '../models/ride_model.dart';
import '../config/app_colors.dart';
import '../config/app_icons.dart';
import '../config/app_size.dart';
import '../config/app_strings.dart';

class MyRidesController extends GetxController {
  RxSet<Marker> markers = <Marker>{}.obs;
  RxString userAddress = ''.obs;
  RxBool like = false.obs;
  BitmapDescriptor? customMarker;
  final MarkerId markerId = const MarkerId(AppStrings.currentLocation);
  LatLng? selectedDestination = const LatLng(21.2212, 72.8688);
  GoogleMapController? myMapController;
  RxBool searchBoolean = false.obs;

  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  Rx<LatLng> initialLocation = const LatLng(0, 0).obs;
  Rx<LatLng> userLocation = const LatLng(0, 0).obs;
  RxInt selectedServiceIndex = 0.obs;
  RxSet<Polyline> polylines = <Polyline>{}.obs;
  RxBool showPolyline = false.obs;
  final PolylinePoints polylinePoints = PolylinePoints(apiKey: 'AIzaSyCrDYCXAVQZeXxbZx84iRVe5SMmBpm5sy8');
  RxBool isTimerElapsed = false.obs;
  RxBool isAppBarColorVisible = false.obs;
  RxBool isAppBarTitleVisible = false.obs;
  RxBool isBodyVisible = false.obs;
  RxBool isBottomSheetOpen = false.obs;

  // API services
  final RideService _rideService = RideService();

  // Ride data
  RxList<RideModel> rideHistory = <RideModel>[].obs;
  Rx<RideModel?> activeRide = Rx<RideModel?>(null);
  RxBool isLoadingRides = false.obs;
  RxBool isLoadingActiveRide = false.obs;

  // Filter for ride history
  RxString rideFilter = 'all'.obs; // all, active, cancelled, completed

  @override
  void onInit() {
    _getCurrentLocation();
    createMarkers();
    loadCustomMarker();
    showPolyline.value = false;
    Timer(const Duration(seconds: 5), () {
      isTimerElapsed.value = true;
      update();
    });
    super.onInit();
  }

  @override
  void onClose() {
    showPolyline.value = false;
    super.onClose();
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
          path: AppIcons.locationPin1,
          height: AppSize.size60.toInt(),
          width: AppSize.size60.toInt())),
    );
    await _getCurrentAddress(latitude.value, longitude.value);
    initialLocation.value = LatLng(latitude.value, longitude.value);
    update();
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
    Timer(const Duration(seconds: 2), () async {
      var libraryPlaceResult = await MapServices().nearByPlaceDetailsAPI(
          const LatLng(21.2315, 72.8663), 16093.4.toInt(), "library");
      var parkPlaceResult = await MapServices().nearByPlaceDetailsAPI(
          const LatLng(21.2315, 72.8663), 16093.4.toInt(), "park");

      List<dynamic> placeWithinList =
          (libraryPlaceResult['results'] + parkPlaceResult['results']) as List;
      // allMarkerList.clear();
      // allMarkerList.addAll(placeWithinList);

      for (var element in placeWithinList) {
        setNearMarker(
            LatLng(element['geometry']['location']['lat'],
                element['geometry']['location']['lng']),
            element['name'],
            element['types'],
            element['business_status'] ?? 'not available',
            element['vicinity']);
      }
      addPolylineToDestination();
    });
  }

  void addPolylineToDestination() async {
    if (selectedDestination != null) {
      LatLng destinationLatLng = const LatLng(21.2212, 72.8688);
      polylines.clear();
      markers.removeWhere(
          (marker) => marker.markerId.value == AppStrings.destinationMarker);
      addCustomMarker(
        destinationLatLng,
        AppStrings.destinationMarker,
        AppStrings.destinationPoint,
        AppStrings.yourDestination,
        BitmapDescriptor.fromBytes(await getBytesFromAsset(
            path: AppIcons.locationPin2,
            height: AppSize.size44.toInt(),
            width: AppSize.size30.toInt())),
      );
      update();
    }
  }

  // Fetch ride history
  Future<void> fetchRideHistory({int page = 1, int perPage = 20}) async {
    try {
      isLoadingRides.value = true;

      final rides = await _rideService.getRideHistory(
        page: page,
        perPage: perPage,
      );

      rideHistory.value = rides;

    } catch (e) {
      String errorMessage = 'Failed to load ride history';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
    } finally {
      isLoadingRides.value = false;
    }
  }

  // Fetch active ride
  Future<void> fetchActiveRide() async {
    try {
      isLoadingActiveRide.value = true;

      final ride = await _rideService.getActiveRide();
      activeRide.value = ride;

    } catch (e) {
      // No active ride is okay
      activeRide.value = null;
    } finally {
      isLoadingActiveRide.value = false;
    }
  }

  // Get filtered rides
  List<RideModel> get filteredRides {
    if (rideFilter.value == 'all') {
      return rideHistory;
    } else if (rideFilter.value == 'active') {
      return rideHistory.where((ride) => ride.isActive).toList();
    } else if (rideFilter.value == 'cancelled') {
      return rideHistory.where((ride) => ride.isCancelled).toList();
    } else if (rideFilter.value == 'completed') {
      return rideHistory.where((ride) => ride.isCompleted).toList();
    }
    return rideHistory;
  }

  // Cancel ride
  Future<void> cancelRide(int rideId, String reason) async {
    try {
      await _rideService.cancelRide(rideId: rideId, reason: reason);
      Fluttertoast.showToast(msg: 'Ride cancelled successfully');

      // Refresh rides
      await fetchRideHistory();
      await fetchActiveRide();

    } catch (e) {
      String errorMessage = 'Failed to cancel ride';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
    }
  }

  // Rate ride
  Future<void> rateRide(int rideId, int rating, String? comment) async {
    try {
      await _rideService.rateRide(
        rideId: rideId,
        rating: rating,
        comment: comment,
      );
      Fluttertoast.showToast(msg: 'Thanks for your feedback!');

      // Refresh rides
      await fetchRideHistory();

    } catch (e) {
      String errorMessage = 'Failed to submit rating';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
    }
  }

  // Update markers for a specific ride
  Future<void> updateMarkersForRide({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    double? driverLat,
    double? driverLng,
  }) async {
    markers.clear();

    // Add pickup marker (BIGGER SIZE) - Same green icon as select route screen
    addCustomMarker(
      LatLng(pickupLat, pickupLng),
      'pickup_marker',
      'Pickup',
      'Pickup Location',
      BitmapDescriptor.fromBytes(await getBytesFromAsset(
        path: 'assets/icons/pickup_marker.png',
        height: 150,
        width: 150,
      )),
    );

    // Add dropoff marker (BIGGER SIZE) - Same red icon as select route screen
    addCustomMarker(
      LatLng(dropoffLat, dropoffLng),
      'dropoff_marker',
      'Dropoff',
      'Dropoff Location',
      BitmapDescriptor.fromBytes(await getBytesFromAsset(
        path: 'assets/icons/destination_marker.png',
        height: 120,
        width: 120,
      )),
    );

    // Add driver marker if location is available (BIGGER SIZE)
    if (driverLat != null && driverLng != null) {
      addCustomMarker(
        LatLng(driverLat, driverLng),
        'driver_marker',
        'Driver',
        'Driver Location',
        BitmapDescriptor.fromBytes(await getBytesFromAsset(
          path: AppIcons.carIcon,
          height: 135,
          width: 135,
        )),
      );
    }

    // Move camera to show all markers
    if (myMapController != null) {
      List<double> latitudes = [pickupLat, dropoffLat];
      List<double> longitudes = [pickupLng, dropoffLng];

      if (driverLat != null && driverLng != null) {
        latitudes.add(driverLat);
        longitudes.add(driverLng);
      }

      final bounds = LatLngBounds(
        southwest: LatLng(
          latitudes.reduce((a, b) => a < b ? a : b),
          longitudes.reduce((a, b) => a < b ? a : b),
        ),
        northeast: LatLng(
          latitudes.reduce((a, b) => a > b ? a : b),
          longitudes.reduce((a, b) => a > b ? a : b),
        ),
      );
      myMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }

    update();
  }

  // Draw polyline from driver to pickup (FREE - using OSRM API)
  Future<void> drawPolylineToPickup({
    required double driverLat,
    required double driverLng,
    required double pickupLat,
    required double pickupLng,
  }) async {
    try {
      polylines.clear();

      // Use OSRM (OpenStreetMap Routing Machine) - 100% FREE, no API key needed
      final url = 'https://router.project-osrm.org/route/v1/driving/$driverLng,$driverLat;$pickupLng,$pickupLat?overview=full&geometries=geojson';

      debugPrint('🚗 Fetching route from OSRM...');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry']['coordinates'] as List;

          List<LatLng> polylineCoordinates = [];
          for (var coord in geometry) {
            polylineCoordinates.add(LatLng(coord[1], coord[0])); // Note: OSRM returns [lng, lat]
          }

          polylines.add(
            Polyline(
              polylineId: const PolylineId('driver_to_pickup'),
              points: polylineCoordinates,
              color: const Color(0xFF4285F4), // Google Maps Blue
              width: 5,
            ),
          );

          showPolyline.value = true;
          update();

          debugPrint('✅ Road-following polyline drawn (${polylineCoordinates.length} points)');
        } else {
          debugPrint('⚠️ No route found, falling back to straight line');
          _drawStraightLine(driverLat, driverLng, pickupLat, pickupLng);
        }
      } else {
        debugPrint('⚠️ OSRM API error, falling back to straight line');
        _drawStraightLine(driverLat, driverLng, pickupLat, pickupLng);
      }
    } catch (e) {
      debugPrint('❌ Error drawing polyline: $e, falling back to straight line');
      _drawStraightLine(driverLat, driverLng, pickupLat, pickupLng);
    }
  }

  // Fallback: draw simple straight line if OSRM fails
  void _drawStraightLine(double driverLat, double driverLng, double pickupLat, double pickupLng) {
    polylines.clear();

    polylines.add(
      Polyline(
        polylineId: const PolylineId('driver_to_pickup'),
        points: [
          LatLng(driverLat, driverLng),
          LatLng(pickupLat, pickupLng),
        ],
        color: const Color(0xFF4285F4), // Google Maps Blue
        width: 5,
      ),
    );

    showPolyline.value = true;
    update();
    debugPrint('✅ Straight line polyline drawn');
  }

  // Draw polyline from pickup to dropoff (FREE - using OSRM API)
  Future<void> drawPolylineFromPickupToDropoff({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    try {
      polylines.clear();

      // Use OSRM (OpenStreetMap Routing Machine) - 100% FREE, no API key needed
      final url = 'https://router.project-osrm.org/route/v1/driving/$pickupLng,$pickupLat;$dropoffLng,$dropoffLat?overview=full&geometries=geojson';

      debugPrint('🚗 Fetching route from pickup to dropoff using OSRM...');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry']['coordinates'] as List;

          List<LatLng> polylineCoordinates = [];
          for (var coord in geometry) {
            polylineCoordinates.add(LatLng(coord[1], coord[0])); // Note: OSRM returns [lng, lat]
          }

          polylines.add(
            Polyline(
              polylineId: const PolylineId('pickup_to_dropoff'),
              points: polylineCoordinates,
              color: AppColors.primaryColor, // Use app primary color
              width: 5,
            ),
          );

          // Auto-fit camera to show entire route
          final bounds = LatLngBounds(
            southwest: LatLng(
              pickupLat < dropoffLat ? pickupLat : dropoffLat,
              pickupLng < dropoffLng ? pickupLng : dropoffLng,
            ),
            northeast: LatLng(
              pickupLat > dropoffLat ? pickupLat : dropoffLat,
              pickupLng > dropoffLng ? pickupLng : dropoffLng,
            ),
          );

          myMapController?.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 100),
          );

          showPolyline.value = true;
          update();

          debugPrint('✅ Pickup to dropoff polyline drawn (${polylineCoordinates.length} points)');
        } else {
          debugPrint('⚠️ No route found, falling back to straight line');
          _drawStraightLinePickupToDropoff(pickupLat, pickupLng, dropoffLat, dropoffLng);
        }
      } else {
        debugPrint('⚠️ OSRM API error, falling back to straight line');
        _drawStraightLinePickupToDropoff(pickupLat, pickupLng, dropoffLat, dropoffLng);
      }
    } catch (e) {
      debugPrint('❌ Error drawing polyline: $e, falling back to straight line');
      _drawStraightLinePickupToDropoff(pickupLat, pickupLng, dropoffLat, dropoffLng);
    }
  }

  // Fallback: draw simple straight line from pickup to dropoff if OSRM fails
  void _drawStraightLinePickupToDropoff(double pickupLat, double pickupLng, double dropoffLat, double dropoffLng) {
    polylines.clear();

    polylines.add(
      Polyline(
        polylineId: const PolylineId('pickup_to_dropoff'),
        points: [
          LatLng(pickupLat, pickupLng),
          LatLng(dropoffLat, dropoffLng),
        ],
        color: AppColors.primaryColor,
        width: 5,
      ),
    );

    showPolyline.value = true;
    update();
    debugPrint('✅ Straight line polyline drawn from pickup to dropoff');
  }
}
