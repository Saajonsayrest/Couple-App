# 🚀 Implementation Plan: Making Couple App Dynamic & Online

## Overview

This plan transforms the app from **100% offline (Hive-only)** to **online-first with offline cache**, using the backend API while preserving all existing features.

---

## Architecture: Online-First with Offline Cache

```
┌─────────────────────────────────────────────────┐
│                  Flutter App                     │
│                                                  │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐    │
│  │  Screens  │──▶│ Providers│──▶│ API Svc  │────┼──▶ Backend API
│  └──────────┘   └────┬─────┘   └──────────┘    │
│                      │                           │
│                 ┌────▼─────┐                     │
│                 │   Hive   │ (offline cache)     │
│                 └──────────┘                     │
└─────────────────────────────────────────────────┘

Flow: Screen → Provider → Try API first → Cache in Hive → Return data
Fallback: If API fails → Return cached Hive data
```

---

## Phase 1: Foundation (API Service + Auth)

### 1.1 Add `http` dependency

```yaml
# pubspec.yaml
dependencies:
  http: ^1.2.1
```

### 1.2 Create `lib/services/api_service.dart`

Core HTTP client with:
- Base URL constant
- JWT token management (stored in `SharedPreferences`)
- `GET`, `POST`, `PUT`, `DELETE` helper methods
- Auto-attach `Authorization: Bearer <token>` header
- Error handling (parse error JSON)
- Connectivity check before API calls

### 1.3 Create `lib/services/auth_service.dart`

- `register(username, password)` → stores token + user data
- `login(username, password)` → stores token + user data
- `logout()` → clears token + cached data
- `getToken()` → returns stored JWT
- `isLoggedIn()` → checks if valid token exists
- `getCurrentUser()` → returns cached user info

### 1.4 Create Auth Screens

- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/register_screen.dart`
- Beautiful UI matching the app's theme
- Form validation
- Error display

### 1.5 Update Router

- Add `/login` and `/register` routes
- Update redirect logic: check JWT token instead of Hive profiles
- Flow: No token → Login/Register → Onboarding (if no profiles) → Home

---

## Phase 2: Sync Profiles with API

### 2.1 Create `lib/services/partner_service.dart`

- `createPartner(data)` → POST /api/partners
- `getPartners()` → GET /api/partners
- `updatePartner(id, data)` → PUT /api/partners/:id
- `deletePartner(id)` → DELETE /api/partners/:id

### 2.2 Create `lib/services/upload_service.dart`

- `uploadImage(File)` → POST /api/upload → returns URL
- Used when picking profile images

### 2.3 Update `ProfileProvider`

- On `updateProfiles()`: Upload images → Create/Update via API → Cache in Hive
- On `_loadProfiles()`: Try API first → Cache in Hive → Fallback to Hive
- Add `syncFromServer()` method for pull-to-refresh

### 2.4 Update `OnboardingScreen`

- After completing onboarding → Upload images → Create partners via API
- Store API partner IDs locally for future updates

### 2.5 Update `EditProfileScreen`

- On save → Upload new images → Update partners via API → Update Hive cache

---

## Phase 3: Sync Timeline/Journeys with API

### 3.1 Create `lib/services/journey_service.dart`

- `createJourney(data)` → POST /api/journeys
- `getJourneys()` → GET /api/journeys
- `updateJourney(id, data)` → PUT /api/journeys/:id
- `deleteJourney(id)` → DELETE /api/journeys/:id

### 3.2 Update `TimelineScreen`

- Load events from API on init (cache in Hive)
- Create/Edit/Delete → API first → Update Hive cache
- Keep system events (birthdays, anniversaries) generated locally
- Map `TimelineEvent.id` to API journey IDs

### 3.3 Update `TimelineEvent` model

- Add optional `serverId` field for API sync tracking
- Keep local `id` (UUID) for offline entries

---

## Phase 4: Sync Reminders with API

### 4.1 Create `lib/services/reminder_service.dart`

- `createReminder(data)` → POST /api/reminders
- `getReminders()` → GET /api/reminders
- `updateReminder(id, data)` → PUT /api/reminders/:id
- `deleteReminder(id)` → DELETE /api/reminders/:id

### 4.2 Update `HomeScreen` reminders

- Load from API → Cache in Hive
- CRUD operations → API first → Hive cache
- Local notifications still scheduled from local data

---

## Phase 5: Settings Sync

### 5.1 Create `lib/services/settings_service.dart`

- `getSettings()` → GET /api/settings
- `updateSettings(data)` → PUT /api/settings

### 5.2 Update `ThemeProvider`

- On theme change → Save to API + Hive
- On load → Fetch from API → Cache in Hive → Fallback to Hive

---

## Phase 6: Partner Linking (Share to Partner) ⭐

### 6.1 Create `lib/services/link_service.dart`

- `linkPartner(inviteCode)` → POST /api/link
- `getLinkStatus()` → GET /api/link
- `unlinkPartner()` → DELETE /api/link

### 6.2 Create `lib/providers/auth_provider.dart`

- Manages auth state (logged in, user info, invite code, link status)
- Exposes `isLinked`, `partnerUsername`, `inviteCode`

### 6.3 Update `SettingsScreen` → Add Partner Linking Section

Add to the Settings/Profile section:

```
┌──────────────────────────────────────┐
│  👤 Account                          │
│  ┌────────────────────────────────┐  │
│  │ 📋 Your Invite Code            │  │
│  │    ABC123XY  [Copy] [Share]    │  │
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │ 🔗 Link with Partner           │  │
│  │    Enter partner's code...     │  │
│  │    [Link Now]                  │  │
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │ ✅ Connected with: sajan       │  │
│  │    Linked on Feb 24, 2026     │  │
│  │    [Unlink]                   │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

