# ZXToolbox
My development kit for iOS

## Requirements

* Requires iOS 8.0 or later
* Requires Automatic Reference Counting (ARC)

## Installation with CocoaPods

Install [CocoaPods](http://cocoapods.org/) with the following command:

```
$ gem install cocoapods
```

Create a [Podfile](http://guides.cocoapods.org/using/the-podfile.html) into your project folder:

```
$ touch Podfile
```

Add the following line to your `Podfile`:

```
platform :ios, '8.0'

target 'TargetName' do
pod "ZXToolbox"
end
```

Then, run the following command:

```
$ pod install
```

or

```
$ pod update
```

## Installation with Carthage

Install [Carthage](https://github.com/Carthage/Carthage) with Homebrew using the following command:

```
$ brew update
$ brew install carthage
```

Create a [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile) into your project folder:

```
$ touch Cartfile
```

Add the following line to your `Cartfile`:

```
github "xinyzhao/ZXToolbox"
```

Then, run carthage to build the framework

```
$ carthage update --platform iOS
```

Drag the built ZXToolbox.framework into your Xcode project.

## Usage

```
#import <ZXToolbox/ZXToolbox.h>
```

## Foundation

* Base64Encoding
* JSONObject
* NSArray+ZXToolbox
* NSDate+ZXToolbox
* NSFileManager+ZXToolbox
* NSNumberFormatter+ZXToolbox
* NSObject+ZXToolbox
* NSString+NumberValue
* NSString+Pinyin
* NSString+Unicode
* NSString+URLEncoding

## UIKit

* UIApplication+ZXToolbox
* UIApplicationIdleTimer
* UIButton+ZXToolbox
* UIColor+ZXToolbox
* UIControl+ZXToolbox.h
* UIDevice+ZXToolbox
* UIImage+ZXToolbox
* UINavigationBar+ZXToolbox
* UINavigationController+ZXToolbox
* UINetworkActivityIndicator
* UIScreen+ZXToolbox
* UIScrollView+ZXToolbox
* UITableViewCell+ZXToolbox
* UITextField+ZXToolbox
* UIView+ZXToolbox
* UIViewController+ZXToolbox

## ZXKit

* ZXAlertView
* ZXAudioDevice
* ZXAuthorizationHelper
* ZXBadgeLabel
* ZXBrightnessView
* ZXCircularProgressView
* ZXCommonCrypto
* ZXDownloader
* ZXDrawingView
* ZXHaloLabel
* ZXHTTPClient
* ZXImageBroswer
* ZXLineChartView
* ZXLocalAuthentication
* ZXLocationManager
* ZXNavigationController
* ZXNetworkTrafficMonitor
* ZXPageIndicatorView
* ZXPageView
* ZXPhotoLibrary
* ZXPlayer
* ZXPlayerViewController
* ZXPopoverView
* ZXPopoverWindow
* ZXQRCodeGenerator
* ZXQRCodeReader
* ZXQRCodeScanner
* ZXScriptMessageHandler
* ZXScrollLabel
* ZXStackView
* ZXTabBar
* ZXTabBarController
* ZXTagView
* ZXTimer
* ZXToastView
* ZXToolbox+Macros
* ZXURLProtocol
* ZXURLSession

## License

`ZXToolbox` is available under the MIT license. See the `LICENSE` file for more info.
