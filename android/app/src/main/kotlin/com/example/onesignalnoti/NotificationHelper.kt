package com.example.onesignalnoti

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.RemoteInput

class NotificationHelper(private val context: Context) {
    
    companion object {
        private const val CHANNEL_ID = "chat_notifications"
        private const val CHANNEL_NAME = "Chat Messages"
        private const val CHANNEL_DESCRIPTION = "Notifications for chat messages"
        private const val REPLY_ACTION = "com.onesignalnoti.REPLY_ACTION"
        private const val KEY_TEXT_REPLY = "key_text_reply"
    }
    
    init {
        createNotificationChannel()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = CHANNEL_DESCRIPTION
                enableVibration(true)
                enableLights(true)
            }
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    fun showNotificationWithReply(
        title: String,
        message: String,
        chatId: String,
        senderId: String
    ) {
        val replyLabel = "Reply"
        val remoteInput = RemoteInput.Builder(KEY_TEXT_REPLY)
            .setLabel(replyLabel)
            .build()
        
        // Create the reply action
        val replyIntent = Intent(REPLY_ACTION).apply {
            putExtra("chatId", chatId)
            putExtra("senderId", senderId)
        }
        
        val replyPendingIntent = PendingIntent.getBroadcast(
            context,
            chatId.hashCode(),
            replyIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        
        val replyAction = NotificationCompat.Action.Builder(
            android.R.drawable.ic_menu_send,
            replyLabel,
            replyPendingIntent
        )
            .addRemoteInput(remoteInput)
            .build()
        
        // Create the main notification intent
        val mainIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("chatId", chatId)
            putExtra("senderId", senderId)
        }
        
        val mainPendingIntent = PendingIntent.getActivity(
            context,
            0,
            mainIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Build the notification
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_email)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setAutoCancel(true)
            .setContentIntent(mainPendingIntent)
            .addAction(replyAction)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .build()
        
        // Show the notification
        with(NotificationManagerCompat.from(context)) {
            notify(chatId.hashCode(), notification)
        }
    }
}
