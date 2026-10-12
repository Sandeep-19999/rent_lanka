# Rent Lanka

Rent Lanka is a Sports Equipment Rental and Exchange Platform designed for users in Sri Lanka.

The system allows sports players to discover, rent, and exchange sports equipment, while equipment providers can manage listings, rental requests, availability, pickups, returns, earnings, and withdrawals.

The project consists of a Flutter mobile application and a React-based Admin Dashboard connected to Firebase.

---

## Technologies

### Mobile Application

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Cloudinary for image uploads

### Admin Web Application

- React
- Vite
- JavaScript
- Firebase Authentication
- Cloud Firestore
- React Router
- Recharts
- Lucide React

### Development Tools

- Visual Studio Code
- Android Studio
- Git
- GitHub
- Firebase Console

---

## User Roles

- Sports Player
- Equipment Provider
- Administrator

---

## Main Features

### Sports Player

- User registration and login
- Email verification
- Forgot password
- Role selection
- Browse sports equipment
- Search equipment
- Category-based filtering
- View equipment details
- View provider details
- Add equipment to favourites
- Recent search history
- Select rental dates
- Create bookings
- Payment flow
- Booking confirmation
- View My Bookings
- View booking details
- Equipment exchange requests
- Messaging
- Notifications
- Unread notification indicator
- Ratings and reviews
- Profile management
- Update profile image
- Update phone number and location

---

### Equipment Provider

- Provider Dashboard
- Add Equipment
- View My Listings
- Edit Equipment
- Delete Equipment
- Manage Equipment Availability
- View Rental Requests
- Accept Rental Requests
- Reject Rental Requests
- Manage Rental Request Status
- Pickup Management
- Return Management
- Confirm equipment handover
- Confirm returned equipment
- Confirm item condition
- Confirm security deposit refund
- Add Bank Account
- View saved Bank Accounts
- Manage Withdrawals
- View Withdrawal History
- View Equipment Performance / Insights
- Provider Profile Management

---

### Administrator

- Admin Login
- Payment Dashboard
- View Payment Records
- View Payment Details
- Transaction History
- Refund Management
- Withdrawal Management
- Firebase-based data integration

---

## Project Structure

```text
rent_lanka/
├── mobile/          # Flutter Mobile Application
├── admin-web/       # React Admin Dashboard
├── firebase/        # Firebase-related files
├── docs/            # Project Documentation
└── README.md

How to Run the Flutter Mobile Application
Navigate to the mobile application folder:
cd mobile

Install Flutter dependencies:
flutter pub get

Check available devices:
flutter devices

Run the application:
flutter run

To run on a specific device:
flutter run -d <device-id>

How to Run the Admin Web Application
Navigate to the Admin Web folder:
cd admin-web

Install dependencies:
npm install

Run the development server:
npm run dev

The local development URL will normally be:
http://localhost:5173

Build the Admin Web Application
Run:
npm run build

The production build will be generated inside:
admin-web/dist/

Git Workflow
The project follows a feature branch workflow.
Feature Branch
      ↓
   develop
      ↓
    main

    Application Testing
The project includes testing for several application features such as:
- Booking lifecycle
- Payment methods
- Player navigation
- Provider navigation
- Profile navigation
- Ratings and reviews
- Exchange requests
- Notification behavior
- Profile updates
- Recent search functionality
Flutter tests can be run using:
flutter test

Flutter static analysis can be run using:
flutter analyze