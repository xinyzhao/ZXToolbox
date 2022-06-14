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

> More examples/usage please check the source code and demo/test.

### Foundation

* AVAsset+ZXToolbox.h
> 204 No Content

* AVAudioSession+ZXToolbox

```
AVAudioSession *ad = [AVAudioSession sharedInstance];
NSLogA(@"#category: %@", ad.category);
NSLogA(@"#currentInput: %@", ad.currentInput);
NSLogA(@"#currentOutput: %@", ad.currentOutput);
NSLogA(@"#isOverrideSpeaker: %d", ad.isOverrideSpeaker);
[AVAudioSession sharedInstance].systemVolumeDidChange = ^(float volume) {
    NSLogA(@"#systemVolume: %f", volume);
};
[AVAudioSession sharedInstance].systemVolume = 0.5;
```
> Output:

```
#category: AVAudioSessionCategoryPlayback
#currentInput: (null)
#currentOutput: Speaker
#isOverrideSpeaker: 0
#systemVolume: 0.5
```

* Base64Encoding

```
NSString *str = @"testBase64Encoding";
str = [str base64EncodedStringWithOptions:0];
NSLogA(@"#base64EncodedString: %@", str);
str = [str base64DecodedStringWithOptions:0];
NSLogA(@"#base64DecodedString: %@", str);
```

> Output:

```
#base64EncodedString: dGVzdEJhc2U2NEVuY29kaW5n
#base64DecodedString: testBase64Encoding
```

* JSONObject

```
id src = @{@"string":@"json", @"array":@[@1,@2,@3], @"object":@{@"a":@"a", @"b":@"b", @"c":@"c"}};
id str = [src JSONString];
id pty = [src JSONStringWithOptions:NSJSONWritingPrettyPrinted];
id obj = [str JSONObject];
NSLogA(@"#JSONString: %@", str);
NSLogA(@"#JSONPretty: %@", pty);
NSLogA(@"#JSONObject: %@", obj);
```
> Output:

```
#JSONString: {"string":"json","array":[1,2,3],"object":{"a":"a","b":"b","c":"c"}}

#JSONPretty: {
  "string" : "json",
  "array" : [
    1,
    2,
    3
  ],
  "object" : {
    "a" : "a",
    "b" : "b",
    "c" : "c"
  }
}

#JSONObject: {
    array =     (
        1,
        2,
        3
    );
    object =     {
        a = a;
        b = b;
        c = c;
    };
    string = json;
}
```

* NSArray+ZXToolbox

```
NSArray *a0 = @[];
NSArray *a1 = @[@1];
NSArray *a2 = @[@1, @2];
NSArray *a3 = [a2 mutableCopy];
if (a0[3] == [a0 objectAtIndex:3]) {}
if (a1[3] == [a1 objectAtIndex:3]) {}
if (a2[3] == [a2 objectAtIndex:3]) {}
if (a3[3] == [a3 objectAtIndex:3]) {}
```
> Output:

```
index 3 beyond bounds for empty array
(
	0   ZXToolbox 0x000000010367ead3 -[NSArray(ZXToolbox) objectAtIndexedSubscript0:] + 995
	...
)

index 3 beyond bounds for empty array
(
	0   ZXToolbox 0x000000010367d1d3 -[NSArray(ZXToolbox) objectAtIndex0:] + 995
	...
)

index 3 beyond bounds [0...0]
(
	0   ZXToolbox 0x000000010367e8b3 -[NSArray(ZXToolbox) objectAtIndexedSubscript0:] + 451
	...
)

index 3 beyond bounds [0...0]
(
	0   ZXToolbox 0x000000010367d4b3 -[NSArray(ZXToolbox) objectAtIndex1:] + 451
	...
)

index 3 beyond bounds [0...1]
(
	0   ZXToolbox 0x000000010367e3b3 -[NSArray(ZXToolbox) objectAtIndexedSubscriptI:] + 451
	...
)

index 3 beyond bounds [0...1]
(
	0   ZXToolbox 0x000000010367cab3 -[NSArray(ZXToolbox) objectAtIndexI:] + 451
	...
)

index 3 beyond bounds [0...1]
(
	0   ZXToolbox 0x000000010367f2b3 -[NSArray(ZXToolbox) objectAtIndexedSubscriptM:] + 451
	...
)

index 3 beyond bounds [0...1]
(
	0   ZXToolbox 0x000000010367d9b3 -[NSArray(ZXToolbox) objectAtIndexM:] + 451
	...
)
```

