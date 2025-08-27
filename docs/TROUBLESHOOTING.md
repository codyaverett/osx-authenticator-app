# Troubleshooting Guide

## Common Issues and Solutions

### Build Issues

#### Xcode Project Setup
- **Issue**: Project fails to build due to missing permissions
- **Solution**: Ensure proper entitlements are set in project configuration
  - Camera usage for QR scanning
  - Keychain access for secure storage

#### Dependency Issues
- **Issue**: Package dependencies fail to resolve
- **Solution**: 
  - Check Swift Package Manager configuration
  - Verify minimum deployment target compatibility
  - Clear derived data if needed

### Runtime Issues

#### QR Code Input (macOS Version)
- **Issue**: QR code parsing fails
- **Solution**: 
  - Ensure you're pasting the complete otpauth:// URL
  - Check that the URL starts with "otpauth://totp/"
  - Use the "Try Sample" button to test with known good data
  - For Google Authenticator export, look for the migration URL format

#### Keychain Access
- **Issue**: Cannot store/retrieve secrets from keychain
- **Solution**:
  - Verify keychain entitlements
  - Check keychain access group configuration
  - Ensure proper error handling for keychain operations

#### TOTP Generation
- **Issue**: Generated codes don't match other authenticators
- **Solution**:
  - Verify time synchronization
  - Check TOTP algorithm implementation (SHA-1, 30-second intervals)
  - Validate secret key parsing from QR codes

### Development Environment

#### Build System
- **Issue**: Xcode build failures or internal errors
- **Solution**: Use Swift Package Manager instead
  ```bash
  swift build
  swift run Authenticator
  ```

#### macOS Compatibility
- **Issue**: iOS-only SwiftUI features causing build errors
- **Solution**: Remove or replace with macOS-compatible alternatives
  - Avoid `navigationBarTitleDisplayMode`
  - Don't use `.page` TabViewStyle on macOS

#### Code Signing
- **Issue**: App won't run due to signing issues
- **Solution**:
  - Configure proper development team
  - Update provisioning profiles
  - Check entitlements configuration

## Debugging Tips

### Logging
- Use `os_log` for structured logging
- Log keychain operations (without secrets)
- Track TOTP generation timing

### Testing
- Test with known QR codes from Google Authenticator
- Verify against online TOTP generators
- Test keychain persistence across app launches

## Performance Monitoring
- Monitor memory usage during QR scanning
- Track UI responsiveness during code generation
- Profile keychain access performance

---

*This document will be updated as issues are encountered and resolved during development*