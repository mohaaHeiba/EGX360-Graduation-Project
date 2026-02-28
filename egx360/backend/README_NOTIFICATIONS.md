# EGX360 Push Notification Service

This Python service sends FCM push notifications when the app is closed, similar to the gold scraper.

## 📋 Requirements

```bash
pip install firebase-admin supabase-py
```

## 🔧 Setup

### 1. Get Firebase Service Account
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Save as `service_account.json` in this directory

### 2. Get Supabase Service Role Key
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. **Settings** → **API**
4. Copy the **service_role key** (NOT the anon key!)
5. Update `SUPABASE_SERVICE_KEY` in `send_push_notifications.py`

### 3. Update Configuration

Edit `send_push_notifications.py`:

```python
SUPABASE_SERVICE_KEY = "your_service_role_key_here"
SERVICE_ACCOUNT_PATH = "service_account.json"
```

## 🚀 Running the Service

### Option 1: Run Directly
```bash
python3 send_push_notifications.py
```

### Option 2: Run as Background Service (Linux)

Create systemd service:

```bash
sudo nano /etc/systemd/system/egx360-notifications.service
```

Add this content:

```ini
[Unit]
Description=EGX360 Push Notification Service
After=network.target

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/path/to/egx360/backend
ExecStart=/usr/bin/python3 /path/to/egx360/backend/send_push_notifications.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable egx360-notifications
sudo systemctl start egx360-notifications
sudo systemctl status egx360-notifications
```

View logs:

```bash
sudo journalctl -u egx360-notifications -f
```

## 📊 How It Works

1. **Database Triggers** create notification records when:
   - Someone comments on your post
   - Someone replies to your comment
   - Someone likes your post/comment
   - Someone follows you

2. **Flutter App (Open)**: Uses Supabase Realtime to show in-app notifications instantly

3. **Python Service (App Closed)**: 
   - Monitors the `notifications` table every 2 seconds
   - When new notification found → Sends FCM push notification
   - Similar architecture to your gold price scraper

## 🧪 Testing

1. Make sure the service is running
2. Close your Flutter app completely
3. From another account, comment on a post
4. You should receive a push notification!

## 🐛 Troubleshooting

**No notifications received?**
- Check if service is running: `sudo systemctl status egx360-notifications`
- Verify FCM token is saved in database
- Check service logs for errors

**FCM token not found?**
- Make sure user has granted notification permissions
- Check if `fcm_token` column has value in `profiles` table

**Import errors?**
- Install dependencies: `pip install firebase-admin supabase-py`
