import 'package:dashboard/mobil/modules/screen_home/home_cubit/home_cubit.dart';
import 'package:dashboard/mobil/modules/screen_home/home_cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class MapScreen extends StatefulWidget {
  final String? trackingNumber;
  
  const MapScreen({Key? key, this.trackingNumber}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Parcel> _parcels = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  LatLng _currentLocation = const LatLng(24.7136, 46.6753); // Default to Riyadh, Saudi Arabia
  Parcel? _selectedParcel;
  
  @override
  void initState() {
    super.initState();
    print('initel Map start');

    _getCurrentLocation();
    if (widget.trackingNumber != null && widget.trackingNumber!.isNotEmpty) {
      _fetchParcelByTrackingNumber(widget.trackingNumber!);
    } else {
      _fetchAllParcels();
    }
    print('initel Map end');
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are disabled
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      
      // Center map on current location if no tracking number is provided
      if (widget.trackingNumber == null || widget.trackingNumber!.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(_currentLocation, 13.0);
          }
        });

      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchParcelByTrackingNumber(String trackingNumber) async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('parcel')
          .where('trackingNumber', isEqualTo: trackingNumber.trim())
          .limit(1)
          .get();
       print(trackingNumber.trim());
      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'لا يوجد طرد بهذا الرقم';
        });
        return;
      }

      final parcel = Parcel.fromJson(snapshot.docs.first);

      setState(() {
        _parcels = [parcel];
        _selectedParcel = parcel;
        _isLoading = false;
      });

      // Center map on parcel location if available
      if (parcel.latitude?.toDouble() != null && parcel.longitude != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(
              LatLng(parcel.latitude!.toDouble(), parcel.longitude!.toDouble()),
              15.0,
            );
          }
        });


      }
    } catch (e) {

      setState(() {
        print('00$e');
        _isLoading = false;
        _isError = true;
        _errorMessage = 'حدث خطأ أثناء جلب بيانات الطرد: $e';
      });
    }
  }

  Future<void> _fetchAllParcels() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('parcel')
          .where('latitude', isNull: false)
          .where('longitude', isNull: false)
          .limit(50)
          .get();

      if (snapshot.docs.isEmpty) {
        print(snapshot.docs);
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'لا توجد طرود متاحة حالياً';
        });
        return;
      }

      final parcels = snapshot.docs.map((doc) {
        try { final data = doc.data();
        return Parcel(
          id: doc.id,
          trackingNumber: data['trackingNumber'] ?? '',
          status: data['status'] ?? 'pending',
          shippingDate: data['shippingDate']?.toDate(),
          senderName: data['senderName'] ?? '',
          receiverName: data['receiverName'] ?? '',
          orderName: data['orderName'] ?? '',
          longitude: data['longitude']?.toDouble() ?? 0.0,
          latitude: data['latitude']?.toDouble() ?? 0.0,
          destination: data['destination'] ?? '',
          parceID: data['parceID'] ?? 0,
          receverName: data['receverName'] ?? data['receiverName'] ?? '',
          prWight: data['prWight']?.toDouble() ?? 0.0,
          noted: data['noted'],
          preType: data['preType'] ?? 'standard',
          shipmentID: data['shipmentID'],
        ); // تأكد من استخدام doc.data() بدلاً من doc
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          return null;
        }
      }).whereType<Parcel>().toList(); // إزالة أي قيم فارغة

      setState(() {
        _parcels = parcels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        print('error في جلب كل البيانا');
        _isLoading = false;
        _isError = true;
        _errorMessage = 'حدث خطأ أثناء جلب بيانات الطرود: ${e.toString()}';
      });
      print('Firestore Error: $e');
    }
  }

  Color _getMarkerColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'in_transit':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'returned':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              :
                   Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            center: _selectedParcel != null && _selectedParcel!.latitude != null
                                ? LatLng(_selectedParcel!.latitude!, _selectedParcel!.longitude!)
                                : _currentLocation,
                            zoom: 13.0,
                            maxZoom: 18.0,
                            minZoom: 3.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            MarkerLayer(
                              markers: [
                                // Current location marker
                                Marker(
                                  point: _currentLocation,
                                  width: 40,
                                  height: 40,
                                  child:  const Icon(
                                    Icons.my_location,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                ),
                                // Parcel markers
                                ..._parcels
                                    .where((parcel) => parcel.latitude != null && parcel.longitude != null)
                                    .map(
                                      (parcel) => Marker(
                                        point: LatLng(parcel.latitude!, parcel.longitude!),
                                        width: 40,
                                        height: 40,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedParcel = parcel;
                                            });
                                          },
                                          child: Icon(
                                            Icons.location_on,
                                            color: _getMarkerColor(parcel.status),
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ],
                        ),
                        // Map controls
                        Positioned(
                          right: 16,
                          bottom: 100,
                          child: Column(
                            children: [
                              FloatingActionButton(
                                heroTag: 'zoomIn',
                                mini: true,
                                child: const Icon(Icons.add),
                                onPressed: () {
                                  final currentZoom = _mapController.zoom;
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {   _mapController.move(_mapController.center, currentZoom + 1);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton(
                                heroTag: 'zoomOut',
                                mini: true,
                                child: const Icon(Icons.remove),
                                onPressed: () {
                                  final currentZoom = _mapController.zoom;
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {   _mapController.move(_mapController.center, currentZoom - 1);
                                    }
                                  });


                                },
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton(
                                heroTag: 'myLocation',
                                mini: true,
                                child: const Icon(Icons.my_location),
                                onPressed: () {
                                  _getCurrentLocation();
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      _mapController.move(_currentLocation, 15.0);
                                    }
                                  });

                                },
                              ),
                            ],
                          ),
                        ),
                        // Selected parcel info
                        if (_selectedParcel != null)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          setState(() {
                                            _selectedParcel = null;
                                          });
                                        },
                                      ),
                                      const Text(
                                        'معلومات الطرد',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(_selectedParcel!.trackingNumber),
                                      const SizedBox(width: 8),
                                      const Text(
                                        ':رقم التتبع',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(_selectedParcel!.orderName.isNotEmpty
                                          ? _selectedParcel!.orderName
                                          : 'غير محدد'),
                                      const SizedBox(width: 8),
                                      const Text(
                                        ':اسم الطلب',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(_selectedParcel!.status),
                                      const SizedBox(width: 8),
                                      const Text(
                                        ':الحالة',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(_selectedParcel!.destination ?? 'غير محدد'),
                                      const SizedBox(width: 8),
                                      const Text(
                                        ':الوجهة',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Search bar
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: 'ابحث عن رقم التتبع',
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  _fetchParcelByTrackingNumber(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}