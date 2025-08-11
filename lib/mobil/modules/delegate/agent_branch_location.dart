import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class AgentBranchLocation extends StatefulWidget {
  const AgentBranchLocation({Key? key}) : super(key: key);

  @override
  _AgentBranchLocationState createState() => _AgentBranchLocationState();
}

class _AgentBranchLocationState extends State<AgentBranchLocation> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  Position? _currentPosition;
  bool _showAgentLocation = false;

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  // List of branch locations
  final List<Branch> _branches = [
    Branch(
      name: 'الفرع الرئيسي',
      latitude: 13.965736,
      longitude: 44.1633493,
      address: '‘إب, جولة العدين',
    ),
    Branch(
      name: 'الفرع الشمالي',
      latitude: 15.3426189,
      longitude: 44.1910388,
      address: 'صنعاء , شارع الزبيري',
    ),
    Branch(
      name: 'فرع الجنوبي',
      latitude: 13.6097216,
      longitude: 44.0991859,
      address: 'تعز ,الحوبان ,خط عدن',
    ),
    Branch(
      name: 'فرع الجنوبي2',
      latitude: 14.534008,
      longitude: 49.1115337,
      address: 'المكلاء,حي باعبود',
    ),
  ];

  void _addMarkers() {
    _markers.clear();
    for (var branch in _branches) {
      _markers.add(
        Marker(
          point: LatLng(branch.latitude, branch.longitude),
          width: 60,
          height: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 30),
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      spreadRadius: 1,
                    )
                  ],
                ),
                constraints: BoxConstraints(maxWidth: 80),
                child: Text(
                  branch.name,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_showAgentLocation && _currentPosition != null) {
      _markers.add(

        Marker(

          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 60,
          height: 60,

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_pin_circle, color: Colors.blue, size: 30),
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      spreadRadius: 1,
                    )
                  ],
                ),
                constraints: BoxConstraints(maxWidth: 80),
                child: Text(
                  'موقعك الحالي',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _goToLocation(double latitude, double longitude) {
    _mapController.move(
      LatLng(latitude, longitude),
      13,
    );
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خدمة الموقع معطلة. يرجى تفعيلها')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفض إذن الوصول للموقع')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفض إذن الوصول للموقع بشكل دائم')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      if (_showAgentLocation) {
        _addMarkers();
      }
    });
    _goToLocation(position.latitude, position.longitude);
  }

  void _toggleAgentLocation(bool value) {
    setState(() {
      _showAgentLocation = value;
      _addMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'AgentLocation',
        backgroundColor: Colors.orange,
        child: Icon(_showAgentLocation ? Icons.location_on : Icons.location_off),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('عرض موقع المندوب'),
                            CupertinoSwitch(
                              value: _showAgentLocation,
                              onChanged: (value) {
                                _toggleAgentLocation(value);
                                Navigator.pop(context);
                              },
                              activeColor: Colors.orange,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          _showAgentLocation
                              ? 'سيتم عرض موقعك الحالي على الخريطة'
                              : 'سيتم إخفاء موقعك الحالي من الخريطة',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(_branches.first.latitude, _branches.first.longitude),
              zoom: 10.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: getCurrentLocation,
              icon: Icon(Icons.my_location),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.all(10),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _branches.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _goToLocation(
                          _branches[index].latitude,
                          _branches[index].longitude,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange,
                        padding: EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _branches[index].name,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _branches[index].address,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Branch {
  final String name;
  final double latitude;
  final double longitude;
  final String address;

  Branch({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}