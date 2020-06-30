//
//  ZXQRCodeGeneratorViewController.m
//  ZXToolboxDemo
//
//  Created by xyz on 2020/6/28.
//  Copyright © 2020 xinyzhao. All rights reserved.
//

#import "ZXQRCodeGeneratorViewController.h"

@interface ZXQRCodeGeneratorViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UITextField *foregroundColorField;
@property (nonatomic, weak) IBOutlet UITextField *backgroundColorField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *correctionLevelControl;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation ZXQRCodeGeneratorViewController

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

- (IBAction)onGenerate:(id)sender {
    NSString *text = _textView.text;
    if (text == nil || text.length == 0) {
        ZXToastView *toastView = [[ZXToastView alloc] initWithText:@"Please input text"];
        [toastView showInView:self.view];
        return;
    }
    UIColor *foreColor = UIColor.blackColor;
    if (_foregroundColorField.text.length > 0) {
        foreColor = [UIColor colorWithString:_foregroundColorField.text];
    }
    UIColor *backColor = UIColor.whiteColor;
    if (_backgroundColorField.text.length > 0) {
        backColor = [UIColor colorWithString:_backgroundColorField.text];
    }
    NSString *level = ZXQRCodeCorrectionLevelMedium;
    switch (_correctionLevelControl.selectedSegmentIndex) {
        case 0:
            level = ZXQRCodeCorrectionLevelLow;
            break;
        case 1:
            level = ZXQRCodeCorrectionLevelMedium;
            break;
        case 2:
            level = ZXQRCodeCorrectionLevelQuarter;
            break;
        case 3:
            level = ZXQRCodeCorrectionLevelHigh;
            break;
    }
    _imageView.image = [ZXQRCodeGenerator imageWithText:text size:_imageView.bounds.size color:foreColor backgroundColor:backColor correctionLevel:level];
}

@end
