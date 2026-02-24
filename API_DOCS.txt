# Couple App Backend — API Documentation (Updated)

**Base URL:** `https://couple-app-backend.vercel.app`

**Tech Stack:** Node.js, Vercel Serverless Functions, Neon PostgreSQL, JWT Auth

---

## Authentication

All endpoints marked with 🔒 require a JWT token in the header:

```
Authorization: Bearer <token>
```

Tokens are returned from the Register and Login endpoints. They expire in **30 days**.

---

## Endpoints

---

### 1. Register User

```
POST /api/auth/register
```

**Request Body:**
```json
{
  "username": "rajiv",
  "password": "mypassword123"
}
```

**Validation:**
- `username`: required, 3–50 characters, must be unique
- `password`: required, minimum 6 characters

**Response (201):**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "username": "rajiv",
    "invite_code": "ABC123XY",
    "created_at": "2026-02-24T09:32:20.545Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Errors:**
- `400` — Missing or invalid fields
- `409` — Username already taken

> **Note:** Each user gets a unique `invite_code` on registration. This code is used for partner linking.

---

### 2. Login

```
POST /api/auth/login
```

**Request Body:**
```json
{
  "username": "rajiv",
  "password": "mypassword123"
}
```

**Response (200):**
```json
{
  "message": "Login successful",
  "user": {
    "id": 1,
    "username": "rajiv",
    "invite_code": "ABC123XY",
    "linked_partner_id": 2,
    "created_at": "2026-02-24T09:32:20.545Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Errors:**
- `400` — Missing fields
- `401` — Invalid username or password

---

### 3. 🔒 Get Current User Profile

```
GET /api/auth/me
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "user": {
    "id": 1,
    "username": "rajiv",
    "invite_code": "ABC123XY",
    "linked_partner_id": 2,
    "created_at": "2026-02-24T09:32:20.545Z"
  }
}
```

---

## Partner Linking (NEW - Required for sharing with partner)

### 4. 🔒 Link Partner (via Invite Code)

```
POST /api/link
Authorization: Bearer <token>
```

**How it works:**
- User A shares their `invite_code` (from registration/login) to User B
- User B enters User A's invite code to link accounts
- Once linked, both users share the same couple space (partners, journeys, reminders, settings)
- The link is bidirectional — once B links to A, A is also linked to B

**Request Body:**
```json
{
  "invite_code": "ABC123XY"
}
```

**Response (200):**
```json
{
  "message": "Successfully linked with partner!",
  "partner": {
    "id": 2,
    "username": "sajan"
  },
  "couple_id": 1
}
```

**Errors:**
- `400` — Missing invite code, trying to link to yourself, or already linked
- `404` — No user found with that invite code

---

### 5. 🔒 Get Link Status

```
GET /api/link
Authorization: Bearer <token>
```

**Response (200) — Linked:**
```json
{
  "is_linked": true,
  "couple_id": 1,
  "partner": {
    "id": 2,
    "username": "sajan"
  },
  "linked_at": "2026-02-24T10:00:00.000Z"
}
```

**Response (200) — Not Linked:**
```json
{
  "is_linked": false,
  "invite_code": "ABC123XY"
}
```

---

### 6. 🔒 Unlink Partner

```
DELETE /api/link
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "message": "Partner unlinked successfully"
}
```

> **Warning:** Unlinking will separate the couple's shared data.

---

## Partner Profiles

### 7. 🔒 Create Partner Profile

```
POST /api/partners
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "full_name": "Rajiv Bhandari",
  "nickname": "Rajiv",
  "gender": "male",
  "date_of_birth": "2000-01-15",
  "first_met_on": "2024-06-01",
  "profile_image": "https://example.com/photo.jpg",
  "is_partner": false
}
```

**Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `full_name` | string | ✅ | Full name of the person |
| `nickname` | string | ✅ | Pet name / nickname |
| `gender` | string | ✅ | `'male'` or `'female'` |
| `date_of_birth` | date (YYYY-MM-DD) | ✅ | Date of birth |
| `first_met_on` | date (YYYY-MM-DD) | ❌ | Date the couple first met (relationship start) |
| `profile_image` | string (URL) | ❌ | Profile photo URL |
| `is_partner` | boolean | ✅ | `false` = me, `true` = my partner |

**Response (201):**
```json
{
  "message": "Partner profile created",
  "partner": {
    "id": 1,
    "profile_image": "https://example.com/photo.jpg",
    "full_name": "Rajiv Bhandari",
    "nickname": "Rajiv",
    "gender": "male",
    "date_of_birth": "2000-01-15",
    "first_met_on": "2024-06-01",
    "is_partner": false,
    "created_at": "2026-02-24T09:35:00.000Z"
  }
}
```

**Errors:**
- `400` — Missing required fields or max 2 partners already exist
- `401` — Unauthorized

> **Note:** Maximum **2 partner profiles** per user/couple (one for "me", one for "partner").

---

### 8. 🔒 Get All Partners

```
GET /api/partners
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "partners": [
    {
      "id": 1,
      "profile_image": "https://example.com/photo.jpg",
      "full_name": "Rajiv Bhandari",
      "nickname": "Rajiv",
      "gender": "male",
      "date_of_birth": "2000-01-15",
      "first_met_on": "2024-06-01",
      "is_partner": false,
      "created_at": "2026-02-24T09:35:00.000Z"
    },
    {
      "id": 2,
      "profile_image": null,
      "full_name": "Partner Name",
      "nickname": "Babe",
      "gender": "female",
      "date_of_birth": "2001-03-20",
      "first_met_on": "2024-06-01",
      "is_partner": true,
      "created_at": "2026-02-24T09:36:00.000Z"
    }
  ]
}
```

> If the user is linked with a partner (via invite code), this returns the **shared** couple profiles.

---

### 9. 🔒 Get Single Partner

```
GET /api/partners/:id
Authorization: Bearer <token>
```

**Example:** `GET /api/partners/1`

**Response (200):**
```json
{
  "partner": {
    "id": 1,
    "profile_image": "https://example.com/photo.jpg",
    "full_name": "Rajiv Bhandari",
    "nickname": "Rajiv",
    "gender": "male",
    "date_of_birth": "2000-01-15",
    "first_met_on": "2024-06-01",
    "is_partner": false,
    "created_at": "2026-02-24T09:35:00.000Z"
  }
}
```

---

### 10. 🔒 Update Partner

```
PUT /api/partners/:id
Authorization: Bearer <token>
```

**Request Body:** (same fields as Create Partner, all optional)
```json
{
  "full_name": "Rajiv B.",
  "nickname": "My Love",
  "date_of_birth": "2000-01-15",
  "first_met_on": "2024-06-01",
  "profile_image": "https://example.com/new-photo.jpg"
}
```

**Response (200):**
```json
{
  "message": "Partner updated",
  "partner": { ... }
}
```

---

### 11. 🔒 Delete Partner

```
DELETE /api/partners/:id
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "message": "Partner deleted"
}
```

---

## Journey Entries (Timeline)

### 12. 🔒 Create Journey Entry

```
POST /api/journeys
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "title": "Our First Date",
  "body": "It was a magical evening at the park. We talked for hours and watched the sunset together.",
  "date": "2024-06-15"
}
```

**Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | ✅ | Title of the journey/timeline entry |
| `body` | string | ❌ | Detailed description / story |
| `date` | date (YYYY-MM-DD) | ✅ | Date of the event |

**Response (201):**
```json
{
  "message": "Journey entry created",
  "journey": {
    "id": 1,
    "title": "Our First Date",
    "body": "It was a magical evening...",
    "date": "2024-06-15",
    "created_at": "2026-02-24T09:40:00.000Z"
  }
}
```

---

### 13. 🔒 Get All Journeys

```
GET /api/journeys
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "journeys": [
    {
      "id": 1,
      "title": "Our First Date",
      "body": "It was a magical evening...",
      "date": "2024-06-15",
      "created_at": "2026-02-24T09:40:00.000Z"
    }
  ]
}
```

> Journeys are returned sorted by `date` descending (newest first).
> If linked, returns **shared** journeys for the couple.

---

### 14. 🔒 Get Single Journey

```
GET /api/journeys/:id
Authorization: Bearer <token>
```

---

### 15. 🔒 Update Journey

```
PUT /api/journeys/:id
Authorization: Bearer <token>
```

---

### 16. 🔒 Delete Journey

```
DELETE /api/journeys/:id
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "message": "Journey deleted"
}
```

---

## Reminders (NEW - Required for app)

### 17. 🔒 Create Reminder

```
POST /api/reminders
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "title": "Buy flowers for anniversary",
  "date_time": "2026-03-15T18:00:00.000Z",
  "is_completed": false,
  "is_notification_enabled": true
}
```

**Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | ✅ | Reminder title |
| `date_time` | datetime (ISO 8601) | ✅ | When to remind |
| `is_completed` | boolean | ❌ | Default: `false` |
| `is_notification_enabled` | boolean | ❌ | Default: `true` |

**Response (201):**
```json
{
  "message": "Reminder created",
  "reminder": {
    "id": 1,
    "title": "Buy flowers for anniversary",
    "date_time": "2026-03-15T18:00:00.000Z",
    "is_completed": false,
    "is_notification_enabled": true,
    "created_at": "2026-02-24T09:45:00.000Z"
  }
}
```

---

### 18. 🔒 Get All Reminders

```
GET /api/reminders
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "reminders": [
    {
      "id": 1,
      "title": "Buy flowers for anniversary",
      "date_time": "2026-03-15T18:00:00.000Z",
      "is_completed": false,
      "is_notification_enabled": true,
      "created_at": "2026-02-24T09:45:00.000Z"
    }
  ]
}
```

> Sorted by `date_time` ascending. If linked, returns **shared** reminders.

---

### 19. 🔒 Get Single Reminder

```
GET /api/reminders/:id
Authorization: Bearer <token>
```

---

### 20. 🔒 Update Reminder

```
PUT /api/reminders/:id
Authorization: Bearer <token>
```

**Request Body:** (same fields as Create, all optional)
```json
{
  "title": "Buy flowers",
  "is_completed": true
}
```

**Response (200):**
```json
{
  "message": "Reminder updated",
  "reminder": { ... }
}
```

---

### 21. 🔒 Delete Reminder

```
DELETE /api/reminders/:id
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "message": "Reminder deleted"
}
```

---

## User Settings (NEW - Required for theme sync)

### 22. 🔒 Get User Settings

```
GET /api/settings
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "settings": {
    "theme_id": "cotton_candy",
    "notifications_enabled": true
  }
}
```

> Returns default settings if none saved yet.

---

### 23. 🔒 Update User Settings

```
PUT /api/settings
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "theme_id": "sky_dreams",
  "notifications_enabled": true
}
```

**Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `theme_id` | string | ❌ | Theme palette ID (e.g., `cotton_candy`, `sky_dreams`, etc.) |
| `notifications_enabled` | boolean | ❌ | Master notification toggle |

**Response (200):**
```json
{
  "message": "Settings updated",
  "settings": {
    "theme_id": "sky_dreams",
    "notifications_enabled": true
  }
}
```

---

## Image Upload (NEW - Required for profile pictures)

### 24. 🔒 Upload Image

```
POST /api/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Form Data:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | file | ✅ | Image file (JPEG, PNG, WebP) |
| `type` | string | ❌ | `'avatar'` or `'general'` (default: `'avatar'`) |

