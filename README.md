# Drimble

Regain control of your drinking.

## Setting up the dev environment

Before you can start developing, you need to run the build runner at least once. 
To do that, either run one of the VSCode build task, or run `dart run build_runner build` in the command line. 

## Running tests

To be able to run the integration tests, you need to run `flutter pub realm install` before. This will download the necessary Realm binaries for your platform.

## Running a release version

### Android

You'll need your signing config set up. To do so, create a `key.properties` file in the `android` folder with the following content:

```properties
storePassword=...
keyPassword=...
keyAlias=...
storeFile=...
```

The default path is `C:\Users\USERNAME\.android\debug.keystore` on Windows and `~/.android/debug.keystore` on Linux and macOS. 
The default password for both the key and the store is `android`, the default alias is `androiddebugkey`.

Then, run `flutter build appbundle --release` to build the release version.

## Releasing a new version

All our release management is done using `fastlane` to ensure consistency across machines.

Beta versions are released using Firebase App Distribution.

### iOS

Navigate into the iOS directory and run `fastlane beta`. This should build and release the app to Firebase App Distribution.

### Android

Navigate into the Android directory and run `fastlane beta`. This should build and release the app to Firebase App Distribution.
