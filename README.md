![Kommander](https://raw.githubusercontent.com/intelygenz/Kommander-iOS/master/Logo.png)

[![Twitter](https://img.shields.io/badge/contact-@intelygenz-0FABFF.svg?style=flat)](http://twitter.com/intelygenz)
[![Version](https://img.shields.io/cocoapods/v/Kommander.svg?style=flat)](http://cocoapods.org/pods/Kommander)
[![License](https://img.shields.io/cocoapods/l/Kommander.svg?style=flat)](http://cocoapods.org/pods/Kommander)
[![Platform](https://img.shields.io/cocoapods/p/Kommander.svg?style=flat)](http://cocoapods.org/pods/Kommander)
[![Swift](https://img.shields.io/badge/Swift-4-orange.svg?style=flat)](https://swift.org)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager Compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Build Status](https://travis-ci.org/intelygenz/Kommander-iOS.svg?branch=master)](https://travis-ci.org/intelygenz/Kommander-iOS)
[![Documentation](https://img.shields.io/badge/documentation-100%25-brightgreen.svg?style=flat)](https://intelygenz.github.io/Kommander-iOS)
[![Downloads](https://img.shields.io/cocoapods/dt/Kommander.svg)](http://cocoapods.org/pods/Kommander)
[![Help Contribute to Open Source](https://www.codetriage.com/intelygenz/kommander-ios/badges/users.svg)](https://www.codetriage.com/intelygenz/kommander-ios)

**Kommander** is a Swift library to manage the task execution in different threads. Through the definition a simple but powerful concept, [**Kommand**](https://en.wikipedia.org/wiki/Command_pattern).

Inspired on the Java library [**Kommander**](https://github.com/Wokdsem/Kommander) from [**Wokdsem**](https://github.com/Wokdsem).


![Kommander](https://raw.githubusercontent.com/intelygenz/Kommander-iOS/master/Kommander.png)

## 🌟 Features

- [x] Make kommand or multiple kommands
- [x] Execute kommand or multiple kommands
- [x] Cancel kommand or multiple kommands
- [x] Retry kommand or multiple kommands
- [x] Set kommand success closure
- [x] Set kommand error closure
- [x] Main thread dispatcher
- [x] Current thread dispatcher
- [x] Custom OperationQueue dispatcher
- [x] Execute single or multiple Operation
- [x] Execute sequential or concurrent closures
- [x] Execute DispatchWorkItem
- [x] Kommand state
- [x] watchOS compatible
- [x] tvOS compatible
- [x] macOS compatible
- [x] Swift 3 version
- [x] Swift 2 version
- [x] Objective-C version

## 📲 Installation

Kommander is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Kommander'
```

For Swift 3 compatibility use:

```ruby
pod 'Kommander', '~> 0.7'
```

For Swift 2 compatibility use:

```ruby
pod 'Kommander', :git => 'https://github.com/intelygenz/Kommander-iOS.git', :tag => '0.3.0-swift2'
```

For Objective-C compatibility use:

```ruby
pod 'Kommander', :git => 'https://github.com/intelygenz/Kommander-iOS.git', :tag => '0.2.3-objc'
```

#### Or you can install it with [Carthage](https://github.com/Carthage/Carthage):

```ogdl
github "intelygenz/Kommander-iOS"
```

#### Or install it with [Swift Package Manager](https://swift.org/package-manager/):

```swift
dependencies: [
    .package(url: "https://github.com/intelygenz/Kommander-iOS.git")
]
```

## 🐒 Usage

#### Making, executing, cancelling and retrying Kommands:

```swift
Kommander().make {
    // Your code here
}.execute()
```

```swift
Kommander().make {
    // Your code here
}.execute(after: .seconds(2))
```

```swift
Kommander().make {
    return "Your string"
}.success { yourString in
    print(yourString)
}.execute()
```

```swift
Kommander().make {
    throw CocoaError(.featureUnsupported)
}.error({ error in
    print(String(describing: error!))
}).execute()
```

```swift
let kommand = Kommander().make { () -> Any? in
    // Your code here
}.success { result in
    // Your success handling here
}.error({ error in
    // Your error handling here
}).execute()

kommand.cancel()

kommand.retry()
```

#### Creating Kommanders:

```swift
Kommander(deliverer: Dispatcher = .current, executor: Dispatcher = .default)

Kommander(deliverer: Dispatcher = .current, name: String, qos: QualityOfService = .default, maxConcurrentOperations: Int = .default)
```

```swift
Kommander.main

Kommander.current

Kommander.default

Kommander.userInteractive

Kommander.userInitiated

Kommander.utility

Kommander.background
```

#### Creating Dispatchers:

```swift
CurrentDispatcher()

MainDispatcher()

Dispatcher(name: String, qos: QualityOfService = .default, maxConcurrentOperations: Int = .default)
```

```swift
Dispatcher.main

Dispatcher.current

Dispatcher.default

Dispatcher.userInteractive

Dispatcher.userInitiated

Dispatcher.utility

Dispatcher.background
```

## ❤️ Etc.

* Contributions are very welcome.
* Attribution is appreciated (let's spread the word!), but not mandatory.

## 👨‍💻 Authors

[alexruperez](https://github.com/alexruperez), alejandro.ruperez@intelygenz.com

[juantrias](https://github.com/juantrias), juan.trias@intelygenz.com

[RobertoEstrada](https://github.com/RobertoEstrada), roberto.estrada@intelygenz.com

## 👮‍♂️ License

Kommander is available under the MIT license. See the LICENSE file for more info.
