//
//  MainViewController.m
//  ZXToolboxDemo
//
//  Created by xyz on 2020/1/9.
//  Copyright © 2020 xinyzhao. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation MainViewController

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
                  @"AVAsset+ZXToolbox",
                  @"AVAudioSession+ZXToolbox",
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
                  @"ZXAuthorizationHelper",
                  @"ZXBrightnessView",
                  @"ZXCircularProgressView",
                  @"ZXCommonCrypto",
                  @"ZXCoordinate2D",
                  @"ZXDeallocObject",
                  @"ZXDebugTools",
                  @"ZXDispatchQueue",
                  @"ZXDownloader",
                  @"ZXDrawingView",
                  @"ZXHTTPClient",
                  @"ZXHaloLabel",
                  @"ZXImageBroswer",
                  @"ZXKeychain",
                  @"ZXKeyValueObserver",
                  @"ZXLineChartView",
                  @"ZXLocalAuthentication",
                  @"ZXLocationManager",
                  @"ZXNetworkTrafficMonitor",
                  @"ZXPageIndicatorView",
                  @"ZXPageView",
                  @"ZXPhotoLibrary",
                  @"ZXPlayer",
                  @"ZXPlayerViewController",
                  @"ZXPopoverView",
                  @"ZXQRCodeGenerator",
                  @"ZXQRCodeReader",
                  @"ZXQRCodeScanner",
                  @"ZXScriptMessageHandler",
                  @"ZXSemaphore",
                  @"ZXStackView",
                  @"ZXTabBar",
                  @"ZXTabBarController",
                  @"ZXTagView",
                  @"ZXTextAttributes",
                  @"ZXTimer",
                  @"ZXToastView",
                  @"ZXToolbox+Macros",
                  @"ZXURLProtocol",
                  @"ZXURLRouter",
                  @"ZXURLSession"
          ]
        }
    ];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender {
    UIViewController *vc = segue.destinationViewController;
    vc.title = segue.identifier;
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
    @try {
        [self performSegueWithIdentifier:row sender:self];
    } @catch(NSException *ex) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Exception" message:ex.description preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:cancel];
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = self.view.frame;
        [self presentViewController:alert animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
