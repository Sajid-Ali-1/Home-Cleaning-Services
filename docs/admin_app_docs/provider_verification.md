# Provider Verification

## Data Model
- Collection: `provider_verifications/{providerId}`
- Fields:
  - `providerName`, `providerEmail`
  - `status`: `pending|approved|rejected`
  - `documents`: array of `{name, url, type, uploadedAt}`
  - `submittedAt`, `reviewedAt`, `reviewerId`
  - `rejectionReason` (nullable)

## Admin UI
- Filters: All, Pending, Approved, Rejected.
- Detail card shows provider info + document list (copy URL).
- Actions when pending:
  - Approve → status to `approved`, clears rejectionReason.
  - Reject with reason → status to `rejected`, saves reason.
- Hook point for email notification after approve/reject.

## Next Steps
- Add document previews (PDF/images) and bulk export.
- Log audit trail of review actions in separate collection.




