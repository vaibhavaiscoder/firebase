package com.example.firebasenotifications

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.firebasenotifications/notification"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Handle notification actions
        handleNotificationIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        
        // Handle notification actions when app is already running
        handleNotificationIntent(intent)
    }
    
    private fun handleNotificationIntent(intent: Intent) {
        val action = intent.action
        val data = intent.dataString
        
        if (action == "FLUTTER_NOTIFICATION_CLICK" || action == "android.intent.action.MAIN") {
            // Handle notification tap
            val messageId = intent.getStringExtra("message_id")
            val replyText = intent.getStringExtra("reply_text")
            
            if (messageId != null) {
                // Send data to Flutter
                sendNotificationDataToFlutter(messageId, replyText)
            }
        }
    }
    
    private fun sendNotificationDataToFlutter(messageId: String, replyText: String?) {
        // This will be handled by the Flutter side
        // You can implement method channel communication here if needed
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up method channel for communication with Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "handleNotificationAction" -> {
                    val messageId = call.argument<String>("messageId")
                    val action = call.argument<String>("action")
                    val replyText = call.argument<String>("replyText")
                    
                    // Handle the notification action
                    handleNotificationAction(messageId, action, replyText)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun handleNotificationAction(messageId: String?, action: String?, replyText: String?) {
        // Handle different notification actions
        when (action) {
            "reply" -> {
                // Handle reply action
                if (messageId != null && replyText != null) {
                    // Send reply to your backend
                    sendReplyToBackend(messageId, replyText)
                }
            }
            "mark_read" -> {
                // Handle mark as read action
                if (messageId != null) {
                    markMessageAsRead(messageId)
                }
            }
        }
    }
    
    private fun sendReplyToBackend(messageId: String, replyText: String) {
        // Implement your API call to send reply
        // This is where you would make an HTTP request to your backend
        println("Sending reply: $replyText to message: $messageId")
    }
    
    private fun markMessageAsRead(messageId: String) {
        // Implement your API call to mark message as read
        println("Marking message as read: $messageId")
    }
}
