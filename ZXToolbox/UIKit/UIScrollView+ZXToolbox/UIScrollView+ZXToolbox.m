//
// UIScrollView+ZXToolbox.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019 Zhao Xin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "UIScrollView+ZXToolbox.h"

@implementation UIScrollView (ZXToolbox)

- (void)scrollToTop:(BOOL)animated {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(),^{
        [weakSelf setContentOffset:CGPointZero animated:animated];
    });
}

- (void)scrollToBottom:(BOOL)animated {
    [self layoutIfNeeded];
    //
    if ([self isKindOfClass:UITableView.class]) {
        UITableView *tableView = (UITableView *)self;
        __weak typeof(tableView) weakSelf = tableView;
        dispatch_async(dispatch_get_main_queue(),^{
            NSInteger section = [weakSelf numberOfSections] - 1;
            NSInteger row = [weakSelf numberOfRowsInSection:section] - 1;
            if (section >= 0 && section != NSNotFound && row >= 0 && row != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                [weakSelf scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
            }
        });
    } else if ([self isKindOfClass:UICollectionView.class]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        __weak typeof(collectionView) weakSelf = collectionView;
        dispatch_async(dispatch_get_main_queue(),^{
            NSInteger section = [weakSelf numberOfSections] - 1;
            NSInteger row = [weakSelf numberOfItemsInSection:section] - 1;
            if (section >= 0 && section != NSNotFound && row >= 0 && row != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                [weakSelf scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
            }
        });
    } else {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(),^{
            CGFloat y = weakSelf.contentSize.height - weakSelf.bounds.size.height;
            if (y > 0.f) {
                [weakSelf setContentOffset:CGPointMake(0, y) animated:animated];
            }
        });
    }
}

@end
