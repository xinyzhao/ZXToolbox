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

    ZXCoordinate2D baidu = ZXCoordinate2DMake(40.02009, 116.467418);
    ZXCoordinate2D china = ZXCoordinate2DMake(40.02009, 116.467418);
    ZXCoordinate2D world = ZXCoordinate2DChinaToWorld(china);
    NSLogA(@"#WGS-84: %f, %f", world.latitude, world.longitude);
    NSLogA(@"#GCJ-02: %f, %f", china.latitude, china.longitude);
    NSLogA(@"#BD-09: %f, %f", baidu.latitude, baidu.longitude);
}


@end
