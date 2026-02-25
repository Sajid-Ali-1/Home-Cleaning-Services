# Availability Selection Refresh

## Implementation Overview
- Enhanced `ServiceDetailsController` to generate granular time slots by combining the provider’s `AvailabilitySchedule` with configurable intervals, producing `AvailabilitySlotView` + `AvailabilityDayGroup` structures.
- Added automatic slot selection (`ensureInitialSlotSelection`) and richer metadata (`selectedSlotInfo`) so booking + confirmation flows share the same schedule state.
- Replaced the legacy chip widget with `CustomerAvailabilityPicker`, giving users horizontal date cards plus contextual time chips and a bottom sheet fallback when no slots exist.
- Updated `ServiceAvailabilitySection` to use the new picker and to keep owner/customer guidance tied to the refreshed layout.

## Notes / Next Steps
- **Dynamic interval**: `_slotIntervalMinutes` is currently set to 60. Expose this via service settings if providers offer shorter visits.
- **Per-slot capacity**: if multiple bookings per slot should be allowed, track availability usage in Firestore and disable chips when capacity is reached.
- **Time zones**: the current implementation assumes the device/system zone. If providers/customers operate in different zones, normalize to UTC and format relative to the viewer.***

