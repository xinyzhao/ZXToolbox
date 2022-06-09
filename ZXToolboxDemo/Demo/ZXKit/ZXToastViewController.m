//
//  ZXToastViewController.m
//  ZXToolboxDemo
//
//  Created by xyz on 2020/6/28.
//  Copyright © 2020 xinyzhao. All rights reserved.
//

#import "ZXToastViewController.h"
#import "NSString+NumberValue.h"

@interface ZXToastViewController ()
@property (weak, nonatomic) IBOutlet UITextView *messageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *animation;
@property (weak, nonatomic) IBOutlet UITextField *centerX;
@property (weak, nonatomic) IBOutlet UITextField *centerY;
@property (weak, nonatomic) IBOutlet UITextField *contentInsetTop;
@property (weak, nonatomic) IBOutlet UITextField *contentInsetLeft;
@property (weak, nonatomic) IBOutlet UITextField *contentInsetBottom;
@property (weak, nonatomic) IBOutlet UITextField *contentInsetRight;
@property (weak, nonatomic) IBOutlet UISegmentedControl *effectStyle;
@property (weak, nonatomic) IBOutlet UITextField *imageWidth;
@property (weak, nonatomic) IBOutlet UITextField *imageHeight;
@property (weak, nonatomic) IBOutlet UITextField *itemSpacing;
@property (weak, nonatomic) IBOutlet UITextField *safeAreaTop;
@property (weak, nonatomic) IBOutlet UITextField *safeAreaLeft;
@property (weak, nonatomic) IBOutlet UITextField *safeAreaBottom;
@property (weak, nonatomic) IBOutlet UITextField *safeAreaRight;
@property (weak, nonatomic) IBOutlet UISwitch *userInteraction;
@property (weak, nonatomic) IBOutlet UILabel *userInteractionLabel;
@property (weak, nonatomic) IBOutlet UITextField *hideAfterTime;

@property (nonatomic, strong) ZXToastView *toastView;

@end

@implementation ZXToastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _toastView = [[ZXToastView alloc] init];
    _toastView.userInteractionEnabled = NO;
    //
    switch (_toastView.animation) {
        case ZXToastAnimationNone:
            _animation.selectedSegmentIndex = 0;
            break;
        case ZXToastAnimationFade:
            _animation.selectedSegmentIndex = 1;
            break;
        case ZXToastAnimationScale:
            _animation.selectedSegmentIndex = 2;
            break;
    }
    //
    _centerX.text = [NSString stringWithFormat:@"%.1f", _toastView.centerPoint.x];
    _centerY.text = [NSString stringWithFormat:@"%.1f", _toastView.centerPoint.y];
    //
    _contentInsetTop.text = [NSString stringWithFormat:@"%.1f", _toastView.effectView.contentInset.top];
    _contentInsetLeft.text = [NSString stringWithFormat:@"%.1f", _toastView.effectView.contentInset.left];
    _contentInsetBottom.text = [NSString stringWithFormat:@"%.1f", _toastView.effectView.contentInset.bottom];
    _contentInsetRight.text = [NSString stringWithFormat:@"%.1f", _toastView.effectView.contentInset.right];
    //
    switch (_toastView.style) {
        case ZXToastStyleDark:
            _effectStyle.selectedSegmentIndex = 0;
            break;
        case ZXToastStyleLight:
            _effectStyle.selectedSegmentIndex = 1;
            break;
        default:
            _effectStyle.selectedSegmentIndex = 2;
            break;
    }
    //
    _imageWidth.text = [NSString stringWithFormat:@"%.1f", _toastView.effectView.imageSize.width];
    _imageHeight.text = [NSString stringWithFormat:@"%.1f", _toastView.effectView.imageSize.height];
    //
    _itemSpacing.text = [NSString stringWithFormat:@"%.1f", _toastView.effectView.itemSpacing];
    //
    _safeAreaTop.text = [NSString stringWithFormat:@"%.1f", _toastView.safeAreaInset.top];
    _safeAreaLeft.text = [NSString stringWithFormat:@"%.1f", _toastView.safeAreaInset.left];
    _safeAreaBottom.text = [NSString stringWithFormat:@"%.1f", _toastView.safeAreaInset.bottom];
    _safeAreaRight.text = [NSString stringWithFormat:@"%.1f", _toastView.safeAreaInset.right];
    //
    _userInteraction.on = _toastView.isUserInteractionEnabled;
    [self onUserInteraction:nil];
    //
    _hideAfterTime.text = @"2";
}

