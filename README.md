# UniFInd

UniFInd is a university lost-and-found iOS app. Students can browse lost and found items, submit ownership claims, and view claim updates. Administrators manage item reports and review claims.

## Technology stack

| Area | Technology |
| --- | --- |
| Platform | iOS 17 and later |
| Language | Swift 5 |
| UI | SwiftUI |
| Authentication | Firebase Authentication (email and password) |
| App data | Cloud Firestore |
| Item and claim images | Cloudinary unsigned image uploads |
| Dependencies | Swift Package Manager through the Xcode project |

The Xcode project references Firebase iOS SDK 12.18.0 and Cloudinary iOS SDK 5.2.5. The app uses Firebase Core, Authentication, and Firestore products. Image upload requests are sent to Cloudinary from the app. There is no Python/FastAPI backend and Firebase Storage is not used.

## Features

- Student registration, sign-in, and password reset with Firebase Authentication.
- Student and administrator experiences, with the account role read from Firestore.
- Browse and search lost-and-found listings.
- Submit an ownership claim with a written description and optional proof image.
- Administrator tools for managing listings and reviewing claims.
- Firebase-backed user profiles, listings, and claims, with demo/sample data available when Firebase is not configured.

## Project layout

```text
UniFInd/
├── UniFInd.xcodeproj/       # Xcode project and Swift package configuration
├── UniFInd/
│   ├── Components/          # Reusable SwiftUI components
│   ├── Controllers/         # Authentication, item, claim, chat, and notification state
│   ├── Models/              # App data models
│   ├── Navigation/          # Root view and app routes
│   ├── Services/            # Firebase and Cloudinary integrations
│   ├── Theme/               # Colors and shared styling
│   └── Views/               # Student, administrator, and authentication screens
├── firestore.rules          # Starter Firestore security rules
└── README.md
```

## Requirements

- A Mac running a version of macOS supported by your installed Xcode.
- Xcode with iOS 17 SDK support.
- An Apple ID for running the app on a physical device.
- Firebase and Cloudinary projects for live backend and image-upload features.

## Getting started

1. Clone the repository and open `UniFInd.xcodeproj` in Xcode.
2. Let Xcode resolve the Swift Package Manager dependencies.
3. Configure Firebase as described below, or launch without Firebase to use the app's demo fallback.
4. Select the `UniFInd` scheme and an iOS 17+ simulator or device, then build and run.

## Firebase setup

1. Create or select a Firebase project and register an iOS app using the bundle identifier `com.student.unifind`.
2. Enable **Authentication → Email/Password** and create a **Cloud Firestore** database.
3. Download that Firebase app's `GoogleService-Info.plist`, put it in the project root, and add it to the app target in Xcode. Do not use another project's configuration file. This file is intentionally ignored by Git; each developer must provide their own.
4. Review `firestore.rules` and deploy rules appropriate for your environment before using real accounts or data. The included rules are a project starter, not a production security review.
5. Student registration creates a Firebase Auth account and a matching `users/{uid}` document with the student's profile and `role: "student"`.
6. To provision an administrator, create the account through a trusted process and set its matching Firestore user document's role to `admin`. Do not allow users to grant themselves administrator access.

Firestore collections used by the app include `users`, `items`, `claims`, `chats`, and `notifications`.

## Cloudinary setup

The upload service is in `UniFInd/Services/CloudinaryService.swift`. Configure the Cloudinary cloud name and an unsigned upload preset there for development. Restrict the preset's upload options and usage in Cloudinary. Never put a Cloudinary API secret in the iOS app or commit it to source control.

## Configuration and security notes

- `GoogleService-Info.plist` identifies a Firebase app and is not included in this repository. Use the configuration for your own Firebase project and apply appropriate API-key restrictions.
- Do not commit credentials, private keys, service-account files, or production secrets.
- Firestore rules and client-side role checks must not be treated as a substitute for a production security review.
- Cloudinary's cloud name and unsigned preset are client-side configuration, not secrets. Anyone who can access an unsigned preset may be able to submit uploads, so configure upload limits and rotate or disable the preset if it is exposed or abused.
