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
    UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    _imageView.gestureRecognizers = @[gr];
    _imageView.userInteractionEnabled = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_textView becomeFirstResponder];
}

- (IBAction)onGenerate:(id)sender {
    NSString *text = _textView.text;
    if (text == nil || text.length == 0) {
        ZXToastView *toastView = [[ZXToastView alloc] initWithText:@"Please input text"];
        [toastView showInView:self.view];
        return;
    }
    //
    [_textView resignFirstResponder];
    [_foregroundColorField resignFirstResponder];
    [_backgroundColorField resignFirstResponder];
    //
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
    //
    _imageView.image = [ZXQRCodeGenerator imageWithText:text size:_imageView.bounds.size color:foreColor backgroundColor:backColor correctionLevel:level];
}

- (IBAction)onLongPress:(id)sender {
    UIImage *image = _imageView.image;
    if (image) {
        __weak typeof(self) weakSelf = self;
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *copy = [UIAlertAction actionWithTitle:@"Copy to pasteboard" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIPasteboard generalPasteboard] setImage:image];
            AudioServicesPlaySystemSound(1001);
            ZXToastView *toastView = [[ZXToastView alloc] initWithText:@"Copy success"];
            [toastView showInView:weakSelf.view];
        }];
        UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save to photo album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ZXPhotoLibrary requestAuthorization:^(AVAuthorizationStatus status) {
                switch (status) {
                    case AVAuthorizationStatusAuthorized:
                    {
                        [[ZXPhotoLibrary sharedPhotoLibrary] saveImage:image toSavedPhotoAlbum:^(NSError *error) {
                            NSString *msg = error ? error.localizedDescription : @"Save success";
                            ZXToastView *toastView = [[ZXToastView alloc] initWithText:msg];
                            [toastView showInView:weakSelf.view];
                        }];
                        break;
                    }
                    default:
                    {
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                        UIAlertAction *settings = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [[UIApplication sharedApplication] openSettingsURL];
                        }];
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Authorization" message:@"Saving the image requires access to the album authorization" preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:cancel];
                        [alert addAction:settings];
                        [weakSelf presentViewController:alert animated:YES completion:nil];
                        break;
                    }
                }
            }];
        }];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Operations" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:cancel];
        [alert addAction:copy];
        [alert addAction:save];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
