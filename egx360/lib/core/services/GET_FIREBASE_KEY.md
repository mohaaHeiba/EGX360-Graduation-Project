# 🔑 How to Get Your Firebase Server Key

## What You Have vs What You Need

You currently have:
- ✅ `service_account.json` - For Firebase Admin SDK (Python backend)

You need:
- ⚠️ **Firebase Server Key** - For client-side FCM HTTP API

## 📍 Where to Find Firebase Server Key

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **egx360-notifs**

### Step 2: Navigate to Cloud Messaging Settings
1. Click the **⚙️ Settings** icon (top left)
2. Click **Project settings**
3. Go to the **Cloud Messaging** tab

### Step 3: Get the Server Key
You'll see two sections:

#### Cloud Messaging API (V1)
- This uses OAuth 2.0 (more secure but complex)
- **Skip this for now**

#### Cloud Messaging API (Legacy) ✅
- Scroll down to find this section
- Look for **Server key**
- Copy the key that looks like:
  ```
  AAAAxxxxxx:APA91bHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ```

### Step 4: Update Your Code
Open [`notification_sender_service.dart`](file:///home/heiba/Codes/flutter/Projects/egx360/lib/core/services/notification_sender_service.dart) and replace line 11:

```dart
static const String _firebaseServerKey = 'AAAAxxxxxx:APA91bHxxxxx...';
```

---

## ⚠️ IMPORTANT: Security Warning

**The Firebase Server Key is sensitive!** 

### Current Setup (Client-Side)
```
❌ Server key is exposed in your app code
❌ Anyone can decompile your app and see it
❌ Risk of abuse/spam notifications
```

### Recommended Production Setup

You have **two better options**:

#### Option 1: Use Backend (Python Service) ✅ RECOMMENDED
This is the Python script I created earlier:
- Server key stays on **your backend server only**
- More secure
- Similar to your gold scraper
- File: `backend/send_push_notifications.py`

**Benefits:**
- ✅ Server key is never exposed
- ✅ Works even when user deletes app
- ✅ Centralized notification management
- ✅ Can send notifications from anywhere (admin panel, cron jobs, etc.)

#### Option 2: Supabase Edge Functions
- Server key stays in environment variables
- No server needed
- Still secure

---

## 🚀 Quick Decision Guide

### Use Client-Side (Current Approach) If:
- ✅ You're prototyping/testing
- ✅ You want something working quickly
- ✅ You don't care about key exposure for now
- ⚠️ **Not recommended for production**

### Use Python Backend If:
- ✅ You want production-ready security
- ✅ You already have server infrastructure
- ✅ You're familiar with your gold scraper setup
- ✅ **This is what I recommend!**

### Use Supabase Edge Functions If:
- ✅ You want serverless
- ✅ You don't want to manage servers
- ✅ You want secure but simple

---

## 🔄 My Recommendation

**For your use case**, I recommend:

1. **Short term** (right now):
   - Use the client-side approach to test everything works
   - Get the Server Key from Firebase Console
   - Test all notification types

2. **Production** (before launch):
   - Use the Python backend service (like your gold scraper)
   - It's more secure
   - You already know how to deploy Python services
   - Just run `python3 backend/send_push_notifications.py`

---

## 📝 If You Want to Use Python Backend Instead

The Python service I created earlier uses your `service_account.json` file (which you already have!).

**Setup:**
```bash
cd backend
pip install firebase-admin supabase-py
python3 send_push_notifications.py
```

That's it! No server key needed in the client code. ✅

---

## ❓ Which approach do you want?

1. **Testing now** → Get Server Key from Firebase Console
2. **Production secure** → Use Python backend (you already have `service_account.json`)
3. **Both** → Use client-side for testing, switch to Python later

Let me know which path you prefer!
