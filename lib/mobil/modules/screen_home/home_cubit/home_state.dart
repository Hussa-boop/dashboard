abstract class HomeState{}
class HomeInitial extends HomeState{}
class HomeChangeTabState extends HomeState{}
class HomeLoading extends HomeState{}
class HomeQRScanned extends HomeState {
  final String qrData;
  HomeQRScanned(this.qrData);
}
class TrackingTextChanged extends HomeState {
  final String trackingNumber;
  TrackingTextChanged(this.trackingNumber);
}
class HomeSearching extends HomeState {}

class HomeSearchCompleted extends HomeState {}

class HomeSearchError extends HomeState {
  final String error;

  HomeSearchError(this.error);
}

class HomeMapTrackingUpdated extends HomeState {
  final String trackingNumber;
  HomeMapTrackingUpdated(this.trackingNumber);
}