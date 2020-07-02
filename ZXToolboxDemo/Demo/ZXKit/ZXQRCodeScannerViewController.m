//
//  ZXQRCodeScannerViewController.m
//  ZXToolboxDemo
//
//  Created by xyz on 2020/6/28.
//  Copyright © 2020 xinyzhao. All rights reserved.
//

#import "ZXQRCodeScannerViewController.h"

@interface ZXQRCodeScannerViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, strong) ZXQRCodeScanner *scanner;

@end

@implementation ZXQRCodeScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _scanner = [[ZXQRCodeScanner alloc] initWithPreview:_imageView captureRect:_imageView.bounds];
    [self startScanning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onTorch:(id)sender {
    if (_scanner.torchLevel < 1) {
        _scanner.torchLevel = 1;
    } else {
        _scanner.torchLevel = 0;
    }
}

- (IBAction)onCopy:(id)sender {
    [UIPasteboard generalPasteboard].string = _textView.text;
    AudioServicesPlaySystemSound(1001);
    ZXToastView *toastView = [[ZXToastView alloc] initWithText:@"Copy success"];
    [toastView showInView:_textView];
}

- (IBAction)onScan:(id)sender {
    _textView.text = nil;
    [self startScanning];
}

- (void)startScanning {
    __weak typeof(self) weakSelf = self;
    [_scanner startScanning:^(NSArray<NSString *> *outputs) {
        AudioServicesPlaySystemSound(1004);
        [weakSelf.scanner stopScanning];
        weakSelf.textView.text = [outputs componentsJoinedByString:@"\n"];
    }];
}

@end
