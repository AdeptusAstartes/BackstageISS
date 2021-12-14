//
//  NotificationManager.swift
//  BackstageISS
//
//  Created by Donald Angelillo on 12/14/21.
//

import UIKit

class NotificationManager {
    
    static let sharedNotificationManager = NotificationManager()

    func requestNotificationAuthorization(completion: @escaping (_ success: Bool) -> ()) {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
            completion(success)
        }
    }
    
    func scheduleISSPassNotification(timestamp: Double) {
        // Make sure we unschedule any existing notifications first so we don't cause duplicate notifications.
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "ISS Is Overhead!"
        notificationContent.body = "The ISS is passing over your location right now!"
        
        // Set the trigger to be the difference in seconds between now and the predicted pass time.
        let timeInterval = Date(timeIntervalSince1970: timestamp).timeIntervalSince(Date())
        
        guard timeInterval > 0 else {
            return
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: "ISSOverheadNotification", content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
}
