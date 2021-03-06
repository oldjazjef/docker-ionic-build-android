FROM openjdk:11

# DO NOT FORGET TO DEFINE ENVS APP_FOLDER AND APK_PATH -- using default values
ENV PROJECT_PATH "app-name"
ENV APK_PATH "yourpathto/android/app/build/outputs/apk"

# install common deps
RUN apt update
RUN apt -y install wget
RUN apt -y install unzip
RUN apt -y install gradle

# deps for building app within container
# RUN apt -y install nodejs
RUN apt -y install npm
# RUN npm install -g @ionic/cli
# RUN npm i -g @capacitor/cli
# RUN npm i -g @capacitor/android

# download android sdk
RUN mkdir android-sdk
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip
RUN unzip commandlinetools-linux-6200805_latest -d /android-sdk/
RUN rm -rf commandlinetools-linux-6200805_latest

# setup environment variables
#java
ENV JAVA_HOME /usr/local/openjdk-11
ENV PATH $PATH:$JAVA_HOME/bin/
# android and tools
ENV ANDROID_HOME /android-sdk/
ENV ANDROID_SDK_ROOT $ANDROID_HOME
ENV PATH $PATH:$ANDROID_SDK_ROOT/tools/bin
ENV PATH $PATH:$ANDROID_SDK_ROOT/platform-tools/bin

# setup sdkmanager
RUN /android-sdk/tools/bin/sdkmanager --update --sdk_root=${ANDROID_HOME}
RUN yes | /android-sdk/tools/bin/sdkmanager --licenses --sdk_root=${ANDROID_HOME}

# copy project source including node_modules because capacitor / cordova depend on it for building
COPY ./$PROJECT_PATH /project

RUN cd /project && npm run build-apks

# TODO
# parameterize app path / android path
# parameterize signing & keystore files
