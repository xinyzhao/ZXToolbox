//
// ZXRefreshDefinitions.h
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

#ifndef ZXRefreshDefinitions_h
#define ZXRefreshDefinitions_h

#import <UIKit/UIKit.h>

typedef void(^ZXRefreshingBlock)(void);

typedef NS_ENUM(NSInteger, ZXRefreshState)
{
    ZXRefreshStateIdle,
    ZXRefreshStatePulling,
    ZXRefreshStateWillRefreshing,
    ZXRefreshStateRefreshing,
};

@protocol ZXRefreshProtocol <NSObject>

- (BOOL)attachToView:(UIView *)view;
- (BOOL)detach;

- (void)setPullingProgress:(CGFloat)progress;

- (BOOL)beginRefreshing;
- (BOOL)endRefreshing;

- (void)updateContentSize;

@end

#endif /* ZXRefreshDefinitions_h */
