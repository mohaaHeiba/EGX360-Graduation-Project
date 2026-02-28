# NotificationSenderService - Usage Examples

## 🎯 Overview

This service sends FCM push notifications **directly from your Flutter app** - no backend needed!

## 📝 Setup

### 1. Get Your Firebase Server Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. **Project Settings** → **Cloud Messaging** tab
4. Copy the **Server Key** (under Cloud Messaging API - Legacy)

### 2. Update the Service

Edit [`notification_sender_service.dart`](file:///home/heiba/Codes/flutter/Projects/egx360/lib/core/services/notification_sender_service.dart) line 11:

```dart
static const String _firebaseServerKey = 'YOUR_KEY_HERE'; // ⚠️ Replace
```

### 3. Add HTTP Package

Make sure `http` is in your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.0
```

## 🔧 Usage Examples

### Example 1: Notify Post Owner When Someone Comments

```dart
import 'package:egx/core/services/notification_sender_service.dart';

// Inside your comment submission function
Future<void> addComment(int postId, String content) async {
  try {
    final currentUser = Supabase.instance.client.auth.currentUser!;
    
    // 1. Get post details to find the owner
    final postResponse = await Supabase.instance.client
        .from('posts')
        .select('user_id')
        .eq('id', postId)
        .single();
    
    final postOwnerId = postResponse['user_id'] as String;
    
    // 2. Insert the comment
    await Supabase.instance.client.from('comments').insert({
      'user_id': currentUser.id,
      'post_id': postId,
      'content': content,
    });
    
    // 3. 🔔 Send push notification to post owner
    await NotificationSenderService.notifyPostOwner(
      ownerId: postOwnerId,
      senderName: currentUser.userMetadata?['name'] ?? 'Someone',
      postId: postId,
    );
    
    print('✅ Comment added and notification sent!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Example 2: Notify All Followers When Creating a Post

```dart
import 'package:egx/core/services/notification_sender_service.dart';

// Inside your "Publish Post" button
Future<void> publishPost({
  required String content,
  String? imageUrl,
}) async {
  try {
    final currentUser = Supabase.instance.client.auth.currentUser!;
    final userName = currentUser.userMetadata?['name'] ?? 'User';
    
    // 1. Insert the post
    final response = await Supabase.instance.client
        .from('posts')
        .insert({
          'user_id': currentUser.id,
          'content': content,
          'image_url': imageUrl,
        })
        .select('id')
        .single();
    
    final newPostId = response['id'] as int;
    
    // 2. 🔔 Notify all followers about the new post
    await NotificationSenderService.notifyAllFollowers(
      currentUserId: currentUser.id,
      currentUserName: userName,
      postId: newPostId,
      postPreview: content, // First 30 chars will be shown
    );
    
    print('✅ Post published and followers notified!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Example 3: Notify When Someone Replies to a Comment

```dart
// Inside your reply submission function
Future<void> replyToComment({
  required int postId,
  required int parentCommentId,
  required String content,
}) async {
  try {
    final currentUser = Supabase.instance.client.auth.currentUser!;
    final userName = currentUser.userMetadata?['name'] ?? 'Someone';
    
    // 1. Get parent comment owner
    final parentComment = await Supabase.instance.client
        .from('comments')
        .select('user_id')
        .eq('id', parentCommentId)
        .single();
    
    final commentOwnerId = parentComment['user_id'] as String;
    
    // 2. Insert the reply
    await Supabase.instance.client.from('comments').insert({
      'user_id': currentUser.id,
      'post_id': postId,
      'parent_id': parentCommentId,
      'content': content,
    });
    
    // 3. 🔔 Notify comment owner about the reply
    await NotificationSenderService.notifyCommentOwner(
      commentOwnerId: commentOwnerId,
      senderName: userName,
      postId: postId,
    );
    
    print('✅ Reply added and notification sent!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Example 4: Notify When Someone Likes Your Post

```dart
// Inside your like button function
Future<void> toggleLike(int postId) async {
  try {
    final currentUser = Supabase.instance.client.auth.currentUser!;
    final userName = currentUser.userMetadata?['name'] ?? 'Someone';
    
    // 1. Get post owner
    final post = await Supabase.instance.client
        .from('posts')
        .select('user_id')
        .eq('id', postId)
        .single();
    
    final postOwnerId = post['user_id'] as String;
    
    // 2. Add like to database
    await Supabase.instance.client.from('post_votes').insert({
      'user_id': currentUser.id,
      'post_id': postId,
      'vote_type': 1, // 1 = like
    });
    
    // 3. 🔔 Notify post owner
    await NotificationSenderService.notifyPostLike(
      postOwnerId: postOwnerId,
      senderName: userName,
      postId: postId,
    );
    
    print('✅ Like added and notification sent!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Example 5: Notify When Someone Follows You

```dart
// Inside your follow button function
Future<void> followUser(String userIdToFollow) async {
  try {
    final currentUser = Supabase.instance.client.auth.currentUser!;
    final userName = currentUser.userMetadata?['name'] ?? 'Someone';
    
    // 1. Add follow to database
    await Supabase.instance.client.from('follows').insert({
      'follower_id': currentUser.id,
      'following_id': userIdToFollow,
    });
    
    // 2. 🔔 Notify the user being followed
    await NotificationSenderService.notifyNewFollow(
      followedUserId: userIdToFollow,
      followerName: userName,
      followerId: currentUser.id,
    );
    
    print('✅ Followed and notification sent!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

## 🎨 GetX Controller Integration Example

If you're using GetX, here's how to integrate it:

```dart
class PostDetailsController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  // Add comment with notification
  Future<void> submitComment(int postId, String content) async {
    try {
      // Show loading
      Get.dialog(const Center(child: CircularProgressIndicator()));
      
      // Get current user info
      final currentUser = _supabase.auth.currentUser!;
      final userName = currentUser.userMetadata?['name'] ?? 'User';
      
      // Get post owner
      final post = await _supabase
          .from('posts')
          .select('user_id')
          .eq('id', postId)
          .single();
      
      // Insert comment
      await _supabase.from('comments').insert({
        'user_id': currentUser.id,
        'post_id': postId,
        'content': content,
      });
      
      // 🔔 Send notification
      await NotificationSenderService.notifyPostOwner(
        ownerId: post['user_id'],
        senderName: userName,
        postId: postId,
      );
      
      // Close loading and show success
      Get.back();
      Get.snackbar('Success', 'Comment added!');
      
      // Refresh comments
      await fetchComments(postId);
      
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to add comment: $e');
    }
  }
}
```

## ⚙️ Important Notes

### ⚠️ Security Considerations

**IMPORTANT:** This approach exposes your Firebase Server Key in the client code. For production apps, consider:

1. **Use Cloud Functions** (Firebase Functions or Supabase Edge Functions) to keep the key server-side
2. **Use the Python backend** approach for better security
3. **Enable App Check** in Firebase to prevent abuse

### 📊 Rate Limiting

- FCM has rate limits per project
- The `notifyAllFollowers` function includes a 100ms delay between sends
- For users with many followers (1000+), consider batching or using multicast messages

### 🔄 Background Execution

- These notifications are sent **immediately** when you call the function
- They work even if the recipient's app is closed
- No need for background services or schedulers

## 🧪 Testing

1. **Update Firebase Server Key** in the service
2. **Run your app** on a device/emulator
3. **Perform an action** (comment, like, follow)
4. **Check logs** for `✅ FCM notification sent successfully`
5. **Close the recipient's app** and verify notification appears

## 🐛 Troubleshooting

**Notifications not sending?**
- ✅ Check if Firebase Server Key is correct
- ✅ Verify recipient has `fcm_token` in database
- ✅ Check console logs for error messages
- ✅ Ensure FCM is enabled in Firebase Console

**Getting 401 Unauthorized?**
- ❌ Wrong Firebase Server Key
- ❌ Using Project ID instead of Server Key
- ❌ Cloud Messaging API not enabled

**Notifications arrive but don't navigate?**
- ✅ Check data payload includes `post_id`
- ✅ Verify `NotificationService.handleNotificationTap` is working
- ✅ Test deep linking with `click_action`
