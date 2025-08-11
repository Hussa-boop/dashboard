import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final TextEditingController trackingController = TextEditingController();
  HomeCubit() : super(HomeInitial()) {
    trackingController.addListener(onTextChanged);
  }


  void onTextChanged() {
    final text = trackingController.text;
    emit(TrackingTextChanged(text));

    if (text.length >= 3) {
      searchParcel(text);
    }
  }

  static HomeCubit get(context) => BlocProvider.of(context);
  int selectedIndex = 0;
  bool isPassword = true;

  void onItemTapped(int index) {
    selectedIndex = index;
    emit(HomeChangeTabState());
    
    // If map tab is selected and there's a tracking number, update the map
    if (index == 1 && trackingController.text.length >= 3) {
      emit(HomeMapTrackingUpdated(trackingController.text));
    }
  }

  void togglePasswordVisibility() {
    isPassword = !isPassword;
  }

  List<Parcel> searchResults = [];
  bool isSearching = false;
  bool hasSearched = false;

  Future<void> searchParcel(String trackingNumber) async {
    if (trackingNumber.isEmpty) {
      clearSearchResults();
      return;
    }

    emit(HomeSearching());
    isSearching = true;
    hasSearched = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('parcel')
          .where('trackingNumber', isEqualTo: trackingNumber.trim())
          .limit(1)
          .get();

      searchResults = snapshot.docs.map((doc) {
        final data = doc.data();
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
        );
      }).toList();

      emit(HomeSearchCompleted());
      
      // If map tab is selected, update the map with the tracking number
      if (selectedIndex == 1) {
        emit(HomeMapTrackingUpdated(trackingNumber));
      }
    } catch (e) {
      searchResults = [];
      emit(HomeSearchError(e.toString()));
    } finally {
      isSearching = false;
    }
  }

  void clearSearchResults() {
    searchResults = [];
    hasSearched = false;
    emit(HomeInitial());
  }
  
  // Method to track a parcel on the map
  void trackParcelOnMap(String trackingNumber) {
    if (trackingNumber.isNotEmpty) {
      // Switch to map tab
      selectedIndex = 1;
      emit(HomeChangeTabState());
      
      // Update tracking
      emit(HomeMapTrackingUpdated(trackingNumber));
    }
  }
}