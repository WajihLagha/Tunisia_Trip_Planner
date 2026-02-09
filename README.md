# 🇹🇳 TuniWays - Smart Travel App

**Discover Tunisia. Book Stays. Rent Rides.**

**TuniWays** is a modern mobile application built with **Flutter** that helps travelers explore the beauty of Tunisia. Unlike standard travel apps, it uses **AI & Microservices** to give you "Smart Recommendations" based on real user sentiment, not just star ratings.

---

## 📱 App Overview

This is the mobile frontend for our distributed Microservices system. It connects to 6 backend services (User, Accommodation, Transport, Review, Recommendation, Notification) to provide a seamless experience.

### **✨ Key Features**

* **🏨 Smart Booking:** Browse hotels, guest houses ("Dars"), and motels with real-time availability.
* **🧠 AI-Powered Picks:** See a **"Sentiment Badge"** (e.g., *75% Positive*) on listings, powered by our Python NLP engine that reads reviews for you.
* **🚗 Transport Hub:** Rent cars or book bus tickets directly within the app.
* **🗺️ Interactive Discovery:** Explore Sousse, Tunis, and Djerba on an interactive map.
* **💬 Reviews & Ratings:** Share your experience to help train our AI model.
* **🔔 Real-Time Alerts:** Get instant booking confirmations via Email/SMS.

---

[//]: # (## 🎨 Screenshots)

[//]: # ()
[//]: # (| Home & Discovery | Smart Details | Transport Rental |)

[//]: # (|:---:|:---:|:---:|)

[//]: # (| *&#40;Place Screenshot Here&#41;* | *&#40;Place Screenshot Here&#41;* | *&#40;Place Screenshot Here&#41;* |)

[//]: # (| *AI Recommendations* | *Sentiment Analysis* | *Car & Bus Booking* |)

[//]: # ()
[//]: # (---)

## 🚀 Getting Started

Follow these simple steps to run the app on your machine.

### **Prerequisites**
* [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
* An Emulator (Android Studio) or Simulator (Xcode), or a physical device.

### **Installation**

1.  **Clone the repository**
    ```bash
    git clone [https://github.com/your-username/tounesna-mobile.git](https://github.com/your-username/tounesna-mobile.git)
    cd tounesna-mobile
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the App**
    ```bash
    flutter run
    ```

---

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **State Management:** `setState` (kept simple for MVP)
* **Navigation:** Flutter Navigator 2.0
* **Maps:** `flutter_map` (OpenStreetMap)
* **Backend Connection:** REST APIs (Spring Boot Microservices)