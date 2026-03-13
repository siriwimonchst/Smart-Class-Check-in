# Product Requirements Document (PRD)

**Project Name:** Smart Class Check-in & Learning Reflection App  
**Platform:** Mobile Application (iOS & Android via Flutter)  
**Version:** 1.0 (MVP)  
**Last Updated:** March 2026  

---

## 1. Project Overview
A mobile application designed for university students to handle class attendance in a more meaningful way. Moving beyond traditional roll calls, the app integrates behavioral compliance (GPS Location / QR Scanning / Photo Capture) with emotional and cognitive engagement (Pre-class expectations, Mood tracking, and Post-class reflections).

The primary goal is to eliminate paper-based attendance, collect comprehensive evidence-based records, and foster better interaction and reflection between students and instructors.

---

## 2. Target Audience
*   **Primary Users:** University Students (Aged 18-25).
*   **Tech Savvy Level:** Medium to High (Familiar with mobile apps, camera usage, and location sharing).

---

## 3. Core Objectives
1. **Reduce Check-in Errors and Proxy Attendance:** Automatically attach the student's Name and ID to records, verified by GPS proximity, a proprietary QR Code scan, and a live photo capture.
2. **Promote Active Learning via Reflection:** Require students to formulate their expectations before class and summarize their key takeaways + provide feedback after class.
3. **Friction-less, Professional UI/UX:** Implement a "Formal Soft UI" design featuring a pearl-white background, soft shadows, and clear typography to create an intuitive, stress-free experience.
4. **Cultural & Linguistic Flexibility:** Provide seamless bilingual support (English / Thai) via a simple toggle button to accommodate international and local students alike.

---

## 4. Feature Requirements

### 4.1. App Startup & Global State
*   **State Management:** The root widget (`main.dart`) maintains the global state for Language preference (`EN`/`TH`) and Student Profile (`Full Name`, `Student ID`) via Local Storage (`SharedPreferences`).
*   **Theming Systems:** 
    *   Primary Font: `Google Fonts (Nunito)`.
    *   Color Palette: Primary = `0xFF4A3880` (Deep Purple) and Background = `0xFFF8F8FC` (Pearl White).

### 4.2. Main Navigation (Home Screen)
*   **User Info Header:** Displays the current student profile at the top right. Tapping it opens a dialog to setup/edit the Full Name and Student ID.
*   **Quick Menu Cards:** Three full-width navigation cards with distinct color gradients:
    *   **Check-in (Purple Gradient):** Navigates to the pre-class check-in flow.
    *   **Finish Class (Blue Gradient):** Navigates to the post-class reflection flow.
    *   **History (Mint Gradient):** Navigates to the timeline history of past records.
*   **Language Button:** A globe icon (🌐) in the AppBar allows real-time switching between English and Thai without reloading the app.

### 4.3. Check-in Module (Before Class)
Requires the user to complete 3 sequential steps:
*   **Step 1: Check Location:** Uses `geolocator` to fetch current Latitude/Longitude coordinates after requesting necessary permissions.
*   **Step 2: Authenticate Identity:** 
    *   Open `mobile_scanner` to scan the instructor's QR Code.
    *   Open `image_picker` (Camera) to capture a live photo for attendance verification.
*   **Step 3: Prepare Mindset (Reflection):** 
    *   Text input: *Previous Class Topic*.
    *   Text input: *Expected Topic Today*.
    *   Mood Scale: Select current mood via a numerical scale (1-5) designed for formal settings (removing informal emojis).

### 4.4. Finish Class Module (After Class)
*   **Steps 1 & 2:** Same verification process as Check-in (GPS location + QR code + Photo capture).
*   **Step 3: Output Reflection (Post-Class):**
    *   Text input: *What Did You Learn Today?* (Summary).
    *   Text input: *Class Feedback / Suggestions*.

### 4.5. History Panel Module
*   **Local Data Fetching:** Reads all stored `CheckinRecord` and `FinishClassRecord` JSON strings from `SharedPreferences`.
*   **Sorting Rule:** Chronological (Newest-first sorting).
*   **Visual Data:** 
    *   Type badge indicating if it was a `Check-in` or `Finish Class`.
    *   Displays Student Profile, Timestamp, and Mood.
    *   Shows a thumbnail of the captured photo if attached.

---

## 5. Non-Functional Requirements
1. **Performance:** Reading and writing local JSON database (`SharedPreferences`) must execute in under 500ms to avoid UI stutter.
2. **Offline-First (MVP):** Students must be able to complete the check-in forms and store the history completely locally on device.
3. **Accessibility & Error Handling:** Explicit SnackBar warnings if GPS/Camera permissions are denied, or if mandatory steps/fields are skipped before submission.
4. **Platform Compatibility:** Target SDKs for modern operating systems: Android (API 29+) and iOS (14+ target).

---

## 6. Future Roadmap
*   **V1.5 Cloud Integration:** Sync local records to an external database (e.g., Firebase Firestore) automatically when network connectivity is present, populating a real-time Instructor Dashboard.
*   **V2.0 Geofencing Constraints:** Prevent check-ins if the device's Lat/Lng distance falls outside an `X` meter radius of the university's central coordinates.
*   **V2.0 Analytics Dashboard:** Aggregate student mood and feedback statistics across an entire semester to visualize learning sentiment trends.
