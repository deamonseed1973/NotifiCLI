import Foundation
import UserNotifications

// MARK: - Argument Parsing
var title: String?
var message: String?
var actions: [String] = []
var imagePath: String?

var args = CommandLine.arguments.dropFirst()
while let arg = args.popFirst() {
    switch arg {
    case "-title":
        title = args.popFirst()
    case "-message":
        message = args.popFirst()
    case "-actions":
        if let actionStr = args.popFirst() {
            actions = actionStr.split(separator: ",").map { String($0) }
        }
    case "-image":
        imagePath = args.popFirst()
    default:
        break
    }
}

guard let notificationTitle = title, let notificationMessage = message else {
    print("Usage: NotifiCLI -title \"Title\" -message \"Message\" [-actions \"Yes,No\"] [-image \"/path/to/image.png\"]")
    exit(1)
}

// MARK: - Notification
let center = UNUserNotificationCenter.current()

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var selectedAction: String?
    let semaphore = DispatchSemaphore(value: 0)
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            selectedAction = "default"
        case UNNotificationDismissActionIdentifier:
            selectedAction = "dismissed"
        default:
            selectedAction = response.actionIdentifier
        }
        completionHandler()
        semaphore.signal()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

let delegate = NotificationDelegate()
center.delegate = delegate

// Request authorization
center.requestAuthorization(options: [.alert, .sound]) { granted, error in
    if let error = error {
        print("Error requesting auth: \(error.localizedDescription)")
    }
}

// Register action category if needed
if !actions.isEmpty {
    let notificationActions = actions.map { actionTitle in
        UNNotificationAction(identifier: actionTitle, title: actionTitle, options: [.foreground])
    }
    let category = UNNotificationCategory(identifier: "ACTIONS_CATEGORY",
                                           actions: notificationActions,
                                           intentIdentifiers: [],
                                           options: [])
    center.setNotificationCategories([category])
}

// Create notification content
let content = UNMutableNotificationContent()
content.title = notificationTitle
content.body = notificationMessage
content.sound = .default

if !actions.isEmpty {
    content.categoryIdentifier = "ACTIONS_CATEGORY"
}

// Add image attachment if specified
if let imagePath = imagePath {
    let imageURL = URL(fileURLWithPath: imagePath)
    if FileManager.default.fileExists(atPath: imagePath) {
        do {
            let attachment = try UNNotificationAttachment(identifier: "image", url: imageURL, options: nil)
            content.attachments = [attachment]
        } catch {
            print("Warning: Could not attach image: \(error.localizedDescription)")
        }
    } else {
        print("Warning: Image not found at \(imagePath)")
    }
}

// Schedule notification
let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

center.add(request) { error in
    if let error = error {
        print("Error scheduling notification: \(error.localizedDescription)")
        exit(1)
    }
}

// Wait for user response
_ = delegate.semaphore.wait(timeout: .distantFuture)

if let action = delegate.selectedAction {
    print(action)
}