**Max Size:** 5 MB

**Response (200):**
```json
{
  "message": "Image uploaded successfully",
  "url": "https://couple-app-backend.vercel.app/uploads/avatar_1234567890.jpg"
}
```

> The returned `url` can be used for `profile_image` field in partner profiles.

**Errors:**
- `400` — No image file provided or file too large
- `415` — Unsupported file type

---

## Error Responses

All errors return JSON in this format:

```json
{
  "error": "Error message here"
}
```

| Status Code | Description |
|-------------|-------------|
| `400` | Bad request — missing or invalid fields |
| `401` | Unauthorized — missing or invalid token |
| `404` | Not found — resource doesn't exist or doesn't belong to you |
| `405` | Method not allowed |
| `409` | Conflict — duplicate (e.g. username taken) |
| `500` | Internal server error |

---

## Database Schema (Updated)

```sql
-- Users (updated: added invite_code and linked_partner_id)
users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password TEXT NOT NULL,
  invite_code VARCHAR(8) UNIQUE NOT NULL,    -- NEW: auto-generated unique invite code
  linked_partner_id INTEGER REFERENCES users(id), -- NEW: linked partner (NULL if not linked)
  created_at TIMESTAMP DEFAULT NOW()
)

-- Couples (NEW: tracks linked couples)
couples (
  id SERIAL PRIMARY KEY,
  user1_id INTEGER REFERENCES users(id) NOT NULL,
  user2_id INTEGER REFERENCES users(id) NOT NULL,
  linked_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user1_id, user2_id)
)

-- Partners (updated: added gender, is_partner; couple_id for shared data)
partners (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) NOT NULL,
  couple_id INTEGER REFERENCES couples(id),  -- NEW: NULL if solo, set when linked
  profile_image TEXT,
  full_name VARCHAR(100) NOT NULL,
  nickname VARCHAR(50) NOT NULL,              -- NOW REQUIRED
  gender VARCHAR(10) NOT NULL,                -- NEW: 'male' or 'female'
  date_of_birth DATE NOT NULL,                -- NOW REQUIRED
  first_met_on DATE,
  is_partner BOOLEAN DEFAULT FALSE,           -- NEW: false = me, true = partner
  created_at TIMESTAMP DEFAULT NOW()
)

-- Journeys (updated: added couple_id for shared data)
journeys (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) NOT NULL,
  couple_id INTEGER REFERENCES couples(id),   -- NEW: NULL if solo, set when linked
  title VARCHAR(255) NOT NULL,
  body TEXT,
  date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
)

-- Reminders (NEW table)
reminders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) NOT NULL,
  couple_id INTEGER REFERENCES couples(id),   -- NEW: NULL if solo, set when linked
  title VARCHAR(255) NOT NULL,
  date_time TIMESTAMP NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  is_notification_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
)

-- User Settings (NEW table)
user_settings (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) UNIQUE NOT NULL,
  theme_id VARCHAR(50) DEFAULT 'cotton_candy',
  notifications_enabled BOOLEAN DEFAULT TRUE,
  updated_at TIMESTAMP DEFAULT NOW()
)
```

