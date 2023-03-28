//
//  CALayerViewController.m
//  ZXToolboxDemo
//
//  Created by xyz on 2023/3/10.
//  Copyright © 2023 xinyzhao. All rights reserved.
//

#import "CALayerViewController.h"

@interface CALayerViewController ()

@end

@implementation CALayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateCorner];
}

- (IBAction)onTap:(id)sender {
    [self.textField resignFirstResponder];
    [self updateCorner];
}

- (IBAction)textFieldValueChanged:(id)sender {
    [self updateCorner];
}

- (IBAction)switchValueChanged:(id)sender {
    [self updateCorner];
}

- (void)updateCorner {
    CGFloat radius = _textField.text.floatValue;
    CALayerCornerMask mask = CALayerCornerMaskNone;
    if (_topLeft.isOn) {
        mask |= CALayerCornerMaskTopLeft;
    }
    if (_topRight.isOn) {
        mask |= CALayerCornerMaskTopRight;
    }
    if (_bottomLeft.isOn) {
        mask |= CALayerCornerMaskBottomLeft;
    }
    if (_bottomRight.isOn) {
        mask |= CALayerCornerMaskBottomRight;
    }
    [_imageView.layer setCornerRadius:radius mask:mask];
}

@end
