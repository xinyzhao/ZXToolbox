//
//  ViewController.m
//  ZXToolboxDemo
//
//  Created by xyz on 2020/1/9.
//  Copyright © 2020 xinyzhao. All rights reserved.
//

#import "ViewController.h"
#import <ZXToolbox/ZXToolbox.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    // TEST
    NSLog(@">>>UDID: %@", [UIDevice currentDevice].UDIDString);
}


@end