---

## API Mapping to Flutter App

This table shows how each part of the Flutter app maps to the API:

| Flutter Feature | Current Storage | API Endpoint | Sync Strategy |
|----------------|----------------|--------------|---------------|
| User Auth | ❌ None | `POST /api/auth/register`, `POST /api/auth/login` | Login on app start, store JWT in `SharedPreferences` |
| My Profile | Hive `user_box[0]` | `POST/PUT /api/partners` (is_partner=false) | Sync on save, cache in Hive |
| Partner Profile | Hive `user_box[1]` | `POST/PUT /api/partners` (is_partner=true) | Sync on save, cache in Hive |
| Timeline Events | Hive `timeline_box` | `POST/GET/PUT/DELETE /api/journeys` | Sync on CRUD, cache in Hive |
| Reminders | Hive `reminders_box` | `POST/GET/PUT/DELETE /api/reminders` | Sync on CRUD, cache in Hive |
| Theme/Settings | Hive `settings_box` | `GET/PUT /api/settings` | Sync on change, cache in Hive |
| Profile Images | Local file path | `POST /api/upload` → URL | Upload on pick, store URL |
| Partner Linking | ❌ None | `POST/GET/DELETE /api/link` | Share invite code from profile |
| Games/Quotes | Hardcoded `GameData` | N/A (keep local) | Static data, no sync needed |
| Home Widget | `HomeWidget` plugin | N/A (keep local) | Updated after API sync |
| Notifications | `flutter_local_notifications` | N/A (keep local) | Schedule locally after API sync |

