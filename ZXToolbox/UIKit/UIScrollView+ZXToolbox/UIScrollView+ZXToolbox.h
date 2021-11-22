//
// UIScrollView+ZXToolbox.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019-2020 Zhao Xin
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (ZXToolbox)
/// @brief 冻结滚动
/// @attention 注意：设置为 true 时会解冻 freezedViews 内的视图
@property (nonatomic, assign) BOOL isScrollFreezed;
/// @brief 当本视图冻结滚动时，解冻其它冻结的视图
@property (nonatomic, readonly, nonnull) NSHashTable<UIScrollView *> *freezedViews;
/// @brief 冻结滚动的底层视图（父视图），需要同时识别多个手势，默认为 NO。
/// @discussion The super view needs recognize multiple gestures simultaneously.
@property (nonatomic, assign) BOOL shouldRecognizeSimultaneously;

/// @brief 滚动到顶部
/// @param animated 是否以动画的形式
- (void)scrollToTop:(BOOL)animated;

/// @brief 滚动到底部
/// @param animated 是否以动画的形式
- (void)scrollToBottom:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
