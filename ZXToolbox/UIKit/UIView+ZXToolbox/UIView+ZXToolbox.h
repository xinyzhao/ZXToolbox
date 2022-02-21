//
// UIView+ZXToolbox.h
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

@interface UIView (ZXToolbox)

/// @brief 替代子类化并重写intrinsicContentSize方法，在intrinsicContentSize的基础上调整宽高。
/// @discussion Replace subclassing and override intrinsicContentSize method, adjust size based on intrinsicContentSize.
/// @attention 由于 intrinsicContentSize 依赖于 AutoLayout，设置此属性会导致 Autoresizing 相关属性(frame/center)设置失效。
@property (nonatomic, assign) CGSize extrinsicContentSize;

/// Capture the view snapshot image
- (nullable UIImage *)captureImage;

/// Snapshot for view, same as captureImage
- (nullable UIImage *)snapshotImage;

/// Get instance of subview for tag, not including self
/// @param tag The tag of subview
/// @return The instance of subview if finded, otherwise is nil.
- (nullable id)subviewForTag:(NSInteger)tag;

/// Get instance of subview for tag, not including self
/// @param tag The tag of subview
/// @param aClass The class of subview
/// @return The instance of subview if finded, otherwise is nil.
- (nullable id)subviewForTag:(NSInteger)tag isKindOfClass:(Class)aClass;

/// Get instance of subview for tag, not including self
/// @param tag The tag of subview
/// @param aClass The member class of subview
/// @return The instance of subview if finded, otherwise is nil.
- (nullable id)subviewForTag:(NSInteger)tag isMemberOfClass:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
