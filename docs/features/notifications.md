# Push Notifications & Local Alerts

## Implementation Overview
- Introduced `NotificationService` that wraps Firebase Messaging + `flutter_local_notifications`. It requests permissions, registers device tokens per user, and displays heads-up banners in foreground/background.
- Hooked initialization into `main.dart` (after Firebase + dotenv) and tied token registration to the `AuthController` login flow so every authenticated device stores its FCM token in `users/{uid}.fcmTokens`.
- Added helper APIs to send push notifications (`sendNotificationToUser`) using the legacy FCM HTTP endpoint and a server key from `.env`.
- Controllers now trigger push updates: `ConfirmBookingController` notifies providers about new requests, and `BookingsController` informs customers/providers when statuses change (accepted, rejected, canceled).

## Notes / Next Steps
- **Server key**: supply `FIREBASE_SERVER_KEY` in `.env`. For production, send notifications from a backend/Cloud Function instead of the client to keep the key secret and to support topic/batch sends.
- **APNs setup**: configure APNs certificates/keys for iOS and update `firebase_app_id_file.json`/`GoogleService-Info.plist` accordingly; otherwise notifications won’t arrive on Apple devices.
- **In-app routing**: currently taps are not deep-linked. Extend `NotificationService` to inspect `payload`/`data` and navigate to the related booking/chat when the user taps.***

