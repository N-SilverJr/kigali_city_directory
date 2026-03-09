import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import '../../models/place_model.dart';

class MapDirectionsScreen extends StatefulWidget {
  final Place place;
  const MapDirectionsScreen({super.key, required this.place});

  @override
  State<MapDirectionsScreen> createState() => _MapDirectionsScreenState();
}

class _MapDirectionsScreenState extends State<MapDirectionsScreen> {
  late final MapController _mapController;
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  bool _loadingLocation = true;
  bool _loadingRoute = false;
  String? _errorMessage;
  String? _distanceText;
  String? _durationText;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocationAndRoute();
  }

  Future<void> _initLocationAndRoute() async {
    await _getCurrentLocation();
    if (_currentLocation != null) {
      await _fetchRoute();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _loadingLocation = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permission permanently denied. Enable it in settings.';
          _loadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _loadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not get location: $e';
        _loadingLocation = false;
      });
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentLocation == null ||
        widget.place.latitude == null ||
        widget.place.longitude == null)
      return;

    setState(() => _loadingRoute = true);

    try {
      final origin = _currentLocation!;
      final dest = LatLng(widget.place.latitude!, widget.place.longitude!);

      // OSRM - completely free, no API key
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${dest.longitude},${dest.latitude}'
          '?overview=full&geometries=geojson';

      final response = await Dio().get(url);
      final data = response.data;

      if (data['code'] == 'Ok') {
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        final points = coords
            .map(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
            )
            .toList();

        final distance = data['routes'][0]['distance'] as num; // meters
        final duration = data['routes'][0]['duration'] as num; // seconds

        setState(() {
          _routePoints = points;
          _distanceText = distance >= 1000
              ? '${(distance / 1000).toStringAsFixed(1)} km'
              : '${distance.toInt()} m';
          _durationText = duration >= 3600
              ? '${(duration / 3600).toStringAsFixed(1)} hr'
              : '${(duration / 60).toInt()} min';
          _loadingRoute = false;
        });

        // Fit map to show full route
        final bounds = LatLngBounds.fromPoints([origin, dest, ...points]);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
        );
      }
    } catch (e) {
      setState(() => _loadingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCoords =
        widget.place.latitude != null && widget.place.longitude != null;
    final destination = hasCoords
        ? LatLng(widget.place.latitude!, widget.place.longitude!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: !hasCoords
          ? const Center(
              child: Text('No coordinates available for this place.'),
            )
          : _loadingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                          _loadingLocation = true;
                        });
                        _initLocationAndRoute();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: destination!,
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.yourcompany.yourapp',
                    ),
                    // Route line
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 5,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // Current location marker
                        if (_currentLocation != null)
                          Marker(
                            point: _currentLocation!,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Destination marker
                        Marker(
                          point: destination,
                          width: 50,
                          height: 60,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.place.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).primaryColor,
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Loading route indicator
                if (_loadingRoute)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Calculating route...'),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Bottom info card
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.place.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.place.address,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_distanceText != null &&
                              _durationText != null) ...[
                            const Divider(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.directions_car,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$_durationText  •  $_distanceText',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: (_currentLocation != null && destination != null)
          ? FloatingActionButton(
              onPressed: () {
                final bounds = LatLngBounds.fromPoints([
                  _currentLocation!,
                  destination,
                  ..._routePoints,
                ]);
                _mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(60),
                  ),
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.fit_screen, color: Colors.white),
            )
          : null,
    );
  }
}