* NSDate+ZXToolbox

```
NSDate *date = [NSDate date];
NSLogA(@"#DateTime: %@", [date stringWithFormat:kZXToolboxDateFormatDateTime]);
NSLogA(@"#Date: %@", [date stringWithFormat:kZXToolboxDateFormatDate]);
NSLogA(@"#Time: %@", [date stringWithFormat:kZXToolboxDateFormatTime]);
```
> Output:

```
#DateTime: 2020-06-05 11:59:59
#Date: 2020-06-05
#Time: 11:59:59
```

* NSFileManager+ZXToolbox

```
NSLogA(@"#%@ [%llu bytes]", [NSFileManager cachesDirectory], [NSFileManager fileSizeAtPath:[NSFileManager cachesDirectory]]);
NSLogA(@"#%@ [%llu bytes]", [NSFileManager documentDirectory], [NSFileManager fileSizeAtPath:[NSFileManager documentDirectory]]);
NSLogA(@"#%@ [%llu bytes]", [NSFileManager temporaryDirectory], [NSFileManager fileSizeAtPath:[NSFileManager temporaryDirectory]]);
```
> Output:

```
#/Users/.../Library/Caches [28706 bytes]
#/Users/.../Documents [0 bytes]
#/Users/.../tmp/ [0 bytes]
```

* NSNumberFormatter+ZXToolbox

```
NSNumber *num = @1234.56789;
NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
NSString *str1 = [fmt stringFromNumber:num integerFormat:@",###" minimumDecimal:4 maximumDecimal:6 paddingZeros:NO];
NSString *str2 = [fmt stringFromNumber:num integerFormat:@",###" minimumDecimal:6 maximumDecimal:9 paddingZeros:NO];
NSString *str3 = [fmt stringFromNumber:num integerFormat:@",###" minimumDecimal:6 maximumDecimal:9 paddingZeros:YES];
NSLogA(@"#%@ -> %@", num, str1);
NSLogA(@"#%@ -> %@", num, str2);
NSLogA(@"#%@ -> %@", num, str3);
```
> Output:

```
#1234.56789 -> 1,234.5679
#1234.56789 -> 1,234.56789
#1234.56789 -> 1,234.567890
```

* NSObject+ZXToolbox

```
- (void)testNSObject {
    [self testNSObjectMethod1];
    [self testNSObjectMethod2];
    [[self class] swizzleMethod:@selector(testNSObjectMethod1) with:@selector(testNSObjectMethod2)];
    [self testNSObjectMethod1];
    [self testNSObjectMethod2];
}

- (void)testNSObjectMethod1 {
    NSLogA(@"testNSObjectMethod1");
}

- (void)testNSObjectMethod2 {
    NSLogA(@"testNSObjectMethod2");
}
```
> Output:

```
>testNSObjectMethod1
>testNSObjectMethod2
>testNSObjectMethod2
>testNSObjectMethod1
```

* NSString+NumberValue

```
NSString *str = @"123456789";
NSLogA(@"Number: %@", str);
NSLogA(@"Components: %@", [str numberComponents]);
//
NSString *alphabet = [NSString defaultAlphabet];
NSLogA(@"Alphabet: %@", alphabet);
for (int i = 2; i <= alphabet.length; i++) {
    NSLog(@"[%02d] %@", i, [NSString stringWithValue:str baseIn:10 baseOut:i alphabet:nil]);
}
```
> Output:

