# Dockerfile for building Kivy + Buildozer targeting Android 4.1 (API 16)
FROM thewtex/opengl:ubuntu1804
LABEL maintainer="psanio"

ENV DEBIAN_FRONTEND=noninteractive
ENV KIVY_VERSION=1.10.1
ENV BUILDOZER_VERSION=0.4
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_NDK_ROOT=/opt/android-ndk
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=${PATH}:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/tools/bin:/opt/android-sdk/platform-tools:/opt/android-ndk

# System packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git curl wget unzip zip openjdk-8-jdk \
    python3-dev python3-pip python3-setuptools \
    pkg-config autoconf \
    libtool libssl-dev libffi-dev zlib1g-dev libgl1-mesa-dev libgles2-mesa-dev \
    libsdl2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libjpeg-dev \
    libfreetype6-dev \
 && rm -rf /var/lib/apt/lists/*

# Python packages
RUN pip3 install --upgrade pip
# Cython pinned to an older stable release compatible with older Kivy builds
RUN pip3 install Cython==0.23
# Install Kivy and Buildozer pinned versions
RUN pip3 install kivy==${KIVY_VERSION} buildozer==${BUILDOZER_VERSION}

# Create a non-root user to run builds
RUN useradd -m -s /bin/bash builder && mkdir -p /home/builder/.buildozer
RUN chown -R builder:builder /home/builder
WORKDIR /home/builder
USER builder
ENV HOME=/home/builder

# Download and install Android command line tools (sdkmanager), SDK platforms and build-tools
USER root
RUN mkdir -p ${ANDROID_SDK_ROOT}
WORKDIR /tmp
# Download Android command line tools
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/cmdline-tools.zip \
 && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
 && unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
 && rm /tmp/cmdline-tools.zip

# Ensure sdkmanager is available and install required SDK components
ENV SDKMANAGER=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager
RUN yes | ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} --licenses || true
# Install platform-tools, platform 16 (Android 4.1), and a build-tools version compatible with API 16
RUN ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} "platform-tools" "platforms;android-16" "build-tools;23.0.3" "extras;android;m2repository" || true

# Download an NDK compatible with older python-for-android (r10e)
RUN wget -q https://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.zip -O /tmp/android-ndk-r10e.zip \
 && unzip -q /tmp/android-ndk-r10e.zip -d /opt/ \
 && rm /tmp/android-ndk-r10e.zip \
 && mv /opt/android-ndk-r10e ${ANDROID_NDK_ROOT}

# Set ownership for builder
RUN chown -R builder:builder ${ANDROID_SDK_ROOT} ${ANDROID_NDK_ROOT}

# Switch back to builder user
USER builder
WORKDIR /home/builder

# Add a simple helper script to show environment and build (optional)
RUN echo "#!/bin/bash\necho 'Kivy:' ${KIVY_VERSION}\necho 'Buildozer:' ${BUILDOZER_VERSION}\necho 'ANDROID_SDK_ROOT=' ${ANDROID_SDK_ROOT}\necho 'ANDROID_NDK_ROOT=' ${ANDROID_NDK_ROOT}\nexec \"$@\"" > /home/builder/entry.sh \
 && chmod +x /home/builder/entry.sh

# NOTE: Intentionally do NOT set ENTRYPOINT or CMD so the container can be used interactively
# The builder user can run: buildozer android debug

# Clean up apt caches (already removed earlier) and leave the image ready for builds
WORKDIR /home/builder

