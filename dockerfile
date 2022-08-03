FROM openjdk:11-jdk-oraclelinux7

ARG CACHEBUSTER=4
ARG PROJECT_PATH="app-name"
ARG ANDROID_PROJECT_PATH="projects/client/android"
ARG APK_PATH="projects/client/android/app/build/outputs/apk"
ARG APK_ALIAS="keystore alias"
ARG APP_KEYSTORE="invalid keystore value"
ARG APP_KEYSTORE_PW=""
ARG APP_KEYSTORE_KEY_PW=""
ARG PROJECT_FOLDER="/"

# DO NOT FORGET TO DEFINE ENVS APP_FOLDER AND ENV_APK_PATH
ENV ENV_PROJECT_PATH=$PROJECT_PATH
ENV ENV_PROJECT_FOLDER=$PROJECT_FOLDER
ENV ENV_ANDROID_PROJECT_PATH=$ANDROID_PROJECT_PATH
ENV ENV_APK_PATH=$APK_PATH
ENV ENV_APK_ALIAS=$APK_ALIAS
ENV ENV_APP_KEYSTORE=$APP_KEYSTORE
ENV ENV_APP_KEYSTORE_PW=$APP_KEYSTORE_PW
ENV ENV_APP_KEYSTORE_KEY_PW=$APP_KEYSTORE_KEY_PW 
ENV ENV_BUILD_TOOLS_VERSION="30.0.2"


# install common deps
RUN yum update
RUN yum -y install wget
RUN yum -y install unzip

# install nodejs and npm
RUN yum -y install curl
RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash -
RUN yum install -y nodejs
RUN npm -v

# download android sdk
RUN mkdir android-sdk
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip
RUN unzip commandlinetools-linux-6200805_latest -d /android-sdk/
RUN rm -rf commandlinetools-linux-6200805_latest

# setup environment variables
#java
ENV PATH $PATH:$JAVA_HOME/bin/
# android and tools
ENV ANDROID_HOME /android-sdk
ENV ANDROID_SDK_ROOT $ANDROID_HOME
ENV PATH $PATH:$ANDROID_SDK_ROOT/tools/bin
ENV PATH $PATH:$ANDROID_SDK_ROOT/platform-tools/bin

# setup sdkmanager
RUN /android-sdk/tools/bin/sdkmanager --install "build-tools;${ENV_BUILD_TOOLS_VERSION}" --sdk_root=${ANDROID_HOME}
RUN yes | /android-sdk/tools/bin/sdkmanager --licenses --sdk_root=${ANDROID_HOME}

# zipalign
ENV PATH $PATH:$ANDROID_HOME/build-tools/$ENV_BUILD_TOOLS_VERSION


# copy project source including node_modules because capacitor / cordova depend on it for building
COPY ./$ENV_PROJECT_PATH $ENV_PROJECT_FOLDER

# build apks
RUN cd $ENV_PROJECT_FOLDER/$ENV_ANDROID_PROJECT_PATH && ./gradlew assembleDebug
RUN cd $ENV_PROJECT_FOLDER/$ENV_ANDROID_PROJECT_PATH && ./gradlew assembleRelease

# TODO
# 1. read file from variable
# 2. copy file to .../release

# sign release apk
# RUN cd /project/$ENV_APK_PATH/release && jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -storepass $ENV_APP_KEYSTORE_PW -keypass $ENV_APP_KEYSTORE_KEY_PW -keystore $ENV_CURRENT_KEYSTORE_PATH app-release-unsigned.apk $ENV_APK_ALIAS
# RUN cd /project/$ENV_APK_PATH/release && zipalign 4 app-release-unsigned.apk app-release-signed.apk
