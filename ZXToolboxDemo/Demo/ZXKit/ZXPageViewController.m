//
//  ZXPageViewController.m
//  ZXToolboxDemo
//
//  Created by xyz on 2020/6/28.
//  Copyright © 2020 xinyzhao. All rights reserved.
//

#import "ZXPageViewController.h"

@interface ZXPageViewController ()
@property (nonatomic, strong) ZXPageView *pageView;

@end

@implementation ZXPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect rect = CGRectMake(0, 120, UIScreen.mainScreen.bounds.size.width, 500);
    _pageView = [[ZXPageView alloc] initWithFrame:rect];
    _pageView.backgroundColor  = [UIColor randomColor];
    _pageView.subviewForPageAtIndex = ^UIView *(NSInteger index) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:50];
        label.textColor = [UIColor randomColor];
        label.backgroundColor = [label.textColor inverseColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"[%ld]", (long)index];
        return label;
    };
    _pageView.direction = ZXPageViewDirectionHorizontal;
    _pageView.pageInset = UIEdgeInsetsMake(10, 5, 10, 5);
    _pageView.pageScaleFactor = CGPointMake(0.8, 1);
    [self.view addSubview:_pageView];
    _pageView.numberOfPages = 2;
    [_pageView reloadData];
    _pageView.currentPage = 1;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
