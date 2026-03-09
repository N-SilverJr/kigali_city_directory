import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/place_service.dart';
import '../models/place_model.dart';

final placeServiceProvider = Provider<PlaceService>((ref) {
  return PlaceService();
});

final allPlacesProvider = StreamProvider<List<Place>>((ref) {
  final placeService = ref.watch(placeServiceProvider);
  return placeService.getAllPlaces();
});

final featuredPlacesProvider = StreamProvider<List<Place>>((ref) {
  final placeService = ref.watch(placeServiceProvider);
  return placeService.getFeaturedPlaces();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final placesByCategoryProvider = StreamProvider.family<List<Place>, String>((
  ref,
  category,
) {
  final placeService = ref.watch(placeServiceProvider);
  return placeService.getPlacesByCategory(category);
});

final userListingsProvider = StreamProvider.family<List<Place>, String>((
  ref,
  userId,
) {
  final placeService = ref.watch(placeServiceProvider);
  return placeService.getUserPlaces(userId);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = StreamProvider<List<Place>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final placeService = ref.watch(placeServiceProvider);

  if (query.isEmpty) {
    return placeService.getAllPlaces();
  }
  return placeService.searchPlaces(query);
});

final selectedPlaceProvider = StateProvider<Place?>((ref) => null);
