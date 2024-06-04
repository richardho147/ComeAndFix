import 'package:come_n_fix/components/input_text_field.dart';
import 'package:come_n_fix/components/loading_animation.dart';
import 'package:come_n_fix/components/top_notification.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SelectLocationPage extends StatefulWidget {
  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  LatLng? _selectedLocation;
  String _selectedLocationName = 'Tap to select location';
  LatLng? _initialLocation;
  OverlayEntry? _overlayEntry;
  final geo = GeoFlutterFire();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _onTap(LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          String streetName = placemark.thoroughfare ?? '';
          String streetNumber = placemark.subThoroughfare ?? '';
          _selectedLocationName = '$streetNumber $streetName';
        });
      } else {
        setState(() {
          _selectedLocationName = 'Unknown Location';
        });
      }
    } catch (e) {
      _showOverlayNotification('Unknown Location');
    }
  }

  void _saveLocation() async {
    if (_selectedLocation != null &&
        _addressController.text.trim().isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'location': geo.point(latitude: _selectedLocation!.latitude, longitude: _selectedLocation!.longitude).data,
          'address': _addressController.text.trim(),
        }, SetOptions(merge: true));
        Navigator.pop(context);
      }
    } else if (_selectedLocation == null &&
        _addressController.text.trim().isNotEmpty) {
      _showOverlayNotification('No location selected!');
    } else if (_selectedLocation != null &&
        _addressController.text.trim().isEmpty) {
      _showOverlayNotification('No Address is provided!');
    } else {
      _showOverlayNotification('No location and address provided');
    }
  }

  void _showOverlayNotification(String message) {
    _overlayEntry = _createOverlayEntry(message);
    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(Duration(seconds: 3), () {
      _overlayEntry?.remove();
    });
  }

  OverlayEntry _createOverlayEntry(String message) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + kToolbarHeight,
        left: 0,
        right: 0,
        child: TopNotification(
          message: message,
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showOverlayNotification('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showOverlayNotification('Location services are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showOverlayNotification(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialLocation = LatLng(position.latitude, position.longitude);
    });
    _onTap(LatLng(position.latitude, position.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Location',
        ),
        backgroundColor: Color.fromARGB(255, 124, 102, 89),
        foregroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: true,
      body: _initialLocation == null
          ? Center(child: LoadingAnimation())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    onTap: _onTap,
                    initialCameraPosition: CameraPosition(
                      target: _initialLocation!,
                      zoom: 15,
                    ),
                    markers: _selectedLocation != null
                        ? {
                            Marker(
                              markerId: MarkerId('selected-location'),
                              position: _selectedLocation!,
                            ),
                          }
                        : {},
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Location: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: _selectedLocationName,
                              ),
                            ],
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Address:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        InputTextField(
                            controller: _addressController,
                            hintText: "Input your full address here",
                            obscureText: false,
                            paddingSize: 0),
                        SizedBox(
                          height: 5,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _saveLocation,
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 143, 90, 38),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
