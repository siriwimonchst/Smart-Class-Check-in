# Smart Class Check-in & Learning Reflection App 🎓

A mobile application designed for university students to **Check-in to Class** and perform **Post-Class Learning Reflection**. The app validates student identity and physical presence using GPS location, QR Code scanning, and photo capture verification.

Built with a **Formal Soft UI** aesthetic—featuring a clean, professional, yet approachable design with a pearl-white background, pill-shaped buttons, and the Nunito font. It fully supports complete bilingual capability (English UK / Thai) that updates instantly without restarting.

---

## 🚀 Key Features

1. **Student Profile System**
   - Setup and edit Full Name and Student ID at any time.
   - Profile data is automatically attached to every check-in and reflection submission.

2. **Bilingual Support (EN / TH)**
   - Toggle instantly between **English (UK)** and **ภาษาไทย** via the globe icon on the home screen.
   - System-wide text translation applied immediately without requiring an app reload.

3. **Check-in to Class (Before Class)**
   - **Step 1:** Retrieve and verify current GPS Location (Latitude/Longitude).
   - **Step 2:** Scan the class QR Code and capture a verification photo (using the device camera).
   - **Step 3:** Record the *Previous Class Topic*, the *Expected Topic Today*, and select the current *Mood* (on a formal 1-5 scale).

4. **Finish Class / Post-Class Reflection (After Class)**
   - Follows a similar identity verification process (GPS + QR + Photo).
   - **Learning Reflection:** Students summarize what they learned in the session and provide feedback or suggestions for the instructor.

5. **History Panel**
   - View all past Check-in and Finish Class records (sorted newest first).
   - Displays a summary containing the student's name, timestamp, mood status, and a photo thumbnail.

---

## 🛠️ Tech Stack

*   **Framework:** [Flutter](https://flutter.dev/) (SDK >= 3.0.0)
*   **Language:** Dart
*   **Design System:** Material Design 3, Google Fonts (Nunito)
*   **Hardware / Sensors:**
    *   `geolocator:` to fetch GPS coordinates.
    *   `mobile_scanner:` to handle QR Code scanning.
    *   `image_picker:` to capture attendance photos via the camera.
*   **Local Storage:**
    *   `shared_preferences:` to persistently store the student profile, language preference, and history records locally as JSON.
*   **External Integration:** Configured with `firebase_core` for future backend expansion.

---

## 📂 Project Structure

```
lib/
├── i18n/
│   └── app_strings.dart          // Bilingual string resources (EN/TH)
├── models/
│   └── checkin_model.dart        // Data models (CheckinRecord, FinishClassRecord)
├── screens/
│   ├── home_screen.dart          // Main menu with 3 navigation cards
│   ├── checkin_screen.dart       // Check-in (Before Class) form screen
│   ├── finish_class_screen.dart  // Finish Class (After Class) form screen
│   └── history_screen.dart       // History list with photo thumbnails
├── services/
│   └── storage_service.dart      // JSON serialization service using SharedPreferences
├── widgets/
│   └── shared_widgets.dart       // Reusable UI (StepCard, QrScannerScreen, FormalButton)
└── main.dart                     // Application entry point, Theme config, and State Root
```

---

## 💻 Getting Started

### Prerequisites
1. Installed **Flutter SDK** (Verify via `flutter --version`).
2. A physical device (recommended for proper GPS and Camera hardware access) or an Emulator configured with virtual location and a simulated camera.

### Installation Steps
1. Clone or open the project in your IDE (VS Code / Android Studio).
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application on your connected device or emulator:
   ```bash
   flutter run
   ```

---

## 🔐 Permissions
The application requires the following device permissions to function correctly. You must grant them when prompted on a physical device:
*   **Location:** (Foreground/Background) required by `geolocator` to capture check-in coordinates.
*   **Camera:** required by `mobile_scanner` (for reading QR codes) and `image_picker` (for capturing photos).
*   **Storage (Photo Library / Media):** Used by `image_picker` to handle images captured and processed by the system.
