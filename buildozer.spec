[app]
# (str) Title of your application
title = MyKivyApp

# (str) Package name
package.name = mykivyapp

# (str) Package domain (reverse domain)
package.domain = org.example

# (list) Source files to include (comma separated)
source.include_exts = py,png,jpg,kv,atlas

# (str) Application requirements
requirements = python3,kivy==1.10.1

# (str) Supported orientation (portrait, landscape or all)
orientation = portrait

# (bool) Indicate whether the application should be fullscreen
fullscreen = 0

# (str) The directory to put the final apk (default bin/)
#bin_dir = bin

[buildozer]
# (str) Path to build artifact storage
#build_dir = .buildozer

# (str) path to android SDK (container installs to /opt/android-sdk)
android.sdk_path = /opt/android-sdk
# (str) path to android NDK (we install r10e at /opt/android-ndk)
android.ndk_path = /opt/android-ndk
# (str) NDK version identifier if needed (some p4a recipes check this)
android.ndk = r10e

# Android target API and min API
# Build for API level 16 (Android 4.1)
android.api = 16
android.minapi = 16

# (str) Android build tools version to match installed build-tools
android.build_tools_version = 23.0.3

# (list) Permissions
android.permissions = INTERNET

# (str) If you need to pin python-for-android branch:
#p4a.branch = master

[app:android]
# Additional android specific options can go here.
