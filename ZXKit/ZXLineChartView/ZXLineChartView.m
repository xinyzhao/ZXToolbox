//
// ZXLineChartView.m
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

#import "ZXLineChartView.h"

void floorAndCeiling(double const *in_values, size_t in_count, double *out_min, double *out_max) {
    double max = 0.0;
    double min = 0.0;
    double diff = 0.0;
    double prev = 0.0;
    for (size_t i = 0; i < in_count; ++i) {
        double v = in_values[i];
        min = i == 0 ? v : MIN(min, v);
        max = MAX(max, v);
        diff = i == 0 ? 0 : MAX(diff, ABS(v - prev));
        prev = v;
    }
    //
    uint64_t units = MIN(MIN(max - min, min), diff);
    for (uint64_t u = 1; u < units; u *= 10) {
        if (u * 10 > units) {
            min = floor(min / u) * u;
            max = ceil(max / u) * u;
            break;
        }
    }
    *out_min = min;
    *out_max = max;
}

@implementation ZXLineChartAxis
@synthesize axisLine = _axisLine;
@synthesize gridLine = _gridLine;

- (ZXLineChartLine *)axisLine {
    if (_axisLine == nil) {
        _axisLine = [[ZXLineChartLine alloc] init];
    }
    return _axisLine;
}

- (ZXLineChartLine *)gridLine {
    if (_gridLine == nil) {
        _gridLine = [[ZXLineChartLine alloc] init];
    }
    return _gridLine;
}

- (UIFont *)textFont {
    return _textFont ?: kZXLineChartTextFont;
}

- (UIColor *)textColor {
    return _textColor ?: kZXLineChartTextColor;
}

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = nil;
    if (text) {
        CGRect rect = CGRectZero;
        rect.size = [self sizeWithText:text];
        //
        label = [[UILabel alloc] initWithFrame:rect];
        label.font = self.textFont;
        label.textAlignment = self.textAlignment;
        label.textColor = self.textColor;
        label.text = text;
    }
    return label;
}

- (CGSize)sizeWithText:(NSString *)text {
    CGSize size = CGSizeZero;
    if (text) {
        size = [text sizeWithAttributes:@{NSFontAttributeName:self.textFont}];
        size.width = ceil(size.width);
        size.height = ceil(size.height);
    }
    return size;
}

@end

@implementation ZXLineChartData

- (CGPoint)locationInRect:(CGRect)rect {
    CGPoint location = CGPointZero;
    location.x = rect.origin.x + rect.size.width * self.point.x;
    location.y = rect.origin.y + rect.size.height * (1 - self.point.y);
    return location;
}

@end

@implementation ZXLineChartLine

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isEnabled = YES;
    }
    return self;
}

- (UIColor *)lineColor {
    return _lineColor ?: kZXLineChartLineColor;
}

- (CGFloat)lineWidth {
    return _lineWidth ?: kZXLineChartLineWidth;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetAllowsAntialiasing(context, true);
    //
    CGFloat r,g,b,a;
    [self.lineColor getRed:&r green:&g blue:&b alpha:&a];
    CGContextSetRGBStrokeColor(context, r, g, b, a);
    //
    CGContextBeginPath(context);
    if (rect.size.width < rect.size.height) {
        CGContextMoveToPoint(context, rect.origin.x + self.lineWidth / 2, rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x + self.lineWidth / 2, rect.origin.y + rect.size.height);
    } else {
        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + self.lineWidth / 2);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + self.lineWidth / 2);
    }
    //
    NSInteger count = self.lineDash.count;
    if (count > 0) {
        CGFloat *dash = malloc(sizeof(CGFloat) * count);
        for (NSInteger i = 0; i < count; ++i) {
            dash[i] = [self.lineDash[i] floatValue];
        }
        CGContextSetLineDash(context, 0, dash, count);
        free(dash);
    }
    CGContextStrokePath(context);
    CGContextSetLineDash(context, 0, 0, 0);
}

@end

@interface ZXLineChartNode ()
@property (nonatomic, assign) CGRect chartRect;
@property (nonatomic, strong) NSArray *points;
@property (nonatomic, assign) CGPoint point;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, copy) void(^touchesMoved)(CGPoint point, NSInteger index);
@property (nonatomic, copy) void(^touchesEnded)(void);

@end

@implementation ZXLineChartNode
@synthesize xLine = _xLine;
@synthesize yLine = _yLine;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        [self initView];
    }
    return self;
}

