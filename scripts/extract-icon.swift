import AppKit
import Foundation

// A simple helper to extract an application's icon using NSWorkspace.
// Usage: swift extract-icon.swift "/Applications/Calendar.app" "/path/to/output.png"

let arguments = CommandLine.arguments
guard arguments.count >= 3 else {
    print("Usage: swift extract-icon.swift <app_path> <output_path>")
    exit(1)
}

let appPath = arguments[1]
let outputPath = arguments[2]

let icon = NSWorkspace.shared.icon(forFile: appPath)
icon.size = NSSize(width: 1024, height: 1024)

guard let tiffData = icon.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    print("Error: Could not convert icon to PNG")
    exit(1)
}

do {
    try pngData.write(to: URL(fileURLWithPath: outputPath))
    // print("Successfully extracted icon to \(outputPath)")
} catch {
    print("Error writing icon: \(error.localizedDescription)")
    exit(1)
}
