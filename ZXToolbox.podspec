Pod::Spec.new do |s|

  s.name         = "ZXToolbox"
  s.version      = "2.0.4"
  s.summary      = "Development kit for iOS"
  s.description  = <<-DESC
                   Development kit for iOS.
                   DESC
  s.homepage     = "https://github.com/xinyzhao/ZXToolbox"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "xinyzhao" => "xinyzhao@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/xinyzhao/ZXToolbox.git", :tag => "#{s.version}" }
  s.requires_arc = true

  s.frameworks = "Foundation", "UIKit"
  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.source_files  = "ZXToolbox.h"
  s.public_header_files = "ZXToolbox.h"

  s.subspec "Base64Encoding" do |ss|
    ss.source_files  = "Foundation/Base64Encoding/*.{h,m}"
    ss.public_header_files = "Foundation/Base64Encoding/*.h"
  end

  s.subspec "JSONObject" do |ss|
    ss.source_files  = "Foundation/JSONObject/*.{h,m}"
    ss.public_header_files = "Foundation/JSONObject/*.h"
  end

  s.subspec "NSArray+ZXToolbox" do |ss|
    ss.source_files  = "Foundation/NSArray+ZXToolbox/*.{h,m}"
    ss.public_header_files = "Foundation/NSArray+ZXToolbox/*.h"
  end

  s.subspec "NSDate+ZXToolbox" do |ss|
    ss.source_files  = "Foundation/NSDate+ZXToolbox/*.{h,m}"
    ss.public_header_files = "Foundation/NSDate+ZXToolbox/*.h"
  end

  s.subspec "NSFileManager+ZXToolbox" do |ss|
    ss.source_files  = "Foundation/NSFileManager+ZXToolbox/*.{h,m}"
    ss.public_header_files = "Foundation/NSFileManager+ZXToolbox/*.h"
  end

  s.subspec "NSNumberFormatter+ZXToolbox" do |ss|
    ss.source_files  = "Foundation/NSNumberFormatter+ZXToolbox/*.{h,m}"
    ss.public_header_files = "Foundation/NSNumberFormatter+ZXToolbox/*.h"
  end

  s.subspec "NSObject+ZXToolbox" do |ss|
    ss.source_files  = "Foundation/NSObject+ZXToolbox/*.{h,m}"
    ss.public_header_files = "Foundation/NSObject+ZXToolbox/*.h"
  end

  s.subspec "NSString+NumberValue" do |ss|
    ss.source_files  = "Foundation/NSString+NumberValue/*.{h,m}"
    ss.public_header_files = "Foundation/NSString+NumberValue/*.h"
  end

  s.subspec "NSString+Pinyin" do |ss|
    ss.source_files  = "Foundation/NSString+Pinyin/*.{h,m}"
    ss.public_header_files = "Foundation/NSString+Pinyin/*.h"
  end

  s.subspec "NSString+Unicode" do |ss|
    ss.dependency 'ZXToolbox/NSObject+ZXToolbox'
    ss.source_files  = "Foundation/NSString+Unicode/*.{h,m}"
    ss.public_header_files = "Foundation/NSString+Unicode/*.h"
  end

  s.subspec "NSString+URLEncoding" do |ss|
    ss.source_files  = "Foundation/NSString+URLEncoding/*.{h,m}"
    ss.public_header_files = "Foundation/NSString+URLEncoding/*.h"
  end

  s.subspec "UIApplication+ZXToolbox" do |ss|
    ss.source_files  = "UIKit/UIApplication+ZXToolbox/*.{h,m}"
    ss.public_header_files = "UIKit/UIApplication+ZXToolbox/*.h"
  end

  s.subspec "UIApplicationIdleTimer" do |ss|
    ss.source_files  = "UIKit/UIApplicationIdleTimer/*.{h,m}"
    ss.public_header_files = "UIKit/UIApplicationIdleTimer/*.h"
  end

  s.subspec "UIButton+ZXToolbox" do |ss|
    ss.source_files  = "UIKit/UIButton+ZXToolbox/*.{h,m}"
    ss.public_header_files = "UIKit/UIButton+ZXToolbox/*.h"
  end

  s.subspec "UIColor+ZXToolbox" do |ss|
    ss.source_files  = "UIKit/UIColor+ZXToolbox/*.{h,m}"
    ss.public_header_files = "UIKit/UIColor+ZXToolbox/*.h"
  end

  s.subspec "UIImage+ZXToolbox" do |ss|
    ss.source_files  = "UIKit/UIImage+ZXToolbox/*.{h,m}"
    ss.public_header_files = "UIKit/UIImage+ZXToolbox/*.h"
    ss.frameworks = "CoreGraphics", "ImageIO"
  end

  s.subspec "UINetworkActivityIndicator" do |ss|
    ss.source_files  = "UIKit/UINetworkActivityIndicator/*.{h,m}"
    ss.public_header_files = "UIKit/UINetworkActivityIndicator/*.h"
  end

  s.subspec "UIScreen+ZXToolbox" do |ss|
    ss.source_files  = "UIKit/UIScreen+ZXToolbox/*.{h,m}"
    ss.public_header_files = "UIKit/UIScreen+ZXToolbox/*.h"
  end

  s.subspec "UIScrollView+ZXToolbox" do |ss|
    ss.source_files  = "UIKit/UIScrollView+ZXToolbox/*.{h,m}"
    ss.public_header_files = "UIKit/UIScrollView+ZXToolbox/*.h"
  end

  s.subspec "UITableViewCell+Separator" do |ss|
    ss.source_files  = "UIKit/UITableViewCell+Separator/*.{h,m}"
    ss.public_header_files = "UIKit/UITableViewCell+Separator/*.h"
  end

  s.subspec "UITextField+ZXToolbox" do |ss|
    ss.dependency 'ZXToolbox/NSObject+ZXToolbox'
    ss.source_files  = "UIKit/UITextField+ZXToolbox/*.{h,m}"
    ss.public_header_files = "UIKit/UITextField+ZXToolbox/*.h"
  end

  s.subspec "UIView+ZXToolbox" do |ss|
    ss.dependency 'ZXToolbox/NSObject+ZXToolbox'
    ss.source_files  = "UIKit/UIView+ZXToolbox/*.{h,m}"
    ss.public_header_files = "UIKit/UIView+ZXToolbox/*.h"
  end

  s.subspec "UIViewController+ZXToolbox" do |ss|
    ss.source_files  = "UIKit/UIViewController+ZXToolbox/*.{h,m}"
    ss.public_header_files = "UIKit/UIViewController+ZXToolbox/*.h"
  end

  s.subspec "ZXAlertView" do |ss|
    ss.source_files  = "ZXKit/ZXAlertView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXAlertView/*.h"
  end

  s.subspec "ZXAudioDevice" do |ss|
    ss.source_files  = "ZXKit/ZXAudioDevice/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXAudioDevice/*.h"
    ss.frameworks = "AVFoundation"
  end

  s.subspec "ZXAuthorizationHelper" do |ss|
    ss.source_files  = "ZXKit/ZXAuthorizationHelper/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXAuthorizationHelper/*.h"
    ss.frameworks = "AddressBook", "AssetsLibrary", "AVFoundation", "CoreLocation"
    ss.weak_framework = "Contacts", "CoreTelephony", "Photos"
  end

  s.subspec "ZXBadgeLabel" do |ss|
    ss.source_files  = "ZXKit/ZXBadgeLabel/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXBadgeLabel/*.h"
  end

  s.subspec "ZXBrightnessView" do |ss|
  	ss.dependency 'ZXToolbox/UIColor+ZXToolbox'
    ss.source_files  = "ZXKit/ZXBrightnessView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXBrightnessView/*.h"
    ss.resources = "ZXKit/ZXBrightnessView/ZXBrightnessView.bundle"
  end

  s.subspec "ZXCircularProgressView" do |ss|
    ss.source_files  = "ZXKit/ZXCircularProgressView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXCircularProgressView/*.h"
  end

  s.subspec "ZXCommonCrypto" do |ss|
    ss.source_files  = "ZXKit/ZXCommonCrypto/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXCommonCrypto/*.h"
  end

  s.subspec "ZXDownloadManager" do |ss|
  	ss.dependency 'ZXToolbox/ZXCommonCrypto'
    ss.source_files  = "ZXKit/ZXDownloadManager/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXDownloadManager/*.h"
  end

  s.subspec "ZXDrawingView" do |ss|
    ss.source_files  = "ZXKit/ZXDrawingView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXDrawingView/*.h"
  end
  
  s.subspec "ZXHaloLabel" do |ss|
    ss.source_files  = "ZXKit/ZXHaloLabel/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXHaloLabel/*.h"
  end

  s.subspec "ZXHTTPClient" do |ss|
    ss.source_files  = "ZXKit/ZXHTTPClient/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXHTTPClient/*.h"
    ss.frameworks = "Security"
  end

  s.subspec "ZXLineChartView" do |ss|
    ss.source_files  = "ZXKit/ZXLineChartView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXLineChartView/*.h"
  end

  s.subspec "ZXLocalAuthentication" do |ss|
    ss.source_files  = "ZXKit/ZXLocalAuthentication/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXLocalAuthentication/*.h"
    ss.weak_framework = "LocalAuthentication"
  end
  
  s.subspec "ZXLocationManager" do |ss|
    ss.source_files  = "ZXKit/ZXLocationManager/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXLocationManager/*.h"
    ss.frameworks = "CoreLocation"
  end
  
  s.subspec "ZXNavigationController" do |ss|
    ss.source_files  = "ZXKit/ZXNavigationController/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXNavigationController/*.h"
  end

  s.subspec "ZXNetworkTrafficMonitor" do |ss|
    ss.source_files  = "ZXKit/ZXNetworkTrafficMonitor/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXNetworkTrafficMonitor/*.h"
  end

  s.subspec "ZXPageIndicatorView" do |ss|
    ss.source_files  = "ZXKit/ZXPageIndicatorView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXPageIndicatorView/*.h"
  end

  s.subspec "ZXPageView" do |ss|
    ss.dependency 'ZXToolbox/ZXTimer'
    ss.source_files  = "ZXKit/ZXPageView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXPageView/*.h"
  end

  s.subspec "ZXPhotoLibrary" do |ss|
    ss.source_files  = "ZXKit/ZXPhotoLibrary/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXPhotoLibrary/*.h"
    ss.frameworks = "AssetsLibrary", "CoreGraphics", "ImageIO"
    ss.weak_framework = "Photos"
  end

  s.subspec "ZXPlayerViewController" do |ss|
    ss.dependency 'ZXToolbox/NSObject+ZXToolbox'
    ss.dependency 'ZXToolbox/UIViewController+ZXToolbox'
    ss.dependency 'ZXToolbox/ZXBrightnessView'
    ss.source_files  = "ZXKit/ZXPlayerViewController/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXPlayerViewController/*.h"
    ss.frameworks = "AVFoundation", "MediaPlayer"
  end

  s.subspec "ZXPopoverView" do |ss|
    ss.source_files  = "ZXKit/ZXPopoverView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXPopoverView/*.h"
  end

  s.subspec "ZXPopoverWindow" do |ss|
    ss.source_files  = "ZXKit/ZXPopoverWindow/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXPopoverWindow/*.h"
  end

  s.subspec "ZXQRCodeGenerator" do |ss|
    ss.source_files  = "ZXKit/ZXQRCodeGenerator/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXQRCodeGenerator/*.h"
  end

  s.subspec "ZXQRCodeReader" do |ss|
    ss.source_files  = "ZXKit/ZXQRCodeReader/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXQRCodeReader/*.h"
  end

  s.subspec "ZXQRCodeScanner" do |ss|
    ss.source_files  = "ZXKit/ZXQRCodeScanner/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXQRCodeScanner/*.h"
    ss.frameworks = "AVFoundation", "ImageIO"
  end

  s.subspec "ZXScriptMessageHandler" do |ss|
    ss.ios.deployment_target = '8.0'
    ss.source_files  = "ZXKit/ZXScriptMessageHandler/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXScriptMessageHandler/*.h"
    ss.frameworks = "WebKit"
  end

  s.subspec "ZXScrollLabel" do |ss|
    ss.source_files  = "ZXKit/ZXScrollLabel/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXScrollLabel/*.h"
  end

  s.subspec "ZXStackView" do |ss|
    ss.source_files  = "ZXKit/ZXStackView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXStackView/*.h"
  end

  s.subspec "ZXTabBar" do |ss|
    ss.source_files  = "ZXKit/ZXTabBar/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXTabBar/*.h"
  end
  
  s.subspec "ZXTabBarController" do |ss|
    ss.source_files  = "ZXKit/ZXTabBarController/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXTabBarController/*.h"
  end

  s.subspec "ZXTagView" do |ss|
    ss.source_files  = "ZXKit/ZXTagView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXTagView/*.h"
  end

  s.subspec "ZXTimer" do |ss|
    ss.source_files  = "ZXKit/ZXTimer/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXTimer/*.h"
  end

  s.subspec "ZXToastView" do |ss|
    ss.source_files  = "ZXKit/ZXToastView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXToastView/*.h"
  end

  s.subspec "ZXToolbox+Macros" do |ss|
    ss.dependency 'ZXToolbox/NSDate+ZXToolbox'
    ss.source_files  = "ZXKit/ZXToolbox+Macros/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXToolbox+Macros/*.h"
  end

  s.subspec "ZXURLProtocol" do |ss|
    ss.source_files  = "ZXKit/ZXURLProtocol/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXURLProtocol/*.h"
    ss.frameworks = "CoreFoundation", "MobileCoreServices"
  end

  s.subspec "ZXURLSession" do |ss|
    ss.source_files  = "ZXKit/ZXURLSession/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXURLSession/*.h"
  end

end