---

## Partner Linking Flow (How "Share to Partner" Works)

```
┌──────────────────────────────────────────────────────────────────────┐
│                        PARTNER LINKING FLOW                         │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   USER A (You)                    USER B (Your Partner)              │
│   ┌─────────────┐                ┌─────────────┐                    │
│   │  Registers   │                │  Registers   │                    │
│   │  Gets code:  │                │  Gets code:  │                    │
│   │  "ABC123XY"  │                │  "XYZ789AB"  │                    │
│   └──────┬──────┘                └──────┬──────┘                    │
│          │                               │                           │
│          │    Shares code via            │                           │
│          │    Share button in Profile    │                           │
│          │    section ─────────────────► │                           │
│          │                               │                           │
│          │                        ┌──────┴──────┐                    │
│          │                        │ Enters code  │                    │
│          │                        │ "ABC123XY"   │                    │
│          │                        │ POST /api/   │                    │
│          │                        │   link       │                    │
│          │                        └──────┬──────┘                    │
│          │                               │                           │
│   ┌──────┴───────────────────────┬──────┴──────┐                    │
│   │         LINKED! 🔗                          │                    │
│   │  • Shared partners profiles                 │                    │
│   │  • Shared journeys/timeline                 │                    │
│   │  • Shared reminders                         │                    │
│   │  • Theme matches partner's color            │                    │
│   └─────────────────────────────────────────────┘                    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### In the Flutter App (Profile Section):

1. **"Share Your Code"** button → Shows invite code + native share sheet
2. **"Link with Partner"** button → Text field to enter partner's code
3. **"Connected ✅"** indicator when linked → Shows partner's username
4. **"Unlink"** option in settings danger zone

---

## Setup for Local Development

1. Clone: `git clone https://github.com/Rajiv-Bhandari/Couple-App-Backend.git`
2. Install: `npm install`
3. Copy `.env.example` to `.env` and fill in `DATABASE_URL` and `JWT_SECRET`
4. Run tables: `node lib/setup-db.js`
5. Deploy: push to GitHub → auto-deploys on Vercel
