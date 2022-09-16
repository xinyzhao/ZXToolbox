//
//  ZXTextAttributesViewController.m
//  ZXToolboxDemo
//
//  Created by xyz on 2021/7/16.
//  Copyright © 2021 xinyzhao. All rights reserved.
//

#import "ZXTextAttributesViewController.h"

@interface ZXTextAttributesViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;

@end

@implementation ZXTextAttributesViewController

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

- (IBAction)onFont:(UITextField *)textField {
    _textView.textAttributes.font = [UIFont systemFontOfSize: textField.text.floatValue];
    [_textView.textAttributes setAttributedString:_textView.text forKey:@"attributedText"];
}

- (IBAction)onForegroundColor:(UITextField *)textField {
    _textView.textAttributes.foregroundColor = ZXColorFromHEXString(textField.text, 1);
    [_textView.textAttributes setAttributedString:_textView.text forKey:@"attributedText"];
}

- (IBAction)onBackgroundColor:(UITextField *)textField {
    _textView.textAttributes.backgroundColor = ZXColorFromHEXString(textField.text, 1);
    [_textView.textAttributes setAttributedString:_textView.text forKey:@"attributedText"];
}

- (IBAction)onKerning:(UITextField *)textField {
    _textView.textAttributes.kern = textField.text.floatValue;
    [_textView.textAttributes setAttributedString:_textView.text forKey:@"attributedText"];
}

- (IBAction)onLineSpacing:(UITextField *)textField {
    _textView.textAttributes.paragraphStyle.lineSpacing = textField.text.floatValue;
    [_textView.textAttributes setAttributedString:_textView.text forKey:@"attributedText"];

}

@end