- (void)initView {
    self.isEnabled = NO;
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    self.panGestureRecognizer.enabled = NO;
    [self addGestureRecognizer:self.panGestureRecognizer];
}

- (UIColor *)color {
    return _color ?: kZXLineChartNodeColor;
}

- (CGFloat)radius {
    return _radius ?: kZXLineChartNodeRadius;
}

- (UIColor *)lineColor {
    return _lineColor ?: kZXLineChartLineColor;
}

- (CGFloat)lineWidth {
    return _lineWidth ?: kZXLineChartLineWidth;
}

- (ZXLineChartLine *)xLine {
    if (_xLine == nil) {
        _xLine = [[ZXLineChartLine alloc] init];
    }
    return _xLine;
}

- (ZXLineChartLine *)yLine {
    if (_yLine == nil) {
        _yLine = [[ZXLineChartLine alloc] init];
    }
    return _yLine;
}

- (void)setCancelsTouchesInView:(BOOL)cancelsTouchesInView {
    self.panGestureRecognizer.enabled = !cancelsTouchesInView;
}

- (BOOL)cancelsTouchesInView {
    return !self.panGestureRecognizer.enabled;
}

- (void)setIsEnabled:(BOOL)isEnabled {
    _isEnabled = isEnabled;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //
    if (self.isEnabled) {
        if (self.xLine) {
            CGRect line = self.chartRect;
            line.origin.x = self.point.x - self.xLine.lineWidth / 2;
            line.size.width = self.xLine.lineWidth;
            line.size.height += line.origin.y;
            line.origin.y = 0;
            [self.xLine drawRect:line];
        }
        if (self.yLine) {
            CGRect line = self.chartRect;
            line.origin.y = self.point.y - self.yLine.lineWidth / 2;
            line.size.width += rect.size.width - line.size.width - line.origin.x;
            line.size.height = self.yLine.lineWidth;
            [self.yLine drawRect:line];
        }
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextAddArc(context, self.point.x, self.point.y, self.radius, 0, M_PI * 2, 0);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
}

- (void)moveToPoint:(id)point {
    self.point = [point CGPointValue];
    [self setNeedsDisplay];
    //
    if (_touchesMoved) {
        NSInteger index = [self.points indexOfObject:point];
        _touchesMoved([point CGPointValue], index);
    }
}

- (void)moveToNearestPoint:(CGPoint)point {
    if (self.points.count > 0) {
        id object = nil;
        CGFloat distance = FLT_MAX;
        for (id obj in self.points) {
            CGPoint p = [obj CGPointValue];
            CGFloat d = ABS(p.x - point.x);
            if (d < distance) {
                object = obj;
                distance = d;
            }
        }
        if (object) {
            [self moveToPoint:object];
        }
    }
}

#pragma mark Touch Event

- (void)onPan:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [pan locationInView:pan.view];
            if (CGRectContainsPoint(self.chartRect, point)) {
                if (self.points.count > 0) {
                    [self moveToNearestPoint:point];
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (_touchesEnded) {
                _touchesEnded();
            }
            break;
        }
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (self.cancelsTouchesInView && CGRectContainsPoint(self.chartRect, point)) {
        [self moveToNearestPoint:point];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (self.cancelsTouchesInView && CGRectContainsPoint(self.chartRect, point)) {
        [self moveToNearestPoint:point];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (self.cancelsTouchesInView && _touchesEnded) {
        _touchesEnded();
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (self.cancelsTouchesInView && _touchesEnded) {
        _touchesEnded();
    }
}

@end

@interface ZXLineChartView ()

@end

@implementation ZXLineChartView
@synthesize chartLine = _chartLine;
@synthesize xAxis = _xAxis;
@synthesize yAxis = _yAxis;
@synthesize nodeView = _nodeView;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.smoothGranularity = 5;
    self.fillColor = kZXLineChartFillColor;
    self.gradientColor = kZXLineChartGradientColor;
}

- (ZXLineChartLine *)chartLine {
    if (_chartLine == nil) {
        _chartLine = [[ZXLineChartLine alloc] init];
    }
    return _chartLine;
}

- (ZXLineChartAxis *)xAxis {
    if (_xAxis == nil) {
        _xAxis = [[ZXLineChartAxis alloc] init];
        _xAxis.gridLine.isEnabled = NO;
        _xAxis.gridLine.lineColor = kZXLineChartGridColor;
        _xAxis.gridLine.lineWidth = kZXLineChartGridWidth;
        _xAxis.textAlignment = NSTextAlignmentCenter;
    }
    return _xAxis;
}

- (ZXLineChartAxis *)yAxis {
    if (_yAxis == nil) {
        _yAxis = [[ZXLineChartAxis alloc] init];
        _yAxis.gridLine.isEnabled = YES;
        _yAxis.gridLine.lineColor = kZXLineChartGridColor;
        _yAxis.gridLine.lineWidth = kZXLineChartGridWidth;
        _yAxis.textAlignment = NSTextAlignmentRight;
    }
    return _yAxis;
}

- (ZXLineChartNode *)nodeView {
    if (_nodeView == nil) {
        _nodeView = [[ZXLineChartNode alloc] initWithFrame:self.bounds];
        //
        __weak typeof(self) weakSelf = self;
        _nodeView.touchesMoved = ^(CGPoint point, NSInteger index) {
            if (weakSelf.touchesMoved && index >= 0 && index < weakSelf.dataArray.count) {
                ZXLineChartData *data = weakSelf.dataArray[index];
                weakSelf.touchesMoved(point, data);
            }
        };
        _nodeView.touchesEnded = ^{
            if (weakSelf.touchesEnded) {
                weakSelf.touchesEnded();
            }
        };
    }
    return _nodeView;
}

#pragma mark Drawing

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    //
    CGRect xAxis = CGRectZero;
    CGRect yAxis = CGRectZero;
    CGRect xGrid = CGRectZero;
    CGRect yGrid = CGRectZero;
    CGRect xText = CGRectZero;
    CGRect yText = CGRectZero;
    CGRect chart = CGRectZero;
    UIEdgeInsets inset = [self contentInset];
    //
    chart.origin.x = inset.left;
    chart.origin.y = inset.top;
    chart.size.width = rect.size.width - inset.left - inset.right;
    chart.size.height = rect.size.height - inset.top - inset.bottom;
    //
    if (self.xAxis.axisLine.isEnabled) {
        xAxis.origin.x = inset.left;
        xAxis.origin.y = rect.size.height - inset.bottom - self.xAxis.axisLine.lineWidth;
        xAxis.size.width = rect.size.width - inset.left;
        xAxis.size.height = self.xAxis.axisLine.lineWidth;
        //
        if (self.xAxis.texts.count > 0) {
            xText = xAxis;
            xText.origin.y += xAxis.size.height + inset.top;
            xText.size.width -= inset.right;
            xText.size.height = rect.size.height - xText.origin.y;
            //
            xGrid.origin.x = inset.left;
            xGrid.size.width = rect.size.width - inset.left - inset.right;
            xGrid.size.height = rect.size.height - inset.bottom;
        }
        //
        chart.size.height -= xAxis.size.height;
    }
    if (self.yAxis.axisLine.isEnabled) {
        yAxis.origin.x = inset.left;
        yAxis.size.width = self.yAxis.axisLine.lineWidth;
        yAxis.size.height = rect.size.height - inset.bottom;
        //
        if (self.yAxis.texts.count > 0) {
            yText = yAxis;
            yText.origin.x = 0;
            yText.origin.y += inset.top;
            yText.size.width = yAxis.origin.x - inset.top;
            yText.size.height -= yText.origin.y;
            //
            yGrid.origin.x = inset.left;
            yGrid.origin.y = inset.top;
            yGrid.size.width = rect.size.width - inset.left;
            yGrid.size.height = rect.size.height - inset.bottom - inset.top;
        }
        //
        chart.origin.x += yAxis.size.width;
        chart.size.width -= yAxis.size.width;
    }
    //
    [self drawGridX:xGrid];
    [self drawGridY:yGrid];
    [self drawAxisX:xAxis label:xText];
    [self drawAxisY:yAxis label:yText];
    [self drawChart:chart];
}

- (void)drawAxisX:(CGRect)lineRect label:(CGRect)labelRect {
    if (self.xAxis.axisLine.isEnabled) {
        [self.xAxis.axisLine drawRect:lineRect];
        //
        NSInteger count = self.xAxis.texts.count;
        if (count > 0) {
            CGPoint center = CGPointZero;
            CGFloat width = labelRect.size.width / count;
            for (NSInteger i = 0; i < count; ++i) {
                NSString *text = self.xAxis.texts[i];
                UILabel *label = [self.xAxis labelWithText:text];
                center.x = labelRect.origin.x + width * (i + 1);
                center.y = labelRect.origin.y + label.bounds.size.height / 2;
                label.center = center;
                [self addSubview:label];
            }
            if (self.xAxis.zeroText) {
                NSString *text = self.xAxis.zeroText;
                UILabel *label = [self.xAxis labelWithText:text];
                center.x = labelRect.origin.x;
                center.y = labelRect.origin.y + label.bounds.size.height / 2;
                label.center = center;
                [self addSubview:label];
            }
        }
    }
}

- (void)drawAxisY:(CGRect)lineRect label:(CGRect)labelRect {
    if (self.yAxis.axisLine.isEnabled) {
        [self.yAxis.axisLine drawRect:lineRect];
        //
        NSInteger count = self.yAxis.texts.count;
        if (count > 0) {
            CGRect rect = labelRect;
            CGFloat height = labelRect.size.height / count;
            for (NSInteger i = 0; i < count; ++i) {
                NSString *text = self.yAxis.texts[count - i - 1];
                UILabel *label = [self.yAxis labelWithText:text];
                rect.origin.y = labelRect.origin.y + height * i - label.bounds.size.height / 2;
                rect.size.height = label.bounds.size.height;
                label.frame = rect;
                [self addSubview:label];
            }
            if (self.yAxis.zeroText) {
                NSString *text = self.yAxis.zeroText;
                UILabel *label = [self.yAxis labelWithText:text];
                rect.origin.y = labelRect.origin.y + height * count - label.bounds.size.height / 2;
                rect.size.height = label.bounds.size.height;
                label.frame = rect;
                [self addSubview:label];
            }
        }
    }
}

- (void)drawGridX:(CGRect)rect {
    if (self.xAxis.gridLine.isEnabled && self.xAxis.texts.count > 0) {
        CGFloat width = rect.size.width / self.xAxis.texts.count;
        CGRect grid = rect;
        grid.size.width = self.xAxis.gridLine.lineWidth;
        for (NSInteger i = 0; i < self.xAxis.texts.count; ++i) {
            grid.origin.x = rect.origin.x + width * (i + 1);
            [self.xAxis.gridLine drawRect:grid];
        }
    }
}

- (void)drawGridY:(CGRect)rect {
    if (self.yAxis.gridLine.isEnabled && self.yAxis.texts.count > 0) {
        CGFloat height = rect.size.height / self.yAxis.texts.count;
        CGRect grid = rect;
        grid.size.height = self.yAxis.gridLine.lineWidth;
        for (NSInteger i = 0; i < self.yAxis.texts.count; ++i) {
            grid.origin.y = rect.origin.y + height * i;
            [self.yAxis.gridLine drawRect:grid];
        }
    }
}

- (void)drawChart:(CGRect)rect {
    NSMutableArray *points = [[NSMutableArray alloc] init];
    //
    if (self.dataArray.count > 0) {
        for (NSInteger i = 0; i < self.dataArray.count; ++i) {
            CGPoint point = [self.dataArray[i] locationInRect:rect];
            [points addObject:[NSValue valueWithCGPoint:point]];
        }
        //
        UIBezierPath *path = nil;
        if (self.smoothGranularity > 0) {
            path = [self smoothedPathWithPoints:points granularity:self.smoothGranularity];
            path.lineWidth = self.chartLine.lineWidth;

        } else {
            path = [[UIBezierPath alloc] init];
            path.lineCapStyle = kCGLineCapButt;
            path.lineJoinStyle = kCGLineJoinMiter;
            path.lineWidth = self.chartLine.lineWidth;
            //
            CGPoint point = [points[0] CGPointValue];
            [path moveToPoint:point];
            for (NSInteger i = 0; i < points.count; ++i) {
                CGPoint point = [points[i] CGPointValue];
                [path addLineToPoint:point];
            }
        }
        //
        if (self.fillColor) {
            UIBezierPath *maskPath = [path copy];
            CGPoint last = [[self.dataArray lastObject] locationInRect:rect];
            last.y = rect.origin.y + rect.size.height;
            [maskPath addLineToPoint:last];
            CGPoint first = [[self.dataArray firstObject] locationInRect:rect];
            first.y = rect.origin.y + rect.size.height;
            [maskPath addLineToPoint:first];
            //
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.path = maskPath.CGPath;
            maskLayer.fillColor = self.fillColor.CGColor;
            maskLayer.strokeColor = nil;
            maskLayer.lineWidth = self.chartLine.lineWidth;
            //
            if (self.gradientColor) {
                CAGradientLayer *gradientLayer = [CAGradientLayer layer];
                gradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
                gradientLayer.colors = @[(__bridge id)self.fillColor.CGColor,
                                         (__bridge id)self.gradientColor.CGColor];
                gradientLayer.locations = @[@0.0, @1.0];
                gradientLayer.startPoint = CGPointMake(0.0, 0.0);
                gradientLayer.endPoint = CGPointMake(0.0, 1.0);
                gradientLayer.mask = maskLayer;
                //
                [self.layer addSublayer:gradientLayer];
            } else {
                [self.layer addSublayer:maskLayer];
            }
        }
        //
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.fillColor = nil;
        shapeLayer.strokeColor = self.chartLine.lineColor.CGColor;
        shapeLayer.lineWidth = self.chartLine.lineWidth;
        shapeLayer.lineDashPattern = self.chartLine.lineDash;
        [self.layer addSublayer:shapeLayer];
    }
    //
    self.nodeView.chartRect = rect;
    self.nodeView.points = [points copy];
    [self addSubview:self.nodeView];
}

- (UIEdgeInsets)contentInset {
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (self.xAxis.axisLine.isEnabled && self.xAxis.texts.count > 0) {
        CGSize size = [self.xAxis sizeWithText:self.xAxis.zeroText];
        inset.left = MAX(inset.left, size.width / 2);
        //
        NSString *text = [self.xAxis.texts lastObject];
        CGSize textSize = [self.xAxis sizeWithText:text];
        size.width = MAX(size.width, textSize.width);
        size.height = MAX(size.height, textSize.height);
        inset.right = MAX(inset.right, size.width / 2);
        //
        inset.top = MAX(inset.top, size.height / 2);
        inset.bottom = MAX(inset.bottom, size.height + size.height / 2);
    }
    if (self.yAxis.axisLine.isEnabled && self.yAxis.texts.count > 0) {
        CGSize size = [self.yAxis sizeWithText:self.yAxis.zeroText];
        inset.bottom = MAX(inset.bottom, size.height / 2);
        //
        for (NSString *text in self.yAxis.texts) {
            CGSize textSize = [self.yAxis sizeWithText:text];
            size.width = MAX(size.width, textSize.width);
            size.height = MAX(size.height, textSize.height);
        }
        inset.top = MAX(inset.top, size.height / 2);
        inset.left = MAX(inset.left, size.width + size.height / 2);
    }
    return inset;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    self.nodeView.frame = self.bounds;
}

/**
 * https://stackoverflow.com/questions/8702696/drawing-smooth-curves-methods-needed
 * https://en.wikipedia.org/wiki/Centripetal_Catmull-Rom_spline
 */
- (UIBezierPath *)smoothedPathWithPoints:(NSArray *)pointsArray granularity:(NSInteger)granularity {
    UIBezierPath * smoothedPath = [[UIBezierPath alloc] init];
    smoothedPath.lineCapStyle = kCGLineCapRound;
    smoothedPath.lineJoinStyle = kCGLineJoinRound;

    // Add control points to make the math make sense
    NSMutableArray *points = [pointsArray mutableCopy];
    [points insertObject:[points firstObject] atIndex:0];
    [points addObject:[points lastObject]];
    [smoothedPath moveToPoint:[[points firstObject] CGPointValue]];
    
    for (NSInteger i = 1; i < points.count - 2; i++) {
        CGPoint p0 = [points[i-1] CGPointValue];
        CGPoint p1 = [points[i] CGPointValue];
        CGPoint p2 = [points[i+1] CGPointValue];
        CGPoint p3 = [points[i+2] CGPointValue];
        
        // now add n points starting at p1 + dx/dy up until p2 using Catmull-Rom splines
        for (int i = 1; i < granularity; i++) {
            float t = (float) i * (1.0f / (float) granularity);
            float tt = t * t;
            float ttt = tt * t;
            
            CGPoint pi; // intermediate point
            pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
            pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
            [smoothedPath addLineToPoint:pi];
        }
        
        // Now add p2
        [smoothedPath addLineToPoint:p2];
    }
    
    // finish by adding the last point
    [smoothedPath addLineToPoint:[points[points.count - 1] CGPointValue]];
    
    return smoothedPath;
}

@end
