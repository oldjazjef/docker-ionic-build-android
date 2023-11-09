FROM openjdk:17-jdk-oraclelinux7

ARG CACHEBUSTER=4
ARG PROJECT_PATH="fleet-app"
ARG ANDROID_PROJECT_PATH="projects/client/android"
ARG APK_PATH="projects/client/android/app/build/outputs/apk"
ARG APK_ALIAS=""
ARG APP_KEYSTORE=""
ARG APP_KEYSTORE_KEY_PW=""
ARG PROJECT_FOLDER="/"

# DO NOT FORGET TO DEFINE ENVS APP_FOLDER AND ENV_APK_PATH
ENV ENV_PROJECT_PATH=$PROJECT_PATH
ENV ENV_PROJECT_FOLDER=$PROJECT_FOLDER
ENV ENV_ANDROID_PROJECT_PATH=$ANDROID_PROJECT_PATH
ENV ENV_APK_PATH=$APK_PATH
ENV ENV_APK_ALIAS=$APK_ALIAS
ENV ENV_APP_KEYSTORE_KEY_PW=$APP_KEYSTORE_KEY_PW 

# install common deps
RUN yum -y update
RUN yum -y install wget
RUN yum -y install unzip
RUN yum -y install curl

# install nodejs and npm
RUN yum -y install curl
# > 16 not supported
RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash - 
RUN yum install -y nodejs

# Verify Node.js and npm installation
RUN node --version
RUN npm --version

# download android sdk
RUN mkdir android-sdk
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
RUN unzip commandlinetools-linux-10406996_latest -d /android-sdk/
RUN rm -rf commandlinetools-linux-10406996_latest

# setup environment variables
#java
ENV PATH $PATH:$JAVA_HOME/bin/
# android and tools
ENV ANDROID_HOME /android-sdk
ENV ANDROID_SDK_ROOT $ANDROID_HOME
ENV PATH $PATH:$ANDROID_SDK_ROOT/cmdline-tools/bin
ENV PATH $PATH:$ANDROID_SDK_ROOT/platform-tools
ENV PATH $PATH:$ANDROID_SDK_ROOT/build-tools/30.0.3

# setup sdkmanager
RUN /android-sdk/cmdline-tools/bin/sdkmanager --update --sdk_root=${ANDROID_HOME}
RUN /android-sdk/cmdline-tools/bin/sdkmanager --install "build-tools;30.0.3" --sdk_root=${ANDROID_HOME}
RUN yes | /android-sdk/cmdline-tools/bin/sdkmanager --licenses --sdk_root=${ANDROID_HOME}


# copy project source including node_modules because capacitor / cordova depend on it for building
COPY ./$ENV_PROJECT_PATH $ENV_PROJECT_FOLDER

CMD ["sh", "/create-release-apk.sh"]
