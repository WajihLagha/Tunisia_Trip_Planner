# 🇹🇳 TuniWays - Smart Trip Planner

**Explore Tunisia. Book Stays. Rent Rides.**

**TuniWays** is a premium mobile application built with **Flutter** designed to provide a seamless travel experience across Tunisia. From discovering hidden gems in the Medina to booking luxury stays in Djerba, TuniWays integrates advanced features like real-time booking, secure payments, and AI-driven sentiment analysis to help travelers make informed decisions.

---

## 📱 Features

### 🔐 Secure Authentication & Roles
- **Keycloak Integration:** Robust authentication using JWT tokens and secure storage.
- **Role-Based Access:** Dedicated interfaces for **Users** (Travelers) and **Admins** (Management).
- **Onboarding:** Smooth introduction for new users.

### 🏨 Accommodation & Bookings
- **Smart Discovery:** Browse hotels, "Dars" (guest houses), and motels.
- **Detailed Listings:** High-quality images, amenities, and interactive room selection.
- **Booking Management:** Real-time booking requests with status tracking.

### 🚗 Transport Hub
- **Car Rentals:** Choose from a wide range of vehicles for your road trips.
- **Public Transport:** Integrated bus ticket booking.
- **Interactive Maps:** Locate services and destinations using OpenStreetMap.

### 💳 Seamless Payments
- **Stripe Integration:** Secure and fast checkout flow for all bookings.
- **Transaction History:** Keep track of all your travel expenses.

### 🎨 Premium UI/UX
- **Dynamic Theming:** Full support for **Light** and **Dark** modes.
- **Smooth Animations:** Powered by `smooth_page_indicator` and custom transitions.
- **Interactive Map:** Explore Sousse, Tunis, and more via `flutter_map`.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Cubit)
- **Networking:** [Dio](https://pub.dev/packages/dio) (with Interceptors for JWT)
- **Local Storage:** 
  - [Hive](https://pub.dev/packages/hive) (Fast NoSQL)
  - [sqflite](https://pub.dev/packages/sqflite) (Local Database)
  - [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) (Sensitive data)
- **Payments:** [flutter_stripe](https://pub.dev/packages/flutter_stripe)
- **Maps:** [flutter_map](https://pub.dev/packages/flutter_map) (Leaflet-based)
- **Notifications:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)

---

## 📂 Project Structure

```text
lib/
├── core/               # App-wide themes, notifications, and constants
├── features/           # Feature-first modules
│   ├── auth/           # Login, Onboarding, Keycloak logic
│   ├── home_layout/    # Main navigation and bottom bar
│   ├── bookings/       # Booking logic and Stripe integration
│   ├── accommodation/  # Hotels and Room details
│   ├── transport/      # Car and Bus services
│   ├── profile/        # User settings and Dark Mode
│   └── favourites/     # Saved locations
├── shared/             # Reusable widgets and network helpers (Dio, Cache)
└── main.dart           # App entry point and Provider setup
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.7.0 or higher)
- Android Studio / VS Code
- A Stripe account (for testing payments)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/WajihLagha/Tunisia_Trip_Planner.git
   cd Tunisia_Trip_Planner
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment**
   - Ensure your backend services are running.
   - Update `Stripe.publishableKey` in `lib/main.dart` if necessary.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.