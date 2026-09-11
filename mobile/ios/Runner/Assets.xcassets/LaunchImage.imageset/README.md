# Serenity Hub Launch Screen Assets

This directory contains the iOS launch image assets used by the Flutter runner before Dart code starts.

To customize the launch screen, replace the PNG files in this directory or open the Flutter iOS workspace with:

```bash
open ios/Runner.xcworkspace
```

Then select `Runner/Assets.xcassets` in Xcode and drop in the desired launch images.

These images only affect the native launch screen. Serenity Hub app content, remote media, breathing sessions, and the audio/video library are loaded by Flutter and the Laravel API after startup.
