//
//  Base64EncodingViewController.m
//  ZXToolboxDemo
//
//  Created by xyz on 2020/6/23.
//  Copyright © 2020 xinyzhao. All rights reserved.
//

#import "Base64EncodingViewController.h"

@interface Base64EncodingViewController ()

@end

@implementation Base64EncodingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onEncode:(id)sender {
    _textView.text = [_textView.text base64EncodedStringWithOptions:0];
}

- (IBAction)onDecode:(id)sender {
    if (_textView.text.length > 0) {
        NSString *str = [_textView.text base64DecodedStringWithOptions:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (str.length > 0) {
            _textView.text = str;
        } else {
            ZXToastView *toastView = [[ZXToastView alloc] initWithText:@"Can't decoing"];
            [toastView showInView:self.textView];
        }
    }
}

- (IBAction)onCopy:(id)sender {
    if (_textView.text.length > 0) {
        [[UIPasteboard generalPasteboard] setString:_textView.text];
        AudioServicesPlaySystemSound(1001);
        ZXToastView *toastView = [[ZXToastView alloc] initWithText:@"Copied to clipboard"];
        [toastView showInView:self.textView];
    }
}

@end
