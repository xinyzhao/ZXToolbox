Pod::Spec.new do |s|

  s.name         = "ZXToolbox"
  s.version      = "1.0.3"
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
    ss.source_files  = "ZXKit/JSONObject/*.{h,m}"
    ss.public_header_files = "ZXKit/JSONObject/*.h"
  end

  s.subspec "NSArray+Extra" do |ss|
    ss.source_files  = "Foundation/NSArray+Extra/*.{h,m}"
    ss.public_header_files = "Foundation/NSArray+Extra/*.h"
  end

  s.subspec "NSDate+Extra" do |ss|
    ss.source_files  = "Foundation/NSDate+Extra/*.{h,m}"
    ss.public_header_files = "Foundation/NSDate+Extra/*.h"
  end

  s.subspec "NSFileManager+Extra" do |ss|
    ss.source_files  = "Foundation/NSFileManager+Extra/*.{h,m}"
    ss.public_header_files = "Foundation/NSFileManager+Extra/*.h"
  end

  s.subspec "NSLog+Extra" do |ss|
    ss.source_files  = "Foundation/NSLog+Extra/*.{h,m}"
    ss.public_header_files = "Foundation/NSLog+Extra/*.h"
  end

  s.subspec "NSObject+Extra" do |ss|
    ss.source_files  = "Foundation/NSObject+Extra/*.{h,m}"
    ss.public_header_files = "Foundation/NSObject+Extra/*.h"
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
    ss.dependency 'ZXToolbox/NSObject+Extra'
    ss.source_files  = "Foundation/NSString+Unicode/*.{h,m}"
    ss.public_header_files = "Foundation/NSString+Unicode/*.h"
  end

  s.subspec "NSString+URLEncoding" do |ss|
    ss.source_files  = "Foundation/NSString+URLEncoding/*.{h,m}"
    ss.public_header_files = "Foundation/NSString+URLEncoding/*.h"
  end

  s.subspec "QRCodeGenerator" do |ss|
    ss.source_files  = "ZXKit/QRCodeGenerator/*.{h,m}"
    ss.public_header_files = "ZXKit/QRCodeGenerator/*.h"
  end

  s.subspec "QRCodeReader" do |ss|
    ss.source_files  = "ZXKit/QRCodeReader/*.{h,m}"
    ss.public_header_files = "ZXKit/QRCodeReader/*.h"
  end

  s.subspec "QRCodeScanner" do |ss|
    ss.source_files  = "ZXKit/QRCodeScanner/*.{h,m}"
    ss.public_header_files = "ZXKit/QRCodeScanner/*.h"
    ss.frameworks = "AVFoundation"
  end

  s.subspec "UIApplicationIdleTimer" do |ss|
    ss.source_files  = "UIKit/UIApplicationIdleTimer/*.{h,m}"
    ss.public_header_files = "UIKit/UIApplicationIdleTimer/*.h"
  end

  s.subspec "UIColor+Extra" do |ss|
    ss.source_files  = "UIKit/UIColor+Extra/*.{h,m}"
    ss.public_header_files = "UIKit/UIColor+Extra/*.h"
  end

  s.subspec "UIImage+Extra" do |ss|
    ss.source_files  = "UIKit/UIImage+Extra/*.{h,m}"
    ss.public_header_files = "UIKit/UIImage+Extra/*.h"
    ss.frameworks = "CoreGraphics", "ImageIO"
  end

  s.subspec "UINetworkActivityIndicator" do |ss|
    ss.source_files  = "UIKit/UINetworkActivityIndicator/*.{h,m}"
    ss.public_header_files = "UIKit/UINetworkActivityIndicator/*.h"
  end

  s.subspec "UITableViewCell+Separator" do |ss|
    ss.source_files  = "UIKit/UITableViewCell+Separator/*.{h,m}"
    ss.public_header_files = "UIKit/UITableViewCell+Separator/*.h"
  end

  s.subspec "UIView+Snapshot" do |ss|
    ss.source_files  = "UIKit/UIView+Snapshot/*.{h,m}"
    ss.public_header_files = "UIKit/UIView+Snapshot/*.h"
  end

  s.subspec "UIViewController+Extra" do |ss|
    ss.source_files  = "UIKit/UIViewController+Extra/*.{h,m}"
    ss.public_header_files = "UIKit/UIViewController+Extra/*.h"
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
  	ss.dependency 'ZXToolbox/UIColor+Extra'
    ss.source_files  = "ZXKit/ZXBrightnessView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXBrightnessView/*.h"
    ss.resources = "ZXKit/ZXBrightnessView/ZXBrightnessView.bundle"
  end

  s.subspec "ZXCircularProgressView" do |ss|
    ss.source_files  = "ZXKit/ZXCircularProgressView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXCircularProgressView/*.h"
  end

  s.subspec "ZXDownloadManager" do |ss|
  	ss.dependency 'ZXToolbox/ZXHashValue'
    ss.source_files  = "ZXKit/ZXDownloadManager/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXDownloadManager/*.h"
  end

  s.subspec "ZXDrawingView" do |ss|
    ss.source_files  = "ZXKit/ZXDrawingView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXDrawingView/*.h"
  end

  s.subspec "ZXHashValue" do |ss|
    ss.source_files  = "ZXKit/ZXHashValue/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXHashValue/*.h"
  end

  s.subspec "ZXHTTPClient" do |ss|
    ss.source_files  = "ZXKit/ZXHTTPClient/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXHTTPClient/*.h"
    ss.frameworks = "Security"
  end

  s.subspec "ZXImageView" do |ss|
    ss.dependency 'ZXToolbox/ZXHashValue'
    ss.dependency 'ZXToolbox/ZXURLSession'
    ss.source_files  = "ZXKit/ZXImageView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXImageView/*.h"
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
    ss.dependency 'ZXToolbox/NSObject+Extra'
    ss.dependency 'ZXToolbox/UIViewController+Extra'
    ss.dependency 'ZXToolbox/ZXBrightnessView'
    ss.source_files  = "ZXKit/ZXPlayerViewController/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXPlayerViewController/*.h"
    ss.frameworks = "AVFoundation", "MediaPlayer"
  end

  s.subspec "ZXPopoverWindow" do |ss|
    ss.source_files  = "ZXKit/ZXPopoverWindow/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXPopoverWindow/*.h"
  end

  s.subspec "ZXRefreshView" do |ss|
  	ss.dependency 'ZXToolbox/ZXCircularProgressView'
    ss.source_files  = "ZXKit/ZXRefreshView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXRefreshView/*.h"
  end

  s.subspec "ZXTabBarController" do |ss|
    ss.source_files  = "ZXKit/ZXTabBarController/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXTabBarController/*.h"
  end

  s.subspec "ZXTagView" do |ss|
    ss.source_files  = "ZXKit/ZXTagView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXTagView/*.h"
  end

  s.subspec "ZXToastView" do |ss|
    ss.source_files  = "ZXKit/ZXToastView/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXToastView/*.h"
  end

  s.subspec "ZXURLSession" do |ss|
    ss.source_files  = "ZXKit/ZXURLSession/*.{h,m}"
    ss.public_header_files = "ZXKit/ZXURLSession/*.h"
  end

end
