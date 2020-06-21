//
//  ViewController.m
//  ZXToolboxDemo
//
//  Created by xyz on 2020/1/9.
//  Copyright © 2020 xinyzhao. All rights reserved.
//

#import "ViewController.h"
#import <ZXToolbox/ZXToolbox.h>

@interface ViewController ()
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ViewController

+ (instancetype)instantiate {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"ViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    self.title = [NSString stringWithFormat:@"%@/%@/%@",
                  info[@"CFBundleName"],
                  info[@"CFBundleShortVersionString"],
                  info[@"CFBundleVersion"]
                  ];
    //
    self.dataArray = @[
        @{@"title":@"Foundation",
          @"rows":@[
                  @"Base64Encoding",
                  @"JSONObject",
                  @"NSArray+ZXToolbox",
                  @"NSDate+ZXToolbox",
                  @"NSFileManager+ZXToolbox",
                  @"NSNumberFormatter+ZXToolbox",
                  @"NSObject+ZXToolbox",
                  @"NSString+NumberValue",
                  @"NSString+Pinyin",
                  @"NSString+Unicode",
                  @"NSString+URLEncoding"
          ]
        },
        @{@"title":@"UIKit",
          @"rows":@[
                  @"UIApplication+ZXToolbox",
                  @"UIButton+ZXToolbox",
                  @"UIColor+ZXToolbox",
                  @"UIControl+ZXToolbox",
                  @"UIDevice+ZXToolbox",
                  @"UIImage+ZXToolbox",
                  @"UINavigationBar+ZXToolbox",
                  @"UINavigationController+ZXToolbox",
                  @"UIScreen+ZXToolbox",
                  @"UIScrollView+ZXToolbox",
                  @"UITableViewCell+ZXToolbox",
                  @"UITextField+ZXToolbox",
                  @"UIView+ZXToolbox",
                  @"UIViewController+ZXToolbox"
          ]
        },
        @{@"title":@"ZXKit",
          @"rows":@[
                  @"ZXAudioDevice",
                  @"ZXAuthorizationHelper",
                  @"ZXBadgeLabel",
                  @"ZXBrightnessView",
                  @"ZXCircularProgressView",
                  @"ZXCommonCrypto",
                  @"ZXCoordinate2D",
                  @"ZXDownloader",
                  @"ZXDrawingView",
                  @"ZXHTTPClient",
                  @"ZXHaloLabel",
                  @"ZXImageBroswer",
                  @"ZXKeychain",
                  @"ZXLineChartView",
                  @"ZXLocalAuthentication",
                  @"ZXLocationManager",
                  @"ZXNavigationController",
                  @"ZXNetworkTrafficMonitor",
                  @"ZXPageIndicatorView",
                  @"ZXPageView",
                  @"ZXPhotoLibrary",
                  @"ZXPlayer",
                  @"ZXPlayerViewController",
                  @"ZXPopoverView",
                  @"ZXPopoverWindow",
                  @"ZXQRCodeGenerator",
                  @"ZXQRCodeReader",
                  @"ZXQRCodeScanner",
                  @"ZXScriptMessageHandler",
                  @"ZXStackView",
                  @"ZXTabBar",
                  @"ZXTabBarController",
                  @"ZXTagView",
                  @"ZXTimer",
                  @"ZXToastView",
                  @"ZXToolbox+Macros",
                  @"ZXURLProtocol",
                  @"ZXURLSession"
          ]
        }
    ];
    [self.tableView reloadData];
}

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dict = _dataArray[section];
    NSArray *rows = dict[@"rows"];
    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dict = _dataArray[indexPath.section];
    NSArray *rows = dict[@"rows"];
    cell.textLabel.text = rows[indexPath.row];
    return cell;
}

#pragma mark <UITableViewDelegate>

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *dict = _dataArray[section];
    return dict[@"title"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = _dataArray[indexPath.section];
    NSArray *rows = dict[@"rows"];
    NSString *row = rows[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
