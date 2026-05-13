@echo on
set JAVA_HOME=D:\java\jdk-21.0.11+10
set ANDROID_HOME=D:\android
set ANDROID_SDK_ROOT=D:\android
set GRADLE_USER_HOME=D:\.gradle
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
set PUB_HOSTED_URL=https://pub.flutter-io.cn
cd /d D:\vocabulary_app
echo === Starting Flutter Build ===
D:\flutter\flutter\bin\flutter.bat build apk --release 2>&1
set BUILD_RESULT=%ERRORLEVEL%
echo === Exit code: %BUILD_RESULT% ===
if exist build\app\outputs\flutter-apk\app-release.apk (
    echo RELEASE APK FOUND
    dir build\app\outputs\flutter-apk\app-release.apk
) else (
    echo RELEASE APK NOT FOUND
    if exist build\app\outputs\flutter-apk\app-debug.apk (
        echo But DEBUG APK exists
        dir build\app\outputs\flutter-apk\app-debug.apk
    )
)
