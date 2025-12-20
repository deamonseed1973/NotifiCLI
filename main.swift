import Foundation
import UserNotifications

// MARK: - Helper Functions

func printUsage() {
    print("Usage: notificli -title <text> -message <text> [-actions <action1,action2>]")
}

// MARK: - Core Logic

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Print the action identifier to stdout
        print(response.actionIdentifier)
        
        // Exit successfully
        completionHandler()
        exit(0)
    }
}

// MARK: - Main Execution

let args = CommandLine.arguments
var title = "Notification"
var message = ""
var actionString = "Dismiss"

// Simple Argument Parsing
if args.count < 3 {
    printUsage()
    exit(1)
}

var i = 1
while i < args.count {
    let arg = args[i]
    if arg == "-title" && i + 1 < args.count {
        title = args[i + 1]
        i += 1
    } else if arg == "-message" && i + 1 < args.count {
        message = args[i + 1]
        i += 1
    } else if arg == "-actions" && i + 1 < args.count {
        actionString = args[i + 1]
        i += 1
    }
    i += 1
}

// Setup Notification Center
let center = UNUserNotificationCenter.current()
let delegate = NotificationDelegate()
center.delegate = delegate

// Request Authorization (Silent mostly for CLI, but good practice)
center.requestAuthorization(options: [.alert, .sound]) { granted, error in
    if let error = error {
        fputs("Error requesting auth: \(error.localizedDescription)\n", stderr)
    }
}

// Create Actions
let actions = actionString.split(separator: ",").map { String($0) }
var notificationActions: [UNNotificationAction] = []

for actionTitle in actions {
    let action = UNNotificationAction(identifier: actionTitle, title: actionTitle, options: [.foreground])
    notificationActions.append(action)
}

// Create Category
let categoryIdentifier = "NOTIFIR_CATEGORY"
let category = UNNotificationCategory(identifier: categoryIdentifier, actions: notificationActions, intentIdentifiers: [], options: [])
center.setNotificationCategories([category])

// Create Content
let content = UNMutableNotificationContent()
content.title = title
content.body = message
content.sound = UNNotificationSound.default
content.categoryIdentifier = categoryIdentifier

// Create Request
let uuidString = UUID().uuidString
let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil) // nil trigger = deliver immediately

// Schedule
center.add(request) { error in
    if let error = error {
        fputs("Error scheduling notification: \(error.localizedDescription)\n", stderr)
        exit(1)
    }
    // Notification scheduled, now we wait for the delegate callback
}

// Run Loop to keep the CLI alive waiting for the delegate
RunLoop.main.run()
