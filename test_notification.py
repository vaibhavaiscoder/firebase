#!/usr/bin/env python3
"""
Firebase Notification Test Script

This script helps you test Firebase notifications by sending test messages
to your Flutter app. You'll need your FCM token from the app.

Usage:
    python test_notification.py --token YOUR_FCM_TOKEN --title "Test Title" --body "Test Message"
"""

import argparse
import json
import requests
import sys

def send_notification(server_key, fcm_token, title, body, data=None):
    """
    Send a notification using Firebase Cloud Messaging API
    """
    url = "https://fcm.googleapis.com/fcm/send"
    
    headers = {
        "Authorization": f"key={server_key}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "to": fcm_token,
        "notification": {
            "title": title,
            "body": body,
            "sound": "default",
            "badge": "1"
        },
        "data": data or {},
        "priority": "high",
        "content_available": True
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        
        result = response.json()
        
        if result.get("success") == 1:
            print("✅ Notification sent successfully!")
            print(f"Message ID: {result.get('message_id', 'N/A')}")
        else:
            print("❌ Failed to send notification")
            print(f"Error: {result}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Error sending notification: {e}")
        return False
    
    return True

def main():
    parser = argparse.ArgumentParser(description="Send Firebase notification test")
    parser.add_argument("--server-key", required=True, help="Firebase Server Key")
    parser.add_argument("--token", required=True, help="FCM Token from the app")
    parser.add_argument("--title", default="Test Notification", help="Notification title")
    parser.add_argument("--body", default="This is a test notification", help="Notification body")
    parser.add_argument("--message-id", help="Custom message ID")
    parser.add_argument("--sender-id", help="Sender ID")
    parser.add_argument("--sender-name", help="Sender name")
    
    args = parser.parse_args()
    
    # Prepare data payload
    data = {}
    if args.message_id:
        data["message_id"] = args.message_id
    if args.sender_id:
        data["sender_id"] = args.sender_id
    if args.sender_name:
        data["sender_name"] = args.sender_name
    
    print("🚀 Sending Firebase notification...")
    print(f"Title: {args.title}")
    print(f"Body: {args.body}")
    print(f"FCM Token: {args.token[:50]}...")
    print(f"Data: {data}")
    print("-" * 50)
    
    success = send_notification(
        args.server_key,
        args.token,
        args.title,
        args.body,
        data
    )
    
    if success:
        print("\n📱 Check your device for the notification!")
        print("💡 Test different app states:")
        print("   - Foreground: App is open")
        print("   - Background: App is minimized")
        print("   - Terminated: App is completely closed")

if __name__ == "__main__":
    main() 