#!/bin/bash
cd $ENV_PROJECT_FOLDER/$ENV_ANDROID_PROJECT_PATH && ./gradlew assembleRelease
cd $ENV_APK_PATH/release
zipalign -v 4 app-release-unsigned.apk app-release-zip.apk
echo $ENV_APP_KEYSTORE | base64 --decode > app.keystore 
apksigner sign -v --ks app.keystore --ks-key-alias $ENV_APK_ALIAS --ks-pass pass:$ENV_APP_KEYSTORE_KEY_PW --v2-signing-enabled true app-release-zip.apk
