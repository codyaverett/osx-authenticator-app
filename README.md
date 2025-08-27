# macOS 2FA Authenticator

A native macOS application for managing Google Authenticator 2FA codes with QR code import functionality.

## Features

- **Native macOS Interface**: Built with SwiftUI for a modern, native experience
- **QR Code Import**: Import accounts by pasting QR code content from Google Authenticator
- **Secure Storage**: All 2FA secrets stored securely in macOS Keychain
- **Real-time Codes**: TOTP codes update automatically with countdown timers
- **Account Management**: Add, edit, and organize your 2FA accounts

## Requirements

- macOS 13.0 or later
- Swift 5.8 or later (for development)

## Development

### Getting Started

1. Clone the repository
2. Build using Swift Package Manager:
   ```bash
   swift build
   ```
3. Run the application:
   ```bash
   swift run Authenticator
   ```

### Alternative: Xcode Development
You can also open the project in Xcode by opening `Package.swift`, though command-line building is recommended for best compatibility.

### Project Structure

- `Authenticator/App/` - Main application files
- `Authenticator/Models/` - Data models and business logic
- `Authenticator/Views/` - SwiftUI views and UI components
- `Authenticator/Services/` - Core services (Keychain, TOTP, QR parsing)
- `docs/` - Project documentation and development notes

### Documentation

- [Project Plan](docs/PROJECT_PLAN.md) - Complete technical architecture and implementation plan
- [Development Log](docs/DEVELOPMENT_LOG.md) - Progress tracking and development notes
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## Security

- All 2FA secrets are stored using macOS Keychain Services
- No sensitive data is stored in plain text or user preferences
- Proper access controls and entitlements are configured

## License

*License to be determined*