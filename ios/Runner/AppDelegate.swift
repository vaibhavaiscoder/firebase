import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Configure notification categories for reply actions
    setupNotificationCategories()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupNotificationCategories() {
    let replyAction = UNTextInputNotificationAction(
      identifier: "REPLY_ACTION",
      title: "Reply",
      options: [.foreground],
      textInputButtonTitle: "Send",
      textInputPlaceholder: "Type your message..."
    )
    
    let chatCategory = UNNotificationCategory(
      identifier: "CHAT_MESSAGE",
      actions: [replyAction],
      intentIdentifiers: [],
      options: [.customDismissAction]
    )
    
    UNUserNotificationCenter.current().setNotificationCategories([chatCategory])
  }
  
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if response.actionIdentifier == "REPLY_ACTION" {
      if let textResponse = response as? UNTextInputNotificationResponse {
        let userText = textResponse.userText
        let userInfo = response.notification.request.content.userInfo
        
        // Handle reply action
        handleNotificationReply(
          message: userText,
          chatId: userInfo["chatId"] as? String ?? "",
          senderId: userInfo["senderId"] as? String ?? ""
        )
      }
    }
    
    completionHandler()
  }
  
  private func handleNotificationReply(message: String, chatId: String, senderId: String) {
    // Send reply data to Flutter
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "chat_app/background",
        binaryMessenger: controller.binaryMessenger
      )
      
      channel.invokeMethod("onNotificationReply", arguments: [
        "message": message,
        "chatId": chatId,
        "senderId": senderId,
        "type": "notification_reply"
      ])
    }
  }
}
