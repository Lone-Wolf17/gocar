# gocar

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Google Authentication

- First Activate on FireBase
- Generate Key info : https://developers.google.com/android/guides/client-auth
    cmd: keytool -list -v -keystore C:\Users\italo\.android\debug.keystore --alias  androiddebugkey -storepass android -keypass android  
                   GoCar key is : 60:AA:67:2C:3E:0B:6A:94:84:04:4C:BE:32:E1:E7:E9:27:CE:BE:07
- After generating key add new android project in firebase and add the key
- Download the json with the key
- Paste inside Android / App folder
- Put in build.gradle
        buildscript {
          dependencies {
            // Add this line
            classpath 'com.google.gms:google-services:4.2.0'
          }
        }
            
         google_sign_in: ^4.0.0
           firebase_core: ^0.4.0+8   
           
           
           
 ##Flutter Launcher Icons
 flutter pub run flutter_launcher_icons:main
 
 

 
 
 ## ScreenShot

<img src="https://fluttaxi.s3.amazonaws.com/image/store/full.png" height="500em" />
