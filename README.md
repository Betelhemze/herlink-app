# HerLink

HerLink is a comprehensive platform designed to connect and empower users through a community-driven mobile application. The project consists of a high-performance Flutter mobile frontend and a robust Node.js/Express backend.

## 🚀 Features

- **User Authentication**: Secure signup and login using JWT, with integrated Google Sign-In support.
- **Dynamic Feed**: A social-style feed where users can browse, like, and interact with posts.
- **Product Marketplace**: functionality to add and view products, with a "Saved Items" feature for personalized tracking.
- **Event Management**: Discover and participate in community events.
- **Real-time Messaging**: Instant communication between users powered by Socket.io.
- **Secure Backend**: Relational data management using PostgreSQL and secure password hashing with Bcrypt.
- **Media Support**: Seamless image uploading for products and profiles.

## 🛠 Tech Stack

### Frontend (Mobile)
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: Provider / Local State
- **Real-time**: [socket_io_client](https://pub.dev/packages/socket_io_client)
- **Auth**: [google_sign_in](https://pub.dev/packages/google_sign_in), [firebase_core](https://pub.dev/packages/firebase_core)
- **UI**: Material Design, Custom Svg Icons

### Backend
- **Environment**: [Node.js](https://nodejs.org/)
- **Framework**: [Express.js](https://expressjs.com/)
- **Database**: [PostgreSQL](https://www.postgresql.org/)
- **Authentication**: JWT (JSON Web Tokens)
- **File Uploads**: Multer
- **Real-time**: Socket.io

## 📂 Project Structure

```text
herlink-app/
├── herlink/          # Flutter Mobile Application
│   ├── lib/          # Dart source code
│   └── assets/       # Images and icons
└── herlink_backend/  # Node.js API Server
    ├── routes/       # API endpoints
    ├── controllers/  # Business logic
    └── config/       # Database and environment configuration
```

## 🏁 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js & npm](https://nodejs.org/en/download/)
- [PostgreSQL](https://www.postgresql.org/download/)

### Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Betelhemze/herlink-app.git
   cd herlink-app
   ```

2. **Backend Setup**
   - Navigate to `herlink_backend/`
   - Run `npm install`
   - Create a `.env` file based on the environment requirements (DB credentials, JWT secret, etc.)
   - Start the server: `npm run dev`

3. **Frontend Setup**
   - Navigate to `herlink/`
   - Run `flutter pub get`
   - Ensure you have a connected device or emulator.
   - Run the app: `flutter run`

## 📄 License
This project is licensed under the ISC License.