- (void)setupView {
    //
    switch (_animation.selectedSegmentIndex) {
        case 0:
            _toastView.animation = ZXToastAnimationNone;
            break;
        case 1:
            _toastView.animation = ZXToastAnimationFade;
            break;
        case 2:
            _toastView.animation = ZXToastAnimationScale;
            break;
    }
    //
    CGFloat x = _centerX.text.length > 0 ? [_centerX.text doubleValue] : 0.5;
    CGFloat y = _centerY.text.length > 0 ? [_centerY.text doubleValue] : 0.5;
    _toastView.centerPoint = CGPointMake(x, y);
    //
    CGFloat t = _contentInsetTop.text.length > 0 ? [_contentInsetTop.text doubleValue] : 0;
    CGFloat l = _contentInsetLeft.text.length > 0 ? [_contentInsetLeft.text doubleValue] : 0;
    CGFloat b = _contentInsetBottom.text.length > 0 ? [_contentInsetBottom.text doubleValue] : 0;
    CGFloat r = _contentInsetRight.text.length > 0 ? [_contentInsetRight.text doubleValue] : 0;
    _toastView.effectView.contentInset = UIEdgeInsetsMake(t, l, b, r);
    //
    switch (_effectStyle.selectedSegmentIndex) {
        case 0:
            _toastView.style = ZXToastStyleDark;
            break;
        case 1:
            _toastView.style = ZXToastStyleLight;
            break;
        default:
            _toastView.style = ZXToastStyleSystem;
            break;
    }
    //
    CGFloat w = _imageWidth.text.length > 0 ? [_imageWidth.text doubleValue] : 0;
    CGFloat h = _imageHeight.text.length > 0 ? [_imageHeight.text doubleValue] : 0;
    _toastView.effectView.imageSize = CGSizeMake(w, h);
    _toastView.effectView.loadingSize = CGSizeMake(w, h);
    //
    _toastView.effectView.itemSpacing = _itemSpacing.text.length > 0 ? [_itemSpacing.text doubleValue] : 0;
    //
    t = _safeAreaTop.text.length > 0 ? [_safeAreaTop.text doubleValue] : 0;
    l = _safeAreaLeft.text.length > 0 ? [_safeAreaLeft.text doubleValue] : 0;
    b = _safeAreaBottom.text.length > 0 ? [_safeAreaBottom.text doubleValue] : 0;
    r = _safeAreaRight.text.length > 0 ? [_safeAreaRight.text doubleValue] : 0;
    _toastView.safeAreaInset = UIEdgeInsetsMake(t, l, b, r);
    //
    _toastView.userInteractionEnabled = _userInteraction.isOn;
}

- (IBAction)onUserInteraction:(id)sender {
    _userInteractionLabel.text = _userInteraction.isOn ? @"Enabled" : @"Disabled";
}

- (IBAction)showText:(id)sender {
    [self setupView];
    NSString *text = _messageView.text;
    [_toastView showText:text];
}

- (IBAction)showImage:(id)sender {
    [self setupView];
    NSString *text = _messageView.text;
    NSString *file = ZXToolboxBundleFile(@"ZXBrightnessView.bundle", @"brightness@2x.png");
    UIImage *image = [UIImage imageWithContentsOfFile:file];
    [_toastView showImage:image text:text];
}

- (IBAction)showLoading:(id)sender {
    [self setupView];
    NSString *text = _messageView.text;
    [_toastView showLoading:text];
}

- (IBAction)showAnimated:(id)sender {
    [self setupView];
    //
    int seed = arc4random() % 100;
    _toastView.effectView.textLabel.text = _messageView.text;
    _toastView.effectView.imageView.hidden = seed < (arc4random() % 100);
    //
    NSString *file = ZXToolboxBundleFile(@"ZXBrightnessView.bundle", @"brightness@2x.png");
    UIImage *image = [UIImage imageWithContentsOfFile:file];
    _toastView.effectView.imageView.image = image;
    _toastView.effectView.imageView.hidden = seed < (arc4random() % 100);
    //
    if (_toastView.effectView.imageView.hidden) {
        [_toastView.effectView.loadingView startAnimating];
    } else {
        [_toastView.effectView.loadingView stopAnimating];
    }
    //
    [_toastView showAnimated:YES];
}

- (IBAction)hideAfter:(id)sender {
    NSTimeInterval time = _hideAfterTime.text.length > 0 ? [_hideAfterTime.text doubleValue] : 1;
    [_toastView hideAfter:time];
}

- (IBAction)hideAnimated:(id)sender {
    switch (_animation.selectedSegmentIndex) {
        case 0:
            _toastView.animation = ZXToastAnimationNone;
            break;
        case 1:
            _toastView.animation = ZXToastAnimationFade;
            break;
        case 2:
            _toastView.animation = ZXToastAnimationScale;
            break;
    }
    [_toastView hideAnimated:YES];
}

- (IBAction)hideToasts:(id)sender {
    [ZXToastView hideToasts];
}

@end
