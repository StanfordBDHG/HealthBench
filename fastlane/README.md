fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Build and test

### ios test_iphone

```sh
[bundle exec] fastlane ios test_iphone
```

Build and test for iPhone

### ios test_ipad

```sh
[bundle exec] fastlane ios test_ipad
```

Build and test for iPad

### ios test_apple_watch

```sh
[bundle exec] fastlane ios test_apple_watch
```

Build and test for Apple Watch

### ios test_apple_tv

```sh
[bundle exec] fastlane ios test_apple_tv
```

Build and test for Apple TV

### ios test_vision_pro

```sh
[bundle exec] fastlane ios test_vision_pro
```

Build and test for Vision Pro

### ios test_macos

```sh
[bundle exec] fastlane ios test_macos
```

Build and test for macOS

### ios codeql

```sh
[bundle exec] fastlane ios codeql
```

CodeQL

### ios build

```sh
[bundle exec] fastlane ios build
```

Build app

### ios signin

```sh
[bundle exec] fastlane ios signin
```

Sign in to the App Store Connect API

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Publish a beta release to internal TestFlight testers

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
