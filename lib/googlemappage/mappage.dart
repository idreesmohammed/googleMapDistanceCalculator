import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math';
import '../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _googleMapController;
  final l = Logger();
  final startAddressController = TextEditingController();
  Future<Position> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {}
    }

    return await Geolocator.getCurrentPosition();
  }

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  var geo;
  bool isDisable = false;
  Placemark? place;
  Placemark? place2;
  Set<Marker> markers = {};
  var marker;
  var destinationMarker;
  var lati;
  var longi;
  var marker2;
  var result;
  var initialCameraPosition;
  @override
  void initState() {
    geoLocator();

    _determinePosition();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    initialCameraPosition =
        CameraPosition(target: LatLng(geo.latitude, geo.longitude), zoom: 14.0);
    return Scaffold(
        body: marker == null || geo.latitude == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: GoogleMap(
                        polylines: Set<Polyline>.of(polylines.values),
                        buildingsEnabled: true,
                        onTap: (latLong) {
                          l.w(latLong.latitude);
                          fromTapLocation(latLong.latitude, latLong.longitude);
                          getPolyline();
                          getAddressDestination(
                              lat: latLong.latitude, long: latLong.longitude);
                          setState(() {
                            result = null;
                          });
                          setState(() {});
                        },
                        initialCameraPosition: initialCameraPosition,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          _googleMapController = controller;
                        },
                        markers: marker2 == null ? {marker} : markers,
                      )),
                  Positioned(
                    top: height * 0.6,
                    child: Container(
                      decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 5.0,
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(60),
                            topLeft: Radius.circular(60),
                          )),
                      height: height * 0.4,
                      width: width,
                      //color: Colors.blue,
                    ),
                  ),
                  Positioned(
                    bottom: height * 0.3,
                    left: width * 0.09,
                    child: Card(
                      shadowColor: Colors.grey,
                      elevation: 12,
                      child: SizedBox(
                        height: height * 0.07,
                        width: width * 0.82,
                        //color: Colors.green,
                        child: Row(
                          children: [
                            SizedBox(
                              width: width * 0.07,
                            ),
                            Container(
                                alignment: Alignment.centerLeft,
                                height: height * 0.05,
                                width: width * 0.47,
                                //color: Colors.red,
                                child: Text(
                                  "${Constants.name} , ${Constants.street}, ${Constants.locality}",
                                  style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: Colors.black)),
                                )),
                            SizedBox(
                              width: width * 0.13,
                            ),
                            const Icon(Icons.location_on_outlined)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: height * 0.21,
                    left: width * 0.09,
                    child: Card(
                      shadowColor: Colors.grey,
                      elevation: 12,
                      child: SizedBox(
                        height: height * 0.07,
                        width: width * 0.82,
                        //color: Colors.grey,
                        child: Row(
                          children: [
                            SizedBox(
                              width: width * 0.07,
                            ),
                            Container(
                                alignment: Alignment.centerLeft,
                                height: height * 0.05,
                                width: width * 0.55,
                                //color: Colors.red,
                                child: Constants.locality2 == ""
                                    ? Text(
                                        Constants.chooseAnyDestination,
                                        style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                                color: Colors.grey)),
                                      )
                                    : Text(
                                        "${Constants.name2} , ${Constants.street2}, ${Constants.locality2}",
                                        style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: Colors.black)),
                                      )),
                            SizedBox(
                              width: width * 0.1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: height * 0.13,
                      left: width * 0.09,
                      child: Row(
                        children: [
                          SizedBox(
                            width: width * 0.2,
                          ),
                          Text(
                            Constants.distanceText,
                            style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: Colors.black)),
                          ),
                          SizedBox(
                            width: width * 0.01,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            height: height * 0.05,
                            width: width * 0.5,
                            //color: Colors.red,
                            child: result == null
                                ? const Text("")
                                : Text(
                                    "${result.toString().substring(0, 4)} Kms",
                                    style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black)),
                                  ),
                          ),
                        ],
                      )),
                  Positioned(
                      bottom: height * 0.04,
                      left: width * 0.25,
                      child: SizedBox(
                          //color: Colors.red,
                          width: width * 0.5,
                          child: InkWell(
                            onTap: () {
                              if (Constants.locality2 == "") {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      Constants.pleaseSelectTheDestination),
                                ));
                                // return null;
                              } else {
                                setState(() {
                                  calculateDistance(
                                      geo.latitude,
                                      geo.longitude,
                                      Constants.fromTapLat,
                                      Constants.fromTapLong);
                                });
                              }
                            },
                            child: Constants.locality2 == ""
                                ? Container(
                                    alignment: Alignment.center,
                                    height: height * 0.06,
                                    width: width * 0.85,
                                    decoration: const BoxDecoration(
                                        color: Color(0xffD2FAEC),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                      Constants.submit,
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.grey),
                                      ),
                                    ))
                                : Card(
                                    elevation: 10,
                                    child: Container(
                                        alignment: Alignment.center,
                                        height: height * 0.06,
                                        width: width * 0.85,
                                        decoration: const BoxDecoration(
                                          color: Color(0xffD2FAEC),
                                        ),
                                        child: Text(
                                          Constants.submit,
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        )),
                                  ),
                          )))
                ],
              ));
  }

  fromTapLocation(lat, long) {
    l.w(long);
    marker2 = Marker(
        markerId: MarkerId("marker2"),
        position: LatLng(lat, long),
        icon: BitmapDescriptor.defaultMarker);
    setState(() {
      markers.add(marker2);
      Constants.fromTapLat = lat;
      Constants.fromTapLong = long;
      markers.add(marker2);
    });
  }

  void getPolyline() async {
    l.w(geo.latitude);
    l.wtf(Constants.fromTapLong);
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants.apiKey,
      PointLatLng(geo.latitude, geo.longitude),
      PointLatLng((Constants.fromTapLat), (Constants.fromTapLong)),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      return null;
    }
    addPolyLine(polylineCoordinates);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    l.w(lat1);
    l.w(lon1);
    l.w(lat2);
    l.w(lon2);
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    l.w(12742 * asin(sqrt(a)));
    result = 12742 * asin(sqrt(a));
    return 12742 * asin(sqrt(a));
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("");
    Polyline polyline = Polyline(
      color: Colors.black,
      polylineId: id,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  geoLocator() async {
    Geolocator.getCurrentPosition().then((value) async {
      setState(() {
        l.e(value);
        lati = value.latitude;
        longi = value.longitude;
        geo = value;
        l.wtf(value.latitude);
      });
      Future.delayed(const Duration(seconds: 2), () {
        getAddress(lat: value.latitude, long: value.longitude);
        setState(() {
          marker = Marker(
              icon: BitmapDescriptor.defaultMarker,
              markerId: MarkerId("marker"),
              position: LatLng(geo.latitude, geo.longitude));
          markers.add(marker);
        });
      });
    });
  }

  getAddress({lat, long}) async {
    l.w(lat);
    l.w(long);
    List<Placemark> placeMarks = await placemarkFromCoordinates(lat, long);
    place = placeMarks[0];
    l.wtf(place);
    setState(() {
      Constants.country = place!.country.toString();
      Constants.name = place!.name.toString();
      Constants.street = place!.street.toString();
      Constants.postalCode = place!.postalCode.toString();
      Constants.locality = place!.locality.toString();
      Constants.subAdministrative = place!.subAdministrativeArea.toString();
    });
  }

  getAddressDestination({lat, long}) async {
    List<Placemark> placeMarks2 = await placemarkFromCoordinates(lat, long);
    place2 = placeMarks2[0];
    l.wtf(place2);
    setState(() {
      Constants.country2 = place!.country.toString();
      Constants.name2 = place2!.name.toString();
      Constants.street2 = place2!.street.toString();
      Constants.postalCode2 = place2!.postalCode.toString();
      Constants.locality2 = place2!.locality.toString();
      Constants.subAdministrative2 = place2!.subAdministrativeArea.toString();
    });
  }
}
