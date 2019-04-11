//
// ZXLineChartView.h
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

#import <UIKit/UIKit.h>

#define kZXLineChartLineColor       [UIColor darkGrayColor]
#define kZXLineChartLineWidth       (1.0)
#define kZXLineChartGridColor       [UIColor lightGrayColor]
#define kZXLineChartGridWidth       (0.5)
#define kZXLineChartTextFont        [UIFont systemFontOfSize:11]
#define kZXLineChartTextColor       [UIColor darkTextColor]
#define kZXLineChartFillColor       [UIColor lightGrayColor]
#define kZXLineChartGradientColor   [UIColor whiteColor]
#define kZXLineChartNodeColor       [UIColor whiteColor]
#define kZXLineChartNodeRadius      4

extern void floorAndCeiling(double const *in_values, size_t in_count, double *out_min, double *out_max);

@class ZXLineChartAxis;
@class ZXLineChartData;
@class ZXLineChartLine;
@class ZXLineChartNode;
@class ZXLineChartView;

@interface ZXLineChartAxis : NSObject
@property (nonatomic, readonly) ZXLineChartLine *axisLine;
@property (nonatomic, readonly) ZXLineChartLine *gridLine;

@property (nonatomic, strong) NSArray *texts;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;

@property (nonatomic, strong) NSString *zeroText; // default is nil

@end

@interface ZXLineChartData : NSObject
@property (nonatomic, assign) CGPoint point; // percent for max value, range 0 - 1
@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

@end

@interface ZXLineChartLine : NSObject
@property (nonatomic, strong) UIColor *lineColor; // default is kZXLineChartLineColor
@property (nonatomic, assign) CGFloat lineWidth; // default is kZXLineChartLineWidth
@property (nonatomic, copy) NSArray<NSNumber *> *lineDash; // same as [CAShapeLayer lineDashPattern]
@property (nonatomic, assign) BOOL isEnabled; // default is YES

@end

@interface ZXLineChartNode : UIView
@property (nonatomic, strong) UIColor *color; // circle color, default is kZXLineChartNodeColor
@property (nonatomic, assign) CGFloat radius; // circle radius, default is kZXLineChartNodeRadius
@property (nonatomic, strong) UIColor *lineColor; // border color, default is kZXLineChartLineColor
@property (nonatomic, assign) CGFloat lineWidth; // border width, default is kZXLineChartLineWidth

@property (nonatomic, readonly) ZXLineChartLine *xLine;
@property (nonatomic, readonly) ZXLineChartLine *yLine;

@property(nonatomic) BOOL cancelsTouchesInView; // default is YES
@property (nonatomic, assign) BOOL isEnabled; // default is NO

@end

@interface ZXLineChartView : UIView
@property (nonatomic, strong) NSArray<ZXLineChartData *> *dataArray;

@property (nonatomic, readonly) ZXLineChartAxis *xAxis;
@property (nonatomic, readonly) ZXLineChartAxis *yAxis;

@property (nonatomic, readonly) ZXLineChartLine *chartLine;
@property (nonatomic, assign) NSInteger smoothGranularity; // default is 5

@property (nonatomic, strong) UIColor *fillColor; // default is kZXLineChartFillColor
@property (nonatomic, strong) UIColor *gradientColor; // default is kZXLineChartGradientColor

@property (nonatomic, readonly) ZXLineChartNode *nodeView;

@property (nonatomic, readonly) UIEdgeInsets contentInset;

@property (nonatomic, copy) void (^touchesMoved)(CGPoint point, ZXLineChartData *data);
@property (nonatomic, copy) void (^touchesEnded)(void);

@end
