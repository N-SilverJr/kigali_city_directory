import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_model.dart';

class PlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _placesCollection => _firestore.collection('places');

  Stream<List<Place>> getAllPlaces() {
    return _placesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Place>> getPlacesByCategory(String category) {
    return _placesCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Place>> getFeaturedPlaces() {
    return _placesCollection
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Place>> getUserPlaces(String userId) {
    return _placesCollection
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Place>> searchPlaces(String query) {
    return _placesCollection
        .orderBy('name')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList(),
        );
  }

  Future<Place?> getPlaceById(String id) async {
    try {
      DocumentSnapshot doc = await _placesCollection.doc(id).get();
      if (doc.exists) {
        return Place.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting place: $e');
    }
  }

  Future<String> addPlace(Place place) async {
    try {
      DocumentReference doc = await _placesCollection.add(place.toFirestore());
      return doc.id;
    } catch (e) {
      throw Exception('Error adding place: $e');
    }
  }

  Future<void> updatePlace(Place place) async {
    try {
      await _placesCollection.doc(place.id).update(place.toFirestore());
    } catch (e) {
      throw Exception('Error updating place: $e');
    }
  }

  Future<void> deletePlace(String id) async {
    try {
      await _placesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting place: $e');
    }
  }

  Future<void> toggleFeatured(String id, bool isFeatured) async {
    try {
      await _placesCollection.doc(id).update({'isFeatured': isFeatured});
    } catch (e) {
      throw Exception('Error updating featured status: $e');
    }
  }
}
