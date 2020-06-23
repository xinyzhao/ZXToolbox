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
        id obj = [JSONObject JSONObjectWithString:_textView.text];
        if ([JSONObject isValidJSONObject:obj]) {
            NSError *error;
            NSString *str = [JSONObject stringWithJSONObject:obj options:0 error:&error];
            if (error) {
                ZXToastView *toastView = [[ZXToastView alloc] initWithText:error.localizedDescription];
                [toastView showInView:self.textView];
            } else {
                _textView.text = str;
            }
        } else {
            ZXToastView *toastView = [[ZXToastView alloc] initWithText:@"Not valid json"];
            [toastView showInView:self.textView];
        }
    }
}

- (IBAction)onPretty:(id)sender {
    if (_textView.text.length > 0) {
        id obj = [JSONObject JSONObjectWithString:_textView.text];
        if ([JSONObject isValidJSONObject:obj]) {
            NSError *error;
            NSString *str = [JSONObject stringWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
            if (error) {
                ZXToastView *toastView = [[ZXToastView alloc] initWithText:error.localizedDescription];
                [toastView showInView:self.textView];
            } else {
                _textView.text = str;
            }
        } else {
            ZXToastView *toastView = [[ZXToastView alloc] initWithText:@"Not valid json"];
            [toastView showInView:self.textView];
        }
    }
}

@end
