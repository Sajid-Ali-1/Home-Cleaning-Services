# Chat & Media Messaging

## Implementation Overview
- Built `ChatController` to manage chat streams (`chats/{bookingId}/messages`), send text/image messages, and expose UI state (`isSending`, `isUploading`, `messages`). Uses `ImagePicker` + `StorageServices.uploadChatImage` for media uploads.
- Added `ChatMessage` model plus `ChatScreen` (message bubbles, image support, input tray) and `_ChatInput` helper. Chats are tied to bookings so both roles have a shared context for each conversation.
- Service details now include a “Chat with Provider” action (customer-side) that opens the latest booking’s chat thread, while `BookingCard` exposes chat buttons whenever the booking isn’t canceled/rejected.
- Created `MessagesScreen` tab that reuses `BookingsController` data to list active conversations, giving providers and customers quick access to existing threads.

## Notes / Next Steps
- **Typing/online indicators**: currently omitted; add Firestore presence docs or Realtime Database if presence is required.
- **Push notifications per message**: integrate chat message triggers server-side (Cloud Functions) to push message-specific notifications rather than only booking status updates.
- **Attachments**: only gallery images are supported. Extend `_ChatInput` with camera capture, documents, or quick replies if workflows demand it.***

