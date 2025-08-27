import SwiftUI
import Foundation
import AppKit

extension Color {
    static let systemBackground = Color(NSColor.controlBackgroundColor)
    static let secondarySystemBackground = Color(NSColor.controlColor)
}

extension String {
    func formattedAsCode() -> String {
        guard count == 6 else { return self }
        let index = self.index(startIndex, offsetBy: 3)
        let firstPart = String(self[..<index])
        let secondPart = String(self[index...])
        return "\(firstPart) \(secondPart)"
    }
}