```
Number: 123456789
Components: (
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9
)
Alphabet: 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~
[02] 111010110111100110100010101
[03] 22121022020212200
[04] 13112330310111
[05] 223101104124
[06] 20130035113
[07] 3026236221
[08] 726746425
[09] 277266780
[10] 123456789
[11] 63762A05
[12] 35418A99
[13] 1C767471
[14] 12579781
[15] AC89BC9
[16] 75BCD15
[17] 51G2A21
[18] 3B60F89
[19] 2BG64AE
[20] 1IBC1J9
[21] 194GH7F
[22] 11L0805
[23] J43JFB
[24] FC2EGL
[25] CG15LE
[26] AA44A1
[27] 8G86NI
[28] 74NQB1
[29] 60FSHJ
[30] 52CE69
[31] 49L302
[32] 3LNJ8L
[33] 353C3R
[34] 2OD2I1
[35] 2C9G1T
[36] 21I3V9
[37] 1SWB9a
[38] 1L7YEX
[39] 1EE96R
[40] 1890JT
[41] 12SBJ8
[42] dSEZF
[43] a4XL5
[44] WfD05
[45] U4aE9
[46] RQGJB
[47] PE549
[48] NCFWL
[49] LKHiF
[50] JbWZd
[51] ICZ6I
[52] Gk151
[53] FYDNK
[54] ES1cj
[55] DR28n
[56] CUtXT
[57] BdaMX
[58] AqhNJ
[59] AB6qu
[60] 9VXX9
[61] 8ttNm
[62] 8M0kX
[63] 7qkGa
[64] 7MyqL
[65] 6xZZE
[66] 6XRpR
[67] 68W4h
[68] 5qh91
[69] 5Utwv
[70] 59#IT
[71] 4y$c1
[72] 4gs'j
[73] 4PP(#
[74] 48n4+
[75] 3%l#d
[76] 3rI7X
[77] 3dWe)
[78] 3QC3R
[79] 3DVjD
[80] 31A9'
[81] 2(Oz*
[82] 2x,on
[83] 2n-)G
[84] 2eOxv
[85] 2V2b'
[86] 2M8W5
[87] 2Df+m
[88] 25EM5
[89] 1\B0?
[90] 1;Vq9
[91] 1*-e1
[92] 1$o9v
[93] 1yjAX
[94] 1sy29
[95] 1m~eE
```

* NSString+Pinyin

```
NSMutableArray *arr = [[NSMutableArray alloc] init];
NSString *str = @"我是中国人";
[arr addObject:[NSString stringWithFormat:@"str = %@", str]];
[arr addObject:[NSString stringWithFormat:@"py0 = %@", [str stringByPinyinStyle:NSStringPinyinMandarinLatin]]];
[arr addObject:[NSString stringWithFormat:@"py1 = %@", [str stringByPinyinStyle:NSStringPinyinStripDiacritics]]];
[arr addObject:[NSString stringWithFormat:@"py2 = %@", [str stringByPinyinAcronym]]];
[arr addObject:[NSString stringWithFormat:@"co0 = %@", [str containsChineseCharacters] ? @"YES" : @"NO"]];
[arr addObject:[NSString stringWithFormat:@"co1 = %@", [str containsString:@"ZG" options:NSStringPinyinSearchNone] ? @"YES" : @"NO"]];
[arr addObject:[NSString stringWithFormat:@"co2 = %@", [str containsString:@"ZG" options:NSStringPinyinSearchAcronym] ? @"YES" : @"NO"]];
NSLogA(@"%@", arr);
```
> Output:

```
(
    "str = 我是中国人",
    "py0 = wǒ shì zhōng guó rén",
    "py1 = wo shi zhong guo ren",
    "py2 = wszgr",
    "co0 = YES",
    "co1 = NO",
    "co2 = YES"
)
```

* NSString+Unicode

```
NSMutableArray *arr = [[NSMutableArray alloc] init];
NSString *str = @"\u6211\u662f\u4e2d\u56fd\u4eba";
[arr addObject:[NSString stringWithFormat:@"str = %@", str]];
NSLogA(@"%@", arr);
```
> Output:

```
(
    "str = 我是中国人"
)
```

* NSString+URLEncoding

```
NSString *str = @" ~`!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?";
NSLogA(@"#Char      : %@", str);
NSLogA(@"#User      : %@", [str stringByURLEncoding:NSStringURLEncodingUser]);
NSLogA(@"#Password  : %@", [str stringByURLEncoding:NSStringURLEncodingPassword]);
NSLogA(@"#Host      : %@", [str stringByURLEncoding:NSStringURLEncodingHost]);
NSLogA(@"#Path      : %@", [str stringByURLEncoding:NSStringURLEncodingPath]);
NSLogA(@"#Query     : %@", [str stringByURLEncoding:NSStringURLEncodingQuery]);
NSLogA(@"#Fragment  : %@", [str stringByURLEncoding:NSStringURLEncodingFragment]);
```
> Output:

```
#Char      :  ~`!@#$%^&*()-_=+[{]}\|;:'",<.>/?
#User      : %20~%60!%40%23$%25%5E&*()-_=+%5B%7B%5D%7D%5C%7C;%3A'%22,%3C.%3E%2F%3F
#Password  : %20~%60!%40%23$%25%5E&*()-_=+%5B%7B%5D%7D%5C%7C;%3A'%22,%3C.%3E%2F%3F
#Host      : %20~%60!%40%23$%25%5E&*()-_=+%5B%7B%5D%7D%5C%7C;%3A'%22,%3C.%3E%2F%3F
#Path      : %20~%60!@%23$%25%5E&*()-_=+%5B%7B%5D%7D%5C%7C%3B%3A'%22,%3C.%3E/%3F
#Query     : %20~%60!@%23$%25%5E&*()-_=+%5B%7B%5D%7D%5C%7C;:'%22,%3C.%3E/?
#Fragment  : %20~%60!@%23$%25%5E&*()-_=+%5B%7B%5D%7D%5C%7C;:'%22,%3C.%3E/?
```

* NSURL+ZXToolbox

```
    NSURL *url1 = [NSURL URLWithString:@"http://www.example.com/" scheme:@"https" user:@"user" password:@"password" host:@"host" port:@2022 path:@"/path" query:@"key1=value1&key2=value2" fragment:@"fragment"];
    NSURL *url2 = [NSURL URLWithString:@"http://www.example.com" scheme:@"https" user:@"user" password:@"password" host:@"host" port:@2022 path:@"/path!@#$%^&*()" query:@{@"key1":@"value1", @"key2":@"value2"} fragment:@"fragment"];
    NSLogA(@"#URL1: %@", [url1 URLString]);
    NSLogA(@"#URL2: %@", [url2 URLString]);
