# Release Guidelines & Commands

## 🚀 Pre-Release Checklist
1. **Analysis**: Run `fvm flutter analyze` - must be 100% clean.
2. **Cleanup**: Remove all `print()` statements and debug overrides.
3. **Release Mode**: Test on a physical device using `fvm flutter run --release`.
4. **Versioning**: Bump `version` in `pubspec.yaml` if breaking changes were made to the metric logic.

## 🛠️ Build Commands

### Android
```bash
# Build Release AAB
fvm flutter build appbundle --release

# Build Release APK
fvm flutter build apk --release
```

### iOS
```bash
# Build Release IPA
fvm flutter build ipa --release
```

## 📋 Benchmarking Best Practices
- **Thermal State**: Do not run benchmarks if the device is hot to the touch (results will be skewed by CPU throttling).
- **Background Apps**: Close all other apps.
- **Orientation**: Keep the device in a consistent orientation (Portrait) for all races.
- **Reporting**: Always report the average of 3 consecutive runs for any published comparison.
