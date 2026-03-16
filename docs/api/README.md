# Waslaa Mobile API Documentation

This directory contains the complete API documentation for the **Waslaa** mobile application backend.  
Mobile developers can explore every endpoint, understand request/response shapes, and test calls interactively.

---

## 📂 Files in this directory

| File | Description |
|------|-------------|
| `openapi.yaml` | OpenAPI 3.0 specification — the single source of truth for all endpoints |
| `swagger-ui.html` | Self-contained interactive Swagger UI page (open in any browser) |
| `waslaa-mobile-api.postman_collection.json` | Ready-to-import Postman collection with all requests pre-filled |

---

## 🚀 Quick Start

### Option 1 — Swagger UI (Recommended for interactive testing)

Swagger UI lets you read the docs and fire real HTTP requests without leaving the browser.

**Steps:**
1. Start the Laravel backend: `cd laravel-app && php artisan serve`  
   *(Or run all services at once: `composer run dev`)*
2. Open `docs/api/swagger-ui.html` in your browser  
   *(Chrome / Firefox / Edge — double-click the file or serve it via any HTTP server)*
3. Click **"Authorize"** → paste your Bearer token (obtained from Login)
4. Browse the endpoints, click **"Try it out"**, fill in the fields, hit **"Execute"**

> **Tip:** You can also serve the docs folder with `npx serve docs/api` for a proper HTTP server.

**Preferred alternative — [Stoplight Elements](https://stoplight.io/open-source/elements):**  
You can drag `openapi.yaml` to [editor.swagger.io](https://editor.swagger.io) or [stoplight.io](https://stoplight.io) for an even richer experience.

---

### Option 2 — Postman

Postman is the best tool for saving test scenarios, writing automated tests, and sharing with your team.

**Steps:**
1. Open Postman → **Import** → select `waslaa-mobile-api.postman_collection.json`
2. Create a new **Environment** with variable:
   - `base_url` = `http://localhost:8000` (or your staging/production URL)
3. Open the **Login** request → click **Send**  
   → The test script automatically saves the token to `{{token}}`
4. All authenticated requests inherit `Authorization: Bearer {{token}}`

**Recommended Postman Environment variables:**

| Variable | Example value |
|----------|---------------|
| `base_url` | `http://localhost:8000` |
| `token` | *(auto-filled after Login)* |

---

### Option 3 — Import OpenAPI spec into any tool

`openapi.yaml` follows the **OpenAPI 3.0.3** standard and can be imported into:

| Tool | How to import |
|------|---------------|
| **Insomnia** | Application → Import → From File → `openapi.yaml` |
| **Postman** | Import → `openapi.yaml` (generates collection automatically) |
| **Swagger Editor** | Visit [editor.swagger.io](https://editor.swagger.io) → File → Import File |
| **RapidAPI / Paw** | File → Import OpenAPI |
| **VS Code REST Client** | Use the `openapi.yaml` with extensions like *OpenAPI (Swagger) Editor* |

---

## 🔐 Authentication

Most endpoints require a **Bearer token** from the login response.

```
Authorization: Bearer 1|abc123xyz...
```

### Flow

```
POST /auth/register    →  creates account (status: pending)
POST /auth/verify-otp  →  activates account (OTP: 6666 in dev)
POST /auth/login       →  returns Bearer token
```

> **Development OTP:** The OTP code is always **`6666`** in non-production environments.

---

## 📋 API Summary

| Group | Endpoints | Auth Required |
|-------|-----------|:---:|
| **Authentication** | Register, Verify OTP, Login, Me, Logout, Logout All | ❌ / ✅ |
| **Password** | Forgot, Verify OTP, Reset | ❌ |
| **Content** | About App, Terms, Privacy, About Us | ❌ |
| **Profile** | Show, Update, Change Password, Upload Avatar, Upload CV | ✅ |
| **Specializations** | List | ✅ |
| **Companies** | List, Show | ✅ |
| **Opportunities** | List, Show, Apply | ✅ |
| **Applications** | List, Show, Withdraw | ✅ |
| **Internships** | List, Current, Show, Timeline, Reports | ✅ |
| **Reports** | Show, Download, Delete | ✅ |
| **Chat** | Threads, Messages, Send, Attachments, Mark Read | ✅ |
| **Notifications** | List, Unread Count, Mark Read, Mark All Read | ✅ |
| **Discussion Schedules** | List, Show | ✅ |
| **Settings** | Show, Update | ✅ |

---

## 📦 Response Format

### Success (single resource)
```json
{
  "data": { ...resource fields... }
}
```

### Success (paginated list)
```json
{
  "data": [ ...items... ],
  "links": { "first": "...", "last": "...", "prev": null, "next": "..." },
  "meta": { "current_page": 1, "last_page": 5, "per_page": 15, "total": 75 }
}
```

### Validation error (422)
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email has already been taken."],
    "password": ["The password must be at least 8 characters."]
  }
}
```

---

## 🛠 Common HTTP Status Codes

| Code | Meaning |
|------|---------|
| `200` | OK |
| `201` | Created |
| `401` | Unauthenticated — missing or invalid token |
| `403` | Forbidden — you don't own this resource |
| `404` | Not Found |
| `422` | Validation Error — check `errors` field |
| `500` | Server Error |

---

## 📁 File Upload Limits

| Upload Type | Allowed Formats | Max Size |
|-------------|-----------------|----------|
| Profile avatar | jpg, jpeg, png, webp | 5 MB |
| CV / Resume | pdf, doc, docx | 10 MB |
| Application CV | pdf, doc, docx | 10 MB |
| Internship report | pdf, doc, docx | 10 MB |
| Chat attachment | Any | 15 MB |

---

## 🔄 Pagination

All list endpoints accept a `per_page` query parameter (default: 15, max: 100).

```
GET /api/mobile/v1/opportunities?per_page=25&page=2
```
