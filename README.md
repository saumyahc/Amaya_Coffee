
# Amaya Coffee

A modern Flutter app for browsing a premium coffee collection, authenticating users, and managing orders with a cart and user profiles. Built with Firebase and modular architecture for maintainability and scalability.

---

## Features

- **Animated Splash Screen**  
	Welcomes users with a smooth, branded animation.

- **Authentication**  
	- Email/password sign up and login (Firebase Auth)
	- Username required at registration, stored in Firestore
	- Persistent login (auto-login if already authenticated)

- **User Profiles**  
	- Each user has a Firestore document (`users/<uid>`) with:
		- `username`
		- `orders` (list of coffee order details)
		- `createdAt` (timestamp)

- **Coffee Catalog**  
	- Coffees loaded from Firestore (`coffees` collection)
	- Each coffee: id, name, description, image, ingredients

- **Cart System**  
	- Add/remove coffees to cart
	- Quantity controls
	- Cart badge in app bar
	- Cart page for review and checkout

- **Order Management**  
	- Orders can be appended to user profile (extensible for future checkout logic)

- **Modular Codebase**  
	- `models/`: Data models (Coffee, Cart, UserProfile)
	- `services/`: Business logic (CoffeeService, UserService)
	- `pages/`: UI screens (Splash, Login, Registration, Home, Cart)

---

## Project Structure

```
lib/
	cart_page.dart                # Legacy cart page (migrated to pages/)
	firebase_options.dart         # Firebase config (FlutterFire CLI)
	home_page.dart                # Legacy home page (migrated to pages/)
	main.dart                     # App entry, routing, Provider setup
	models/
		cart.dart                   # Cart model (Provider)
		coffee.dart                 # Coffee model
		user_profile.dart           # User profile model
	pages/
		cart_page.dart              # Cart screen
		home_page.dart              # Coffee catalog screen
		login_page.dart             # Login screen
		registration_page.dart      # Registration screen (username required)
		splash_page.dart            # Splash screen
	services/
		coffee_service.dart         # Firestore coffee queries
		user_service.dart           # Firestore user profile management
```

---

## Setup

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK (included with Flutter)
- Firebase project (Auth + Firestore enabled)

### Installation

1. **Clone the repository**
	 ```sh
	 git clone https://github.com/saumyahc/Amaya_Coffee.git
	 cd Amaya_Coffee
	 ```

2. **Install dependencies**
	 ```sh
	 flutter pub get
	 ```

3. **Firebase configuration**
	 - Generate `firebase_options.dart` using [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
	 - Place `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` in respective folders

4. **Firestore setup**
	 - Create a `coffees` collection with documents:
		 - `id` (int)
		 - `name` (string)
		 - `description` (string)
		 - `image` (string URL)
		 - `ingredients` (array of strings)
	 - Users will be added automatically to the `users` collection on registration

---

## Usage

### Running the App

```sh
flutter run
```
Select your device (Android, iOS, web, desktop).

### Authentication Flow

- New users register with email, password, and username
- On registration, a Firestore user profile is created (`users/<uid>`)
- Login persists across app restarts

### Cart & Orders

- Add coffees to cart from the home page
- Review and adjust cart items in the cart page
- (Checkout logic is stubbed; orders can be appended to user profile for future extension)

---

## Extending the App

- **Google Sign-In**: Enable in Firebase Console, add `google_sign_in` package, and wire with `firebase_auth`
- **Order History**: Use `UserService.appendOrder` to save completed orders
- **Profile Editing**: Add a page to update username or other profile fields
- **Admin Panel**: Add Firestore rules and UI for managing coffee catalog

---

## Troubleshooting

- **AnimationController disposed**: Guard with `if (!mounted) return;` before calling `forward()` after delays
- **keytool not found**: Use full JDK path for SHA-1 generation
- **Login not persistent**: Ensure Firebase is initialized before `runApp` and auth state is observed

---

## License

Private project (no license specified).

---

## Credits

Developed by [saumyahc](https://github.com/saumyahc)  
Powered by Flutter & Firebase
