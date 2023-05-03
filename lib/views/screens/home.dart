import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({Key? key}) : super(key: key);

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  final Completer<GoogleMapController> _controller = Completer();
  static LatLng sourceLocation =
      const LatLng(21.21965268156295, 72.87439546163078);
  static LatLng destination =
      const LatLng(21.240935425174243, 72.88045562217373);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  Future<void> getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then(
          (location) {},
        );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (newLoc) {
        setState(() {
          currentLocation = newLoc;
        });

        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(newLoc.latitude!, newLoc.longitude!),
            ),
          ),
        );
        setState(() {});
      },
    );
  }

  Future<void> getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      "AIzaSyCllTzWtFACvqdjqLEdrWCwa1vBysiSP7k",
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isEmpty) {
      setState(() {
        result.points.forEach(
          (PointLatLng point) => polylineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          ),
        );
      });
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      /*"assets/images/source.png"*/
      AutofillHints.addressCity,
    ).then((icon) {
      sourceIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/current.png")
        .then((icon) {
      currentLocationIcon = icon;
      super.initState();
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getPolyPoints();
    setCustomMarkerIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: (currentLocation != null)
                ? LatLng(
                    currentLocation!.latitude as double,
                    currentLocation!.longitude as double,
                  )
                : const LatLng(0, 0),
            zoom: 13.5,
          ),
          polylines: {
            Polyline(
              polylineId: const PolylineId("route"),
              points: polylineCoordinates,
              color: Colors.red,
              width: 6,
            ),
          },
          markers: {
            Marker(
              icon: currentLocationIcon,
              markerId: const MarkerId("current Location"),
              position: (currentLocation != null)
                  ? LatLng(
                      currentLocation!.latitude as double,
                      currentLocation!.longitude as double,
                    )
                  : const LatLng(0, 0),
            ),
            Marker(
              icon: sourceIcon,
              markerId: const MarkerId("source"),
              position: sourceLocation,
            ),
            Marker(
              icon: destinationIcon,
              markerId: const MarkerId("destination"),
              position: destination,
            ),
          },
          onMapCreated: (mapController) {
            _controller.complete(mapController);
          },
        ),
      ),
    );
  }
}
