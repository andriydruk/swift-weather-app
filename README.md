# Swift Weather App ![AndroidCore](https://github.com/andriydruk/swift-weather-app/workflows/AndroidCore/badge.svg) ![MacCore](https://github.com/andriydruk/swift-weather-app/workflows/MacCore/badge.svg)
Cross-platform Swift application 

![GitHub Logo](./doc/device-2020-04-21-000209.png)

## Arhitecture

Architecture based on reusing as much as possible code written on Swift. Currently, Swift Weather Core includes weather repository that handles loading info from the database and fetching new data from providers.

```
                                    ------------------------------------------
                                  /                        \                   \
  +---------+    +---------------------+    +-----------+   \   +---------+     \   +----------+
  |  macOS  |<-->|  Swift Weather Core |<-->|  Android  |     ->|   iOS   |       ->|  Windows |
  +---------+    +---------------------+    +-----------+       +---------+         +----------+
                 |  Weather repository |
                 +---------------------+
                 |   Weather database  |
                 +---------------------+
                 |   Weather provider  |
                 +---------------------+
```



## How to build [Android]

For building an Android application you need [Readdle's Swift Android Toolchain](https://github.com/readdle/swift-android-toolchain#installation). Please follow the guideline on installation first.
After a successful setup, you can clone this repo and build it with Android Studio as any other android project. 


## How to build [iOS/MacOS]

For building an iOS application you need [Xcode 12](https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_12_beta/Xcode_12_beta.xip). Minimal target version of operation systems is iOS 14 and MacOS 11.


## How to build [Windows]

In progress...
