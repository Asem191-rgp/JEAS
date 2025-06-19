abstract class LocationState {
  const LocationState();

  List<Object> get props => [];
}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final double lat;
  final double lon;

  const LocationLoaded({required this.lat, required this.lon});

  @override
  List<Object> get props => [lat, lon];
}

class LocationError extends LocationState {}
