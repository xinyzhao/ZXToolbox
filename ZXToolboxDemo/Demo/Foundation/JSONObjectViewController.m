//
//  JSONObjectViewController.m
//  ZXToolboxDemo
//
//  Created by xyz on 2020/6/23.
//  Copyright © 2020 xinyzhao. All rights reserved.
//

#import "JSONObjectViewController.h"

@interface JSONObjectViewController ()

@end

@implementation JSONObjectViewController

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

- (IBAction)onParse:(id)sender {
    if (_textView.text.length > 0) {
        id obj = [_textView.text JSONObject];
        if ([obj isValidJSONObject]) {
            NSError *error;
            NSString *str = [obj JSONStringWithOptions:0 error:&error];
            if (error) {
                ZXToastView *toastView = [[ZXToastView alloc] init];
                [toastView showText:error.localizedDescription];
                [toastView hideAfter:2];
            } else {
                _textView.text = str;
            }
        } else {
            ZXToastView *toastView = [[ZXToastView alloc] init];
            [toastView showText:@"Not valid json"];
            [toastView hideAfter:2];
        }
    }
}

- (IBAction)onPretty:(id)sender {
    if (_textView.text.length > 0) {
        id obj = [JSONObject JSONObjectWithString:_textView.text];
        if ([JSONObject isValidJSONObject:obj]) {
            NSError *error;
            NSString *str = [obj JSONStringWithOptions:NSJSONWritingPrettyPrinted error:&error];
            if (error) {
                ZXToastView *toastView = [[ZXToastView alloc] init];
                [toastView showText:error.localizedDescription];
                [toastView hideAfter:2];
            } else {
                _textView.text = str;
            }
        } else {
            ZXToastView *toastView = [[ZXToastView alloc] init];
            [toastView showText:@"Not valid json"];
            [toastView hideAfter:2];
        }
    }
}

@end
