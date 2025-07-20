package com.app.firebasenotifications

import android.app.NotificationManager
import android.app.PendingIntent
import android.app.RemoteInput
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "chat_app/background"
    private val NOTIFICATIONS_CHANNEL = "chat_app/notifications"
    private val REPLY_ACTION = "com.onesignalnoti.REPLY_ACTION"
    private val KEY_TEXT_REPLY = "key_text_reply"
    
    private lateinit var methodChannel: MethodChannel
    private lateinit var notificationsChannel: MethodChannel
    private lateinit var replyReceiver: BroadcastReceiver
    private lateinit var notificationHelper: NotificationHelper
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize notification helper
        notificationHelper = NotificationHelper(this)
        
        // Setup method channels for Flutter communication
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            // Background operations channel
            methodChannel = MethodChannel(messenger, CHANNEL)
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateBadgeCount" -> {
                        // Update app badge count (Android doesn't have native badges)
                        result.success(null)
                    }
                    "sendReplyFromNotification" -> {
                        val message = call.argument<String>("message")
                        val chatId = call.argument<String>("chatId")
                        val senderId = call.argument<String>("senderId")
                        handleReplyFromNotification(message, chatId, senderId)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
            
            // Notifications channel
            notificationsChannel = MethodChannel(messenger, NOTIFICATIONS_CHANNEL)
            notificationsChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "showNotificationWithReply" -> {
                        val title = call.argument<String>("title") ?: "New Message"
                        val message = call.argument<String>("message") ?: ""
                        val chatId = call.argument<String>("chatId") ?: ""
                        val senderId = call.argument<String>("senderId") ?: ""
                        
                        notificationHelper.showNotificationWithReply(title, message, chatId, senderId)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        
        // Setup broadcast receiver for reply actions
        replyReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == REPLY_ACTION) {
                    val remoteInput = RemoteInput.getResultsFromIntent(intent)
                    val replyText = remoteInput?.getCharSequence(KEY_TEXT_REPLY)?.toString()
                    val chatId = intent.getStringExtra("chatId")
                    val senderId = intent.getStringExtra("senderId")
                    
                    if (replyText != null && chatId != null && senderId != null) {
                        handleReplyFromNotification(replyText, chatId, senderId)
                    }
                }
            }
        }
        
        registerReceiver(replyReceiver, IntentFilter(REPLY_ACTION))
    }
    
    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(replyReceiver)
    }
    
    private fun handleReplyFromNotification(message: String?, chatId: String?, senderId: String?) {
        // Send reply message data back to Flutter
        val data = mapOf(
            "message" to message,
            "chatId" to chatId,
            "senderId" to senderId,
            "type" to "notification_reply"
        )
        
        methodChannel.invokeMethod("onNotificationReply", data)
        
        // Cancel the notification after reply
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(chatId.hashCode())
    }
}
