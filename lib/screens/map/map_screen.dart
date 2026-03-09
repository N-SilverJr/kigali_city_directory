import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/place_provider.dart';
import '../../models/place_model.dart';
import '../home/place_detail_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController mapController = MapController();
  String? _selectedPlaceId;

  // Kigali coordinates
  static const LatLng _kigaliCenter = LatLng(-1.9536, 29.8739);

  void _showPlaceBottomSheet(Place place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Place image
                if (place.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      place.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(place.category),
                    ),
                  )
                else
                  _buildPlaceholder(place.category),
                const SizedBox(height: 16),
                // Place name
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Category
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    place.category,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Address
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: place.address,
                ),
                const SizedBox(height: 12),
                // Phone
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: place.phone,
                ),
                if (place.email != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: place.email!,
                  ),
                ],
                if (place.website != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.language_outlined,
                    label: 'Website',
                    value: place.website!,
                  ),
                ],
                const SizedBox(height: 16),
                // Description
                if (place.description.isNotEmpty) ...[
                  Text('About', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 16),
                ],
                // View Details button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailScreen(place: place),
                        ),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String category) {
    IconData icon;
    switch (category) {
      case 'Restaurant':
        icon = Icons.restaurant;
        break;
      case 'Hotel':
        icon = Icons.hotel;
        break;
      case 'Shopping':
        icon = Icons.shopping_bag;
        break;
      case 'Entertainment':
        icon = Icons.movie;
        break;
      case 'Healthcare':
        icon = Icons.local_hospital;
        break;
      case 'Education':
        icon = Icons.school;
        break;
      case 'Transport':
        icon = Icons.directions_bus;
        break;
      case 'Government':
        icon = Icons.account_balance;
        break;
      case 'Bank':
        icon = Icons.account_balance;
        break;
      default:
        icon = Icons.place;
    }

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Icon(icon, size: 50, color: Colors.grey[500])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(allPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Places Map'),
        centerTitle: true,
        elevation: 0,
      ),
      body: placesAsync.when(
        data: (places) {
          final markers = _createMarkers(places);

          return FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _kigaliCenter,
              initialZoom: 12.0,
              minZoom: 8.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.kigali_city_directory',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Error loading map: $error'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'map_fab',
        onPressed: () {
          mapController.move(_kigaliCenter, 12.0);
        },
        tooltip: 'Center on Kigali',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  List<Marker> _createMarkers(List<Place> places) {
    return places
        .where((place) => place.latitude != null && place.longitude != null)
        .map((place) {
          return Marker(
            point: LatLng(place.latitude!, place.longitude!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlaceId = place.id;
                });
                _showPlaceBottomSheet(place);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedPlaceId == place.id
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(place.category),
                  color: _selectedPlaceId == place.id
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
            ),
          );
        })
        .toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Restaurant':
        return Icons.restaurant;
      case 'Hotel':
        return Icons.hotel;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Education':
        return Icons.school;
      case 'Transport':
        return Icons.directions_bus;
      case 'Government':
        return Icons.account_balance;
      case 'Bank':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }
}