### 6.4 How "Colors Matched" Works
- When User A (male/sky_dreams) links with User B (female/cotton_candy):
  - User A sees: Their profile as blue, partner as pink
  - User B sees: Their profile as pink, partner as blue
  - Both see the SAME data (journeys, reminders, partner profiles)
  - Theme colors are determined by their own `gender` in their profile

---

## Phase 7: Polish & Edge Cases

### 7.1 Loading States
- Add shimmer/skeleton loaders while syncing
- Show "Syncing..." indicator in app bar

### 7.2 Error Handling
- Network errors → Show toast + work offline
- Auth errors (401) → Auto-redirect to login
- Conflict errors (409) → Show meaningful message

### 7.3 Logout Feature
- Add "Logout" button in Settings
- Clear JWT token + optionally clear cached data
- Redirect to login screen

### 7.4 Offline Mode
- All features work offline via Hive cache
- Sync when connectivity returns
- Show "Offline Mode" indicator

---

## File Structure (New/Modified Files)

```
lib/
├── core/
│   ├── api_constants.dart          ← NEW (base URL, endpoints)
│   ├── app_theme.dart
│   ├── constants.dart
│   └── globals.dart
├── data/
│   ├── models/
│   │   ├── user_profile.dart       ← MODIFY (add serverId)
│   │   ├── timeline_event.dart     ← MODIFY (add serverId)
│   │   ├── reminder.dart           ← MODIFY (add serverId)
│   │   └── auth_user.dart          ← NEW (API user model)
├── providers/
│   ├── auth_provider.dart          ← NEW
│   ├── profile_provider.dart       ← MODIFY (add API sync)
│   └── theme_provider.dart         ← MODIFY (add API sync)
├── services/
│   ├── api_service.dart            ← NEW (HTTP client)
│   ├── auth_service.dart           ← NEW
│   ├── partner_service.dart        ← NEW
│   ├── journey_service.dart        ← NEW
│   ├── reminder_service.dart       ← NEW
│   ├── settings_service.dart       ← NEW
│   ├── upload_service.dart         ← NEW
│   ├── link_service.dart           ← NEW
│   ├── image_service.dart
│   └── notification_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart       ← NEW
│   │   └── register_screen.dart    ← NEW
│   ├── settings/
│   │   ├── settings_screen.dart    ← MODIFY (add link, logout)
│   │   └── edit_profile_screen.dart← MODIFY (add API sync)
│   ├── home/home_screen.dart       ← MODIFY (load from API)
│   ├── timeline/timeline_screen.dart← MODIFY (load from API)
│   └── onboarding/onboarding_screen.dart ← MODIFY (API save)
└── routes/
    └── app_router.dart             ← MODIFY (add auth routes)
```

---

## Implementation Order (Recommended)

| Step | What | Priority | Effort |
|------|------|----------|--------|
| 1 | API Service + Auth Service | 🔴 High | Medium |
| 2 | Login/Register Screens | 🔴 High | Medium |
| 3 | Router Update (auth flow) | 🔴 High | Low |
| 4 | Partner Service + Profile Sync | 🔴 High | Medium |
| 5 | Upload Service (images) | 🟡 Medium | Low |
| 6 | Journey Service + Timeline Sync | 🟡 Medium | Medium |
| 7 | Reminder Service + Sync | 🟡 Medium | Medium |
| 8 | Partner Linking (invite code) | 🔴 High | Medium |
| 9 | Settings Sync | 🟢 Low | Low |
| 10 | Offline mode + Error handling | 🟡 Medium | Medium |
| 11 | Logout feature | 🟢 Low | Low |

---

## Key Decisions

1. **Hive stays** — Used as offline cache, not removed
2. **API is primary** — Always try API first, fallback to Hive
3. **Games stay local** — Static data, no need to sync
4. **Notifications stay local** — Scheduled from cached data
5. **Home Widget stays local** — Updated after API sync
6. **Images uploaded** — Picked locally → Upload to API → Store URL
