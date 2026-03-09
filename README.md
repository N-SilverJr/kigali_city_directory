# Kigali City Directory

A comprehensive mobile application for discovering and managing places in Kigali, Rwanda. Built with Flutter and powered by Firebase, this app serves as a digital directory for businesses, attractions, services, and points of interest in the city.

## Features

### 🔐 User Authentication
- Secure sign-in and sign-up with Firebase Authentication
- Email verification and password recovery
- User profile management with display name and photo

### 🏢 Place Directory
- Browse a curated list of places in Kigali
- Filter places by categories (restaurants, hotels, shops, etc.)
- Featured places highlighting popular spots
- Detailed place information including:
  - Name, description, and category
  - Contact information (phone, email, website)
  - Physical address
  - Location coordinates for mapping
  - Images and tags

### 🗺️ Interactive Map
- Visualize all places on an interactive map
- Powered by Flutter Map with OpenStreetMap tiles
- Tap on map markers to view place details
- Get directions using integrated map services

### 👤 Personal Listings
- Create and manage your own place listings
- Edit existing listings with real-time updates
- Track listings created by you
- Mark places as featured (admin feature)

### 📍 Location Services
- Integrated geolocation using Geolocator
- Find places near your current location
- GPS-based navigation assistance

### ⚙️ Settings & Preferences
- Customize app appearance and behavior
- Notification preferences
- Account management options

### 🔄 Real-time Updates
- Live synchronization with Firebase Firestore
- Instant updates across all users
- Offline-capable data caching

## Getting Started

### Prerequisites

- Flutter SDK (^3.10.8)
- Dart SDK (^3.10.8)
- Firebase project with Firestore and Authentication enabled
- Android Studio or VS Code with Flutter extensions

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/kigali-city-directory.git
   cd kigali-city-directory
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Firestore Database and Authentication
   - Download `google-services.json` for Android and place it in `android/app/`
   - Configure Firebase options in `lib/firebase_options.dart`

4. **Run the app:**
   ```bash
   flutter run
   ```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/
│   ├── place_model.dart      # Place data model
│   └── user_model.dart       # User data model
├── providers/                # Riverpod state management
├── screens/
│   ├── auth/                 # Authentication screens
│   ├── home/                 # Directory home screen
│   ├── listings/             # User listings management
│   ├── map/                  # Interactive map view
│   ├── profile/              # User profile screen
│   └── settings/             # App settings
├── services/
│   ├── auth_service.dart     # Firebase Auth service
│   └── place_service.dart    # Firestore place operations
└── widgets/                  # Reusable UI components
```

## Dependencies

### Core Dependencies
- **firebase_core**: Firebase initialization
- **firebase_auth**: User authentication
- **cloud_firestore**: NoSQL database
- **flutter_riverpod**: State management
- **flutter_map**: Interactive maps
- **geolocator**: GPS location services
- **url_launcher**: External link handling
- **dio**: HTTP client for API calls

### Development Dependencies
- **flutter_test**: Unit and widget testing

## API Reference

### PlaceService
- `getAllPlaces()`: Stream of all places
- `getPlacesByCategory(category)`: Places filtered by category
- `getFeaturedPlaces()`: Featured places only
- `getUserPlaces(userId)`: Places created by specific user
- `addPlace(place)`: Create new place listing
- `updatePlace(id, data)`: Update existing place
- `deletePlace(id)`: Remove place listing

### AuthService
- `signIn(email, password)`: User sign-in
- `signUp(email, password)`: User registration
- `signOut()`: User logout
- `getCurrentUser()`: Current user stream

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Flutter's [effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter format` for code formatting
- Run `flutter analyze` to check for issues
## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
