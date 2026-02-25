# Bookings Management (Customers & Providers)

## Implementation Overview
- Added `BookingsController` to stream Firestore booking docs for the logged-in user (customer or provider), keep filters (`requests`, `upcoming`, `past`), auto-cancel stale requests, and trigger status updates.
- Created `MyBookingsScreen` with a segmented control + refreshed list UI using the reusable `BookingCard`. Provider cards expose accept/reject controls; customers can cancel requests. Both roles include a contextual chat button.
- Wired the bookings tab into `NavPage`, ensuring a single `BookingsController` instance feeds both the bookings and messages surfaces.
- Introduced `MessagesScreen` as a top-level tab that reuses `BookingsController.bookings` to show active conversations and open the appropriate `ChatScreen`.
- Extended `BookingDbService` with helper APIs (status updates, latest booking lookup) reused across controllers/UI and auto-cancellation logic.

## Notes / Next Steps
- **Role-based filtering**: the current filters are intentionally simple; add extra tabs (e.g., “Completed”) or provider-only views (per service) if needed.
- **Pagination**: Firestore streams all bookings for now. Consider pagination or query cursors if provider catalogs grow large.
- **Provider earnings**: augment `BookingCard` with payout status and integrate with accounting data when Stripe Connect or other payout systems are ready.***

