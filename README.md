# Drimble

Regain control of your drinking.

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
