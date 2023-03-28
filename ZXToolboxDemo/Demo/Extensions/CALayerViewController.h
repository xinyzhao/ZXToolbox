//
//  CALayerViewController.h
//  ZXToolboxDemo
//
//  Created by xyz on 2023/3/10.
//  Copyright © 2023 xinyzhao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayerViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UISwitch *topLeft;
@property (nonatomic, weak) IBOutlet UISwitch *topRight;
@property (nonatomic, weak) IBOutlet UISwitch *bottomLeft;
@property (nonatomic, weak) IBOutlet UISwitch *bottomRight;

@end

NS_ASSUME_NONNULL_END