```

> Output:

```
#URL1: https://user:password@host:2022/path?key1=value1&key2=value2#fragment
#URL2: https://user:password@host:2022/path!@%23$%25%5E&*()?key1=value1&key2=value2#fragment
```

### UIKit

* UIApplication+ZXToolbox

```
UIApplication.sharedApplication.idleTimerEnabled = NO;
[UIApplication.sharedApplication openSettingsURL];
[UIApplication.sharedApplication exitWithCode:0 afterDelay:1];
```

* UIButton+ZXToolbox

```
UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
[button setImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
[button setTitle:@"button" forState:UIControlStateNormal];
button.titleImageLayout = UIButtonTitleImageLayoutRight;
button.titleImageSpacing = 10;
NSLogA(@"#title: %@", NSStringFromUIEdgeInsets(button.titleEdgeInsets));
NSLogA(@"#image: %@", NSStringFromUIEdgeInsets(button.imageEdgeInsets));
```
> Output:

```
#title: {0, -5, 0, 5}
#image: {0, 5, 0, -5}
```

* UIColor+ZXToolbox

```
NSLogA(@"#[UIColor colorWithHEXString:] %@", [UIColor colorWithHEXString:@"#999999"]);
NSLogA(@"#[UIColor colorWithHEXString:alpha:] %@", [UIColor colorWithHEXString:@"#999999" alpha:0.5]);
NSLogA(@"#[UIColor colorWithRGBInteger:] %@", [UIColor colorWithRGBInteger:0x999999]);
NSLogA(@"#[UIColor colorWithRGBInteger:alpha:] %@", [UIColor colorWithRGBInteger:0x999999 alpha:0.5]);
NSLogA(@"#[UIColor randomColor] %@", [UIColor randomColor]);
NSLogA(@"#[UIColor inverseColor] %@", [[UIColor blackColor] inverseColor]);
NSLogA(@"#[UIColor NStringValue] %@", [[UIColor redColor] NSStringValue]);
NSLogA(@"#[UIColor NSIntegerValue] %lx", (long)[[UIColor redColor] NSIntegerValue]);
UIColorComponents gc = [[UIColor colorWithWhite:0.1 alpha:0.7] grayscaleComponents];
NSLogA(@"#[UIColor grayscaleComponents:] white: %f alpha: %f", gc.white, gc.alpha);
gc = [[UIColor colorWithHue:0.2 saturation:0.5 brightness:0.8 alpha:0.1] HSBComponents];
NSLogA(@"#[UIColor HSBComponents:] h: %f s: %f b: %f alpha: %f", gc.hue, gc.saturation, gc.brightness, gc.alpha);
gc = [[UIColor colorWithRed:0.3 green:0.6 blue:0.9 alpha:1.0] RGBComponents];
NSLogA(@"#[UIColor RGBComponents:] r: %f g: %f b: %f alpha: %f", gc.red, gc.green, gc.blue, gc.alpha);
```
> Output:

```
#[UIColor colorWithHEXString:] UIExtendedSRGBColorSpace 0.6 0.6 0.6 1
#[UIColor colorWithHEXString:alpha:] UIExtendedSRGBColorSpace 0.6 0.6 0.6 0.5
#[UIColor colorWithRGBInteger:] UIExtendedSRGBColorSpace 0.6 0.6 0.6 1
#[UIColor colorWithRGBInteger:alpha:] UIExtendedSRGBColorSpace 0.6 0.6 0.6 0.5
#[UIColor randomColor] UIExtendedSRGBColorSpace 0.921569 0.545098 0.992157 1
#[UIColor inverseColor] UIExtendedSRGBColorSpace 1 1 1 1
#[UIColor NStringValue] FF0000
#[UIColor NSIntegerValue] ff0000
#[UIColor grayscaleComponents:] white: 0.100000 alpha: 0.700000
#[UIColor HSBComponents:] h: 0.200000 s: 0.500000 b: 0.800000 alpha: 0.100000
#[UIColor RGBComponents:] r: 0.300000 g: 0.600000 b: 0.900000 alpha: 1.000000
```

* UIControl+ZXToolbox.h

```
UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
button.timeIntervalByUserInteractionEnabled = YES;
[button setTimeInteval:1 forControlEvents:UIControlEventTouchUpInside];
[button removeTimeIntevalForControlEvents:UIControlEventTouchUpInside];
```

* UIDevice+ZXToolbox

```
NSLogA(@"#CPU Bits: %d", [UIDevice currentDevice].cpuBits);
NSLogA(@"#CPU Type: %d", [UIDevice currentDevice].cpuType);
NSLogA(@"#Model Type: %@", [UIDevice currentDevice].modelType);
NSLogA(@"#Model Name: %@", [UIDevice currentDevice].modelName);
NSLogA(@"#UDIDString: %@", [UIDevice currentDevice].UDIDString);
NSLogA(@"#FileSystemSize: %lld bytes", [UIDevice currentDevice].fileSystemSize);
NSLogA(@"#FileSystemFreeSize: %lld bytes", [UIDevice currentDevice].fileSystemFreeSize);
NSLogA(@"#FileSystemUsedSize: %lld bytes", [UIDevice currentDevice].fileSystemUsedSize);
NSLogA(@"#isProximityMonitoringEnabled: %d", [UIDevice currentDevice].isProximityMonitoringEnabled);
NSLogA(@"#proximityState: %d", [UIDevice currentDevice].proximityState);
```
> Output:

```
#CPU Bits: 64
#CPU Type: 7
#Model Type: iPhone10,4
#Model Name: iPhone 8
#UDIDString: 2231ccf4007eb74442c8ae7cc2471e65b34d9af5
#FileSystemSize: 499933818880 bytes
#FileSystemFreeSize: 271827771392 bytes
#FileSystemUsedSize: 228106047488 bytes
#isProximityMonitoringEnabled: 0
#proximityState: 0
```

* UIImage+ZXToolbox

```
UIImage *image = [UIImage imageWithColor:[UIColor blueColor] size:CGSizeMake(1000, 1000)];
UIImage *blurImage = [image blurImage:10];
UIImage *grayImage = [image grayscaleImage];
UIImage *thumbImage = [image thumbnailImage:CGSizeMake(100, 100) aspect:NO];
NSData *data = [image compressToData:1024 * 2];
NSLogA(@"#[UIImage imageWithColor:size:]%@", image);
NSLogA(@"#[UIImage blurImage:]%@", blurImage);
NSLogA(@"#[UIImage grayscaleImage]%@", grayImage);
NSLogA(@"#[UIImage thumbnailImage:aspect:]%@", thumbImage);
NSLogA(@"#[UIImage compressToData:] -> %ld bytes", (long)data.length);
```
> Output:

```
#[UIImage imageWithColor:size:]<UIImage: 0x60000244afb0>, {1000, 1000}
#[UIImage blurImage:]<UIImage: 0x600006458000>, {1000, 1000}
#[UIImage grayscaleImage]<UIImage: 0x600006458540>, {1000, 1000}
#[UIImage thumbnailImage:aspect:]<UIImage: 0x6000064591f0>, {100, 100}
#[UIImage compressToData:] -> 2020 bytes
```

* UINavigationBar+ZXToolbox
> 204 No Content

* UINavigationController+ZXToolbox
> 204 No Content

* UIScreen+ZXToolbox

```
CGSize size = CGSizeMake(100, 100);
NSLogA(@"#adapt height: %.2f for base width %.2f = %.2f", size.height, size.width, [UIScreen adaptHeight:size.height forBaseWidth:size.width]);
NSLogA(@"#adapt height: %.2f for base width %.2f = %.2f", size.width, size.height, [UIScreen adaptWidth:size.width forBaseHeight:size.height]);
```
> Output:

```
#adapt height: 100.00 for base width 100.00 = 375.00
#adapt height: 100.00 for base width 100.00 = 667.00
```

* UIScrollView+ZXToolbox

```
- (void)viewDidLoad {
    // 父视图设置
    scrollView.shouldRecognizeSimultaneously = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 垂直滚动时用y值做判断，横向滚动时用x值做判断
    CGFloat y = 100;
    //
    if (scrollView.isScrollFreezed) {
        // 冻结时，固定滚动位置
        scrollView.contentOffset.y = y;
    } else if (scrollView.contentOffset.y >= y) {
        // 滚动距离超过y时，固定滚动位置，并冻结
        scrollView.contentOffset.y = y;
        scrollView.isScrollFreezed = YES;
    } else if (scrollView.contentOffset.y < 0) {
        // 如果子视图包含刷新header，建议加上此条逻辑
        scrollView.contentOffset.y = 0;
    }
}
```

```
// 此处需要从外部传入与此联动的父视图
UIScrollView *superView = nil;
// 当前的滚动视图
UIScrollView *childView = nil;

- (void)viewDidLoad {
    // 子视图冻结设置正好与父视图相反
    childView.isScrollFreezed = !superView.isScrollFreezed;
    // 父子视图相互添加对方到自己的冻结列表内
    childView.freezedViews.addObject(superView);
    superView.freezedViews.addObject(childView);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 垂直滚动时用y值做判断，0为最顶部，横向滚动时用x值做判断
    CGFloat y = 0;
    // 没有刷新header时的逻辑
    if (scrollView.isScrollFreezed) {
        // 冻结时, 固定滚动位置
        scrollView.contentOffset.y = y;
    } else if (scrollView.contentOffset.y <= y) {
        // 滚动距离小于等于y时，固定滚动位置，并冻结
        scrollView.contentOffset.y = y;
        scrollView.isScrollFreezed = YES;
    }
    // 包含刷新header时的逻辑
    if (scrollView.isScrollFreezed) {
        if (scrollView.contentOffset.y > y) {
            scrollView.contentOffset.y = y;
        }
    } else if (scrollView.contentOffset.y <= y) {
        scrollView.isScrollFreezed = YES;
    }
}
```

* UITableViewCell+ZXToolbox
> 204 No Content

* UITextField+ZXToolbox
> 204 No Content

* UIView+ZXToolbox
> 204 No Content

* UIViewController+ZXToolbox
> 204 No Content

### ZXKit

* ZXTextAttributes
> 204 No Content

* ZXAuthorizationHelper
> 204 No Content

* ZXBrightnessView
> 204 No Content

* ZXCircularProgressView
> 204 No Content

* ZXCommonCrypto

```
CCAlgorithm alg = kCCAlgorithmAES;
CCMode mode = kCCModeCBC;
CCPadding padding = ccPKCS7Padding;
id iv = @"1234567890123456";
id key = @"12345678901234561234567890123456";
id value = @"1234567890123456";
NSError *error = nil;
NSData *data = nil;
// encrypt
data = [value encryptedDataUsingAlgorithm:alg mode:mode padding:padding key:key iv:iv error:&error];
if (error) {
    NSLogA(@"#error: %@", error);
} else {
    value = [data base64EncodedStringWithOptions:0];
    NSLogA(@"#encoded: %@", value);
}
// decrypt
data = [data decryptedDataUsingAlgorithm:alg mode:mode padding:padding key:key iv:iv error:&error];
if (error) {
    NSLogA(@"#error: %@", error);
} else {
    value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLogA(@"#decoded: %@", value);
}
```
> Output:

```
#encoded: fY6VcNMCC2MXj6dlzPbh3m2WqBnA1HW+qKMAeQqmAxI=
#decoded: 1234567890123456
```

* ZXCoordinate2D

```
ZXCoordinate2D world = ZXCoordinate2DMake(40.01845989630743, 116.461795056622);
NSLogA(@"#WGS-84: %f, %f", world.latitude, world.longitude);
ZXCoordinate2D china = ZXCoordinate2DWorldToChina(world);
NSLogA(@"#GCJ-02: %f, %f", china.latitude, china.longitude);
ZXCoordinate2D baidu = ZXCoordinate2DChinaToBaidu(china);
NSLogA(@"#BD-09: %f, %f", baidu.latitude, baidu.longitude);
china = ZXCoordinate2DBaiduToChina(baidu);
NSLogA(@"#GCJ-02: %f, %f", china.latitude, china.longitude);
world = ZXCoordinate2DChinaToWorld(china);
NSLogA(@"#WGS-84: %f, %f", world.latitude, world.longitude);
NSLogA(@"#W-C: %fm", ZXCoordinate2DDistanceMeters(world, china));
NSLogA(@"#C-B: %fm", ZXCoordinate2DDistanceMeters(china, baidu));
NSLogA(@"#W-B: %fm", ZXCoordinate2DDistanceMeters(world, baidu));
```
> Output:

```
#WGS-84: 40.018460, 116.461795
#GCJ-02: 40.019793, 116.467953
#BD-09: 40.025828, 116.474442
#GCJ-02: 40.019793, 116.467953
#WGS-84: 40.018475, 116.461815
#W-C: 543.431461m
#C-B: 870.298132m
#W-B: 1352.293468m
```
* ZXDeallocObject
> 204 No Content

* ZXDebugTools
> 204 No Content

* ZXDispatchQueue
> 204 No Content

* ZXDownloader

```
NSURL *url = [NSURL URLWithString:@"https://vod.300hu.com/4c1f7a6atransbjngwcloud1oss/4bb3e4c1242645539656048641/v.f30.mp4"];
ZXDownloadTask *task = [ZXDownloader.defaultDownloader downloadTaskWithURL:url];
[task addObserver:self state:^(NSURLSessionTaskState state, NSString * _Nullable filePath, NSError * _Nullable error) {
    NSLogA(@"#state: %d filePath: %@ error: %@", (int)state, filePath, error);
    if (filePath) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
} progress:^(int64_t receivedSize, int64_t expectedSize, float progress) {
    NSLogA(@"#receivedSize: %lld expectedSize: %lld progress: %.2f", receivedSize, expectedSize, progress);
}];
[task resume];
```
> Output:

```
#state: 0 filePath: /Users/.../Library/Caches/ZXDownloader/3b27598d16cdcba625ae5f6a3985b8dc432fd8a3 error: (null)
#receivedSize: 0 expectedSize: 5597141 progress: 0.00
...
#receivedSize: 5597141 expectedSize: 5597141 progress: 1.00
#state: 3 filePath: /Users/.../Library/Caches/ZXDownloader/v.f30.mp4 error: (null)
```

* ZXDrawingView
> 204 No Content

* ZXHaloLabel
> 204 No Content

* ZXHTTPClient
> 204 No Content

* ZXImageBroswer
> 204 No Content

* ZXKeychain

```
NSString *key = @"ZXKeychainDemoTests";
NSString *text = [NSUUID UUID].UUIDString;
ZXKeychain *keychain = [[ZXKeychain alloc] init];
// add
if ([keychain setString:text forKey:key]) {
    NSLogA(@"#add success: %@", text);
} else {
    NSLogA(@"#add error: %@", keychain.lastError);
}
// allkeys
NSArray *keys = [keychain allKeys];
if (keys) {
    NSLogA(@"#all keys: %@", keys);
} else {
    NSLogA(@"#all keys error: %@", keychain.lastError);
}
// search
text = [keychain stringForKey:key];
if (text) {
    NSLogA(@"#search result: %@", text);
} else {
    NSLogA(@"#search error: %@", keychain.lastError);
}
// delete
if ([keychain removeItemForKey:key]) {
    NSLogA(@"#delete success!");
} else {
    NSLogA(@"#delete error: %@", keychain.lastError);
}
// clear
if ([keychain removeAllItems]) {
    NSLogA(@"#delete all success!");
} else {
    NSLogA(@"#delete all error: %@", keychain.lastError);
}
```
> Output:

```
#add success: C48040FB-4527-4799-A2BF-1C91FCCEFD94
#all keys: (
    ZXToolboxUniqueDeviceIdentifierKey,
    ZXKeychainDemoTests
)
#search result: C48040FB-4527-4799-A2BF-1C91FCCEFD94
#delete success!
#delete all success!
```

* ZXKeyValueObserver

```
ZXDownloader *obj = [ZXDownloader defaultDownloader];
ZXKeyValueObserver *obs = [[ZXKeyValueObserver alloc] init];
[obs observe:obj keyPath:@"downloadPath" options:NSKeyValueObservingOptionNew context:NULL changeHandler:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, void * _Nullable context) {
    NSLogA(@"%@", [change objectForKey:NSKeyValueChangeNewKey]);
}];
obj.downloadPath = @"1";
obj.downloadPath = @"2";
obj.downloadPath = @"3";
[obs invalidate];
obj.downloadPath = @"4";
obj.downloadPath = @"5";
obj.downloadPath = @"6";
```
> Output:

```
1
2
3
```

* ZXLineChartView
> 204 No Content

* ZXLocalAuthentication

```
NSLogA(@"#canEvaluatePolicy:%d", [ZXLocalAuthentication canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics]);
```
> Output:

```
#canEvaluatePolicy:0
```

* ZXLocationManager

```
ZXLocationManager *lm = [[ZXLocationManager alloc] init];
lm.didUpdateLocation = ^(CLLocation * _Nonnull location, CLPlacemark * _Nullable placemark) {
    NSLogA(@"#location: %@", location);
    NSLogA(@"#province: %@", placemark.province);
    NSLogA(@"#city: %@", placemark.city);
    NSLogA(@"#district: %@", placemark.district);
    NSLogA(@"#street: %@", placemark.street);
    NSLogA(@"#streetNumber: %@", placemark.streetNumber);
    NSLogA(@"#address: %@", placemark.address);
};
if (@available(iOS 9.0, *)) {
    [lm requestLocation];
}
```
> Output:

```
#location: <+40.02009000,+116.46741800>
#province: 北京市
#city: 北京市
#district: 朝阳区
#street: 广顺北大街
#streetNumber: (null)
#address: (
    "中国北京市朝阳区广顺北大街"
)
```

* ZXNavigationController
> 204 No Content

* ZXNetworkTrafficMonitor

```
ZXNetworkTrafficMonitor *tm = [[ZXNetworkTrafficMonitor alloc] init];
ZXNetworkTrafficData *data = tm.currentTrafficData;
NSLogA(@"#WiFiSent:     %lld bytes", data.WiFiSent);
NSLogA(@"#WiFiReceived: %lld bytes", data.WiFiReceived);
NSLogA(@"#WWANSent:     %lld bytes", data.WWANSent);
NSLogA(@"#WWANReceived: %lld bytes", data.WWANReceived);
```
> Output:

```
#WiFiSent:     527789056 bytes
#WiFiReceived: 3915675648 bytes
#WWANSent:     0 bytes
#WWANReceived: 0 bytes
```

* ZXPageIndicatorView
> 204 No Content

* ZXPageView
> 204 No Content

* ZXPhotoLibrary

```
[ZXPhotoLibrary requestAuthorization:^(AVAuthorizationStatus status) {
    if (status == AVAuthorizationStatusAuthorized) {
        UIImage *image = [UIImage imageWithColor:[UIColor randomColor] size:[UIScreen mainScreen].bounds.size];
        [[ZXPhotoLibrary sharedPhotoLibrary] saveImage:image toSavedPhotoAlbum:^(NSError *error) {
            NSLogA(@"%@", error ? error.localizedDescription : @"#success");
        }];
    } else {
        NSLogA(@"没有权限");
    }
}];
```
> Output:

```
#success
```

* ZXPlayer
> 204 No Content

* ZXPlayerViewController
> 204 No Content

* ZXPopoverView
> 204 No Content

* ZXQRCodeGenerator

```
UIImage *image = [ZXQRCodeGenerator imageWithText:@"ZXQRCodeGenerator"];
NSLogA(@"#ZXQRCodeGenerator %@", image);
```
> Output:

```
#ZXQRCodeGenerator <UIImage: 0x600003fa1d50>, {27, 27}
```

* ZXQRCodeReader

```
UIImage *image = [ZXQRCodeGenerator imageWithText:@"ZXQRCodeReader"];
id results = [ZXQRCodeReader decodeQRCodeImage:image];
NSLogA(@"#ZXQRCodeReader %@", results);
```
> Output:

```
#ZXQRCodeReader (
    ZXQRCodeReader
)
```

* ZXQRCodeScanner
> 204 No Content

* ZXScriptMessageHandler
> 204 No Content

* ZXSemaphore
> 204 No Content

* ZXStackView
> 204 No Content

* ZXTabBar
> 204 No Content

* ZXTabBarController
> 204 No Content

* ZXTagView
> 204 No Content

* ZXTimer
> 204 No Content

* ZXToastView
> 204 No Content

* ZXToolbox+Macros
> 204 No Content

* ZXURLProtocol
> 204 No Content

* ZXURLSession
> 204 No Content

## License

`ZXToolbox` is available under the MIT license. See the `LICENSE` file for more info.
