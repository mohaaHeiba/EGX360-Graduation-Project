# 🔄 Integration Guide: Replace Existing Notification Logic

## Overview

You already have notification logic in your controllers. This guide shows how to **replace** the existing notification code with the new `NotificationSenderService` for cleaner, simpler code.

---

## 📍 Integration Points

### 1. Post Details Controller - Comment Notifications

**File**: [`post_details_controller.dart`](file:///home/heiba/Codes/flutter/Projects/egx360/lib/features/post_details/presentation/controller/post_details_controller.dart)

**Current Code** (Lines 191-233):
```dart
Future<void> _sendCommentNotification(...) async {
  // Uses getPeerFcmTokenUseCase + sendNotificationUseCase
  // Complex logic spread across multiple lines
}
```

**Replace With**:
```dart
import 'package:egx/core/services/notification_sender_service.dart';

// In addComment() method, line 183:
// OLD CODE:
_sendCommentNotification(newPost, content, replyingTo.value);

// NEW CODE (simpler!):
if (replyingTo.value != null) {
  // Reply to comment
  await NotificationSenderService.notifyCommentOwner(
    commentOwnerId: replyingTo.value!.userId,
    senderName: Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ?? 'Someone',
    postId: newPost.id,
  );
} else {
  // Comment on post
  await NotificationSenderService.notifyPostOwner(
    ownerId: newPost.userId,
    senderName: Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ?? 'Someone',
    postId: newPost.id,
  );
}
```

**Then DELETE** the entire `_sendCommentNotification` method (lines 191-233).

---

### 2. Post Details Controller - Like Notifications

**File**: [`post_details_controller.dart`](file:///home/heiba/Codes/flutter/Projects/egx360/lib/features/post_details/presentation/controller/post_details_controller.dart)

**Current Code** (Lines 287-307):
```dart
Future<void> _sendLikeNotification(PostEntity likedPost) async {
  // Complex logic
}
```

**Simple Replacement** - In `toggleLike()` method, line 270, replace the call:

```dart
// OLD:
_sendLikeNotification(newPost);

// NEW:
await NotificationSenderService.notifyPostLike(
  postOwnerId: newPost.userId,
  senderName: Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ?? 'Someone',
  postId: newPost.id,
);
```

**Then DELETE** the `_sendLikeNotification` method (lines 287-307).

---

### 3. Profile Controller - New Post Notifications

**File**: [`profile_controller.dart`](file:///home/heiba/Codes/flutter/Projects/egx360/lib/features/profile/presentations/controller/profile_controller.dart)

**Add Notification** in `createPost()` method (after line 489):

```dart
import 'package:egx/core/services/notification_sender_service.dart';

Future<void> createPost() async {
  // ... existing code ...
  
  await createPostUseCase(
    userId: currentUserId,
    content: content,
    imageFile: pickedImage,
    sentiment: selectedSentiment.value,
    cashtags: cashtags,
  );

  // 🆕 ADD THIS - Notify all followers about new post
  final userName = Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ?? 'User';
  await NotificationSenderService.notifyAllFollowers(
    currentUserId: currentUserId,
    currentUserName: userName,
    postId: 0, // We need to get the post ID from createPostUseCase
    postPreview: content,
  );

  Get.back();
  // ... rest of code ...
}
```

**⚠️ Note**: You'll need to modify `createPostUseCase` to return the `postId`:

```dart
// In create_post_usecase.dart
Future<int> call({...}) async {
  return await repository.createPost(...);
}

// In repository
Future<int> createPost({...}) async {
  return await remoteDataSource.createPost(...);
}

// In remote_data_source.dart
Future<int> createPost({...}) async {
  final response = await _supabase.from('posts')
    .insert({...})
    .select('id')
    .single();
  return response['id'] as int;
}
```

---

### 4. Profile Controller - Follow Notifications

**Add in `toggleFollow()` method** (after line 411):

```dart
if (!isFollowing.value) { // Was not following, now following
  final userName = Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ?? 'Someone';
  
  await NotificationSenderService.notifyNewFollow(
    followedUserId: targetUserId,
    followerName: userName,
    followerId: currentUserId,
  );
}
```

---

## 🔧 Setup Firebase Server Key

1. Get your key from Firebase Console → Project Settings → Cloud Messaging → Server Key
2. Open [`notification_sender_service.dart`](file:///home/heiba/Codes/flutter/Projects/egx360/lib/core/services/notification_sender_service.dart)
3. Line 11, replace:
   ```dart
   static const String _firebaseServerKey = 'YOUR_KEY_HERE';
   ```

---

## 🧹 Cleanup - Remove Old Code

### Files to Clean Up:

1. **Remove these imports** from `post_details_controller.dart`:
   ```dart
   // DELETE:
   import 'package:egx/features/notifications/domain/usecase/get_peer_fcm_token_usecase.dart';
   import 'package:egx/features/notifications/domain/usecase/send_notification_usecase.dart';
   ```

2. **Remove these dependencies** from `post_details_controller.dart`:
   ```dart
   // DELETE:
   final GetPeerFcmTokenUseCase getPeerFcmTokenUseCase = Get.find();
   final SendNotificationUseCase sendNotificationUseCase = Get.find();
   ```

3. **Delete these methods**:
   - `_sendCommentNotification()` (lines 191-233)
   - `_sendLikeNotification()` (lines 287-307)

---

## ✅ Benefits of This Approach

| Before | After |
|--------|-------|
| 40+ lines for comment notifications | 8 lines |
| 20+ lines for like notifications | 5 lines |
| Multiple usecase dependencies | 1 service import |
| Complex token fetching | Handled internally |
| Separate logic for reply vs comment | One clean call |

---

## 🧪 Testing

After integration:

1. **Comment on a post** → Post owner receives notification
2. **Reply to a comment** → Comment owner receives notification
3. **Like a post** → Post owner receives notification
4. **Follow someone** → They receive notification
5. **Create a post** → All followers receive notification

---

## 🐛 Troubleshooting

**Notifications not working?**
- Check Firebase Server Key is set correctly
- Verify user has `fcm_token` in database
- Check console logs for error messages

**Still want to use UseCases?**
- You can keep your existing approach if preferred
- The `NotificationSenderService` is just a simpler alternative
- Both methods work fine!
