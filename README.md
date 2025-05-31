# 📍 Staff Tracking App

A complete employee/staff tracking system built using **Flutter**, **Firebase**, **Riverpod**, and **Hive** for local caching.

---

## ✨ Features

### 🔐 Authentication
- Admin and Staff login/signup using Firebase Auth.
- Role-based navigation and access control.

### 🧭 Location Tracking
- Punch In/Out feature for staff.
- Track and log live location every 2 minutes when punched in.
- Admin can view:
  - Staff’s **live location**.
  - Staff’s **movement history** for a specific day.

### 🗺 Office Management
- Admin can create and assign office locations using an interactive map.
- Assign staff to specific offices.

### 🕒 Attendance & Reports
- Working hours calculated from punch in/out.
- Daily summary view for staff.
- Admin can:
  - View  daily working hours report.
  - See all punch entries.

---

## 🔧 Tech Stack

| Tool/Platform  | Usage                            |
|----------------|----------------------------------|
| Flutter        | UI development                   |
| Firebase Auth  | User authentication              |
| Firebase Firestore | Cloud NoSQL DB for all data     |
| Riverpod       | State management                 |
| Flutter Map    | Map rendering                    |
| Geolocator     | Get device GPS location          |

---


### **Steps to Run the App**

1. **Clone the Repository:**
   ```sh
   git clone https://github.com/jaimonvarghese/staff-tracker-app.git
   cd staff_tracking_app
   ```
2. **Install Dependencies:**
   ```sh
   flutter pub get
   ```
3. **Run the App:**
   ```sh
   flutter run
   ```

## 📥 Download APK
🔗 **[Download Here]https://drive.google.com/file/d/1xPdLkXjtIxVEEGuEbIz9PRjLNYYI9tcA/view?usp=sharing**

