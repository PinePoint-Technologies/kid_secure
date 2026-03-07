# KidSecure

A Flutter application for crèche and school management with GPS tracking, guardian verification via QR codes, and role-based access control.

---

## Features

### Super Admin
- **Dashboard** — live stats: total schools, teachers, kids, parents, and guardians
- **Crèche Management** — full CRUD for crèches; assign and manage teachers per crèche
- **Parent Management** — view all parents, add new parents, deactivate accounts
- **Kids Management** — enrol kids, link parents to kids, deactivate records
- **Reports** — sick leave and enrollment reports across all schools

### Teacher
- View and manage kids in their assigned crèche
- Link parents to kids
- Record sick leave

### Parent
- View their child's profile and crèche information
- Receive notifications about their child

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| State Management | Riverpod |
| Navigation | GoRouter |
| Backend | Firebase (Auth, Firestore, Storage, Functions, Messaging) |
| Maps & Location | Google Maps, Geolocator |
| QR Codes | mobile_scanner, qr_flutter |
| Animations | flutter_animate, Lottie |
| Charts | fl_chart |

---

## Architecture

```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── providers/       # Core Firebase providers
│   ├── router/          # GoRouter route definitions
│   ├── theme/           # App theme and colors
│   └── utils/           # Helpers and extensions
├── features/
│   ├── auth/            # Login, registration, onboarding
│   ├── parent/          # Parent dashboard and screens
│   ├── teacher/         # Teacher dashboard and screens
│   ├── super_admin/     # Admin dashboard, crèches, kids, reports
│   └── splash/          # Splash screen
└── shared/
    ├── models/          # UserModel, ChildModel, etc.
    ├── services/        # FirestoreService, AdminUserService
    └── widgets/         # Reusable UI components
```

---

## Roles & Permissions

| Role | Access |
|---|---|
| `super_admin` | Full access to all features and data |
| `teacher` | Crèche-scoped access: kids, parents, sick leave |
| `parent` | Access to their own child's data |

Role-based routing is handled in `app_router.dart`. The `Permission` enum in `user_model.dart` controls feature-level access — super admins automatically receive all permissions.

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Firebase project with Firestore, Auth, Storage, and Functions enabled
- Google Maps API key

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/khuthy/kid_secure.git
   cd kid_secure
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective platform folders
   - Update `firebase.json` with your project details

4. **Run the app**
   ```bash
   flutter run
   ```

---

## Firestore Security

Firestore rules are defined in `firestore.rules`. Key rules:
- Super admins have full read/write access
- Teachers can read and update user and child records within their crèche
- Parents can only read their own child's data

---

## Key Services

- **`FirestoreService`** — all database operations: watching kids, parents, guardians, sick leave, linking parents to children
- **`AdminUserService`** — creates Firebase Auth users via a secondary app instance so the super admin session is never interrupted