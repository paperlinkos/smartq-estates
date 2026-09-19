# SmartQ Estates — Development Context
**Last updated:** 2026-09-19  
**Product concept:** *"Your estate, in one place."*  
**Stack:** Flutter (Dart) · Monorepo at `paperlinkos/smartq-estates`

---

## ✅ Phases Complete

| Phase | Screen / Feature | Status |
|-------|-----------------|--------|
| 1 | Foundation — scaffold, theme, navigation, models, widgets | ✅ Done |
| 2 | Resident Home Screen | ✅ Done |
| 3A | Visitors Home Screen | ✅ Done |
| 3B | Invite Someone (visitor invitation form) | ✅ Done |
| 3C | Visitor Pass + QR Code | ✅ Done |
| 4A | Create Event form | ✅ Done |
| 4B | Event Pass + QR Code | ✅ Done |
| 5A | Security Home Screen | ✅ Done |
| 5B | Security QR Scanner (scan + decode only) | ✅ Done |

---

## 🔜 Next Phase: 5C — Pass Verification

**Goal:** When a QR code is scanned and decoded, determine whether the pass is valid and show a clear GRANT / DENY decision to the security officer.

The scanning pipeline is already complete. Phase 5C only adds verification logic.

### What Phase 5C should do:

1. **Receive** a `DecodedQrPayload` (already provided by Phase 5B)
2. **Verify** the payload against known passes:
   - Check pass type (`visitor` or `event`)
   - Look up the pass by `passId` in the in-memory store
   - Confirm the `token` matches
   - Check the pass is not cancelled
   - Check the visit date/event window covers today
3. **Show a clear decision screen:**
   - ✅ **ACCESS GRANTED** — visitor name, unit, arrival time
   - ❌ **ACCESS DENIED** — reason (expired / cancelled / unrecognised / wrong date)
4. **Log the event** in the security activity feed (in-memory for now)

### Architecture note:
- Verification logic → new `PassVerificationService` in `lib/core/services/`
- `DecodedResultScreen` (Phase 5B) should be replaced or extended to show the result
- Keep verification separate from scanning — scanner does not decide, verifier decides

---

## Known UX Issue To Fix

The Security Terminal is currently hard to find:
- Path: **Account tab → PREFERENCES & SYSTEM → "Security Gate Terminal"** (a small row item)

**Proposed fix:** Add a role selector on the Welcome screen — "I am a Resident" vs "I am Security" — so security officers navigate directly to SecurityShellScreen without going through resident menus.

---

## App Architecture

### Navigation Flow
SplashScreen → WelcomeScreen → EstateSelectionScreen → MainShellScreen (resident)
                                                      → SecurityShellScreen (security, via Account tab)

### Route Constants (lib/navigation/app_router.dart)
```
/                      → SplashScreen
/welcome               → WelcomeScreen
/estate-selection      → EstateSelectionScreen
/main                  → MainShellScreen (resident bottom nav: HOME / ACTIVITY / ACCOUNT)
/visitors              → VisitorsHomeScreen
/visitors/invite       → InviteSomeoneScreen
/visitors/pass         → VisitorPassScreen
/visitors/create-event → CreateEventScreen
/visitors/event-created→ EventCreatedScreen
/visitors/event-pass   → EventPassScreen
/security              → SecurityShellScreen (security bottom nav: SECURITY / ACCOUNT)
/security/verify-access→ VerifyAccessScannerScreen
/security/scan-result  → DecodedResultScreen
```

### Key Models (lib/core/models/)
- Estate, VisitorPass, EventPass, EstateEvent, PassType, DecodedQrPayload, VisitorInvitation

### Key Services (lib/core/services/)
- EstateService — estate data
- QrCodeService — token generation and QR encoding

### QR Payload Format (NO PII in QR)
```json
{ "passId": "VP-XXXXXXXX", "type": "visitor", "token": "abc123def456" }
```

### Reusable Widgets (lib/widgets/)
AppButton · AppCard · AppHeader · AppTextField · AppBottomNavigation

---

## Design Language — STRICTLY MAINTAIN

- Colors: Monochrome only — black #000000, white #FFFFFF, grays via AppColors
- Typography: Inter font, uppercase section labels, strong weight hierarchy  
- Style: Minimalist, spacious, calm, premium, uncluttered
- AppButtonVariant enum: primary / secondary / destructive
- NO color gradients, NO decorative icons, NO busy layouts

---

## Dependencies (pubspec.yaml)
```
google_fonts: ^6.1.0
mobile_scanner: ^7.4.2    ← Camera QR scanning (needs native rebuild)
qr_flutter: ^4.1.0         ← QR code rendering
share_plus: ^10.0.0        ← Share pass action
uuid: ^4.3.3               ← Pass ID generation
intl: ^0.19.0              ← Date formatting
```

> ⚠️ After any pubspec.yaml change: stop flutter run, then flutter run again.
> Native packages cannot be hot-reloaded.

---

## Running The App

```bash
cd /Users/christembassyabujazone1/projects/smartq-estates
flutter run
```

To reach the Security Terminal manually:
1. Welcome → Select Estate → lands on Home
2. Tap ACCOUNT tab (bottom right)
3. PREFERENCES & SYSTEM → tap "Security Gate Terminal" →
4. Now on SecurityShellScreen
5. Tap VERIFY ACCESS to open QR scanner

---

## Tests

```bash
flutter test      # All tests
flutter analyze   # Static analysis
```

Camera hardware is mocked — tests run without a physical device.

---

## Future Phases

| Phase | Feature |
|-------|---------|
| 5C | Pass Verification (GRANT / DENY) — NEXT |
| 6 | Maintenance Requests |
| 7 | Estate Services (gas, groceries, cleaning, etc.) |
| 8 | Payments |
| 9 | Activity / History log |
| 10 | Real auth, backend, push notifications |
