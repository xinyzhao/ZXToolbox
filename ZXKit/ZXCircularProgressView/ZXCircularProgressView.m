//
// ZXCircularProgressView.m
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

#import "ZXCircularProgressView.h"

@interface ZXCircularProgressView ()
@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation ZXCircularProgressView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self viewDidLoad];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self viewDidLoad];
    }
    return self;
}

- (void)viewDidLoad {
    self.backgroundColor = [UIColor clearColor];
    //
    _trackLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_trackLayer];
    //
    _progressLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_progressLayer];
    //
    _progressViewStyle = ZXCircularProgressViewStylePie;
    _progressTintColor = self.tintColor;
    _progress = 0.f;
    //
    _clockwise = YES;
    _lineWidth = 0.f;
    _integrity = 1.f;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //
    rect.origin.x = self.layer.borderWidth;
    rect.origin.y = self.layer.borderWidth;
    rect.size.width -= self.layer.borderWidth * 2;
    rect.size.height -= self.layer.borderWidth * 2;
    _trackLayer.frame = _progressLayer.frame = rect;
    //
    CGFloat progress = _progress > 1.f ? 1.f : _progress;
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius = MIN(rect.size.width, rect.size.height) / 2 - _lineWidth / 2;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = startAngle + M_PI * 2 * progress * _integrity;
    CGFloat trackAngle = startAngle + M_PI * 2 * (_clockwise ? _integrity : -_integrity);
    //
    if (_progress > 1.f && _progressViewStyle == ZXCircularProgressViewStyleRing) {
        progress = _progress - 1.f;
        startAngle += M_PI * 2 * progress * _integrity;
        endAngle += M_PI * 2 * progress * _integrity;
    }
    //
    if (_progressViewStyle == ZXCircularProgressViewStylePie) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:center];
        [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:trackAngle clockwise:_clockwise];
        [path closePath];
        //
        _trackLayer.fillColor = _trackTintColor.CGColor;
        _trackLayer.strokeColor = _trackTintColor.CGColor;
        _trackLayer.lineCap = kCALineCapButt;
        _trackLayer.lineWidth = 0;
        _trackLayer.path = path.CGPath;
    } else {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:trackAngle clockwise:_clockwise];
        [path setLineWidth:_lineWidth];
        [path setLineCapStyle:kCGLineCapRound];
        //
        _trackLayer.fillColor = nil;
        _trackLayer.strokeColor = _trackTintColor.CGColor;
        _trackLayer.lineCap = kCALineCapRound;
        _trackLayer.lineWidth = _lineWidth;
        _trackLayer.path = path.CGPath;
    }
    //
    if (_progressViewStyle == ZXCircularProgressViewStylePie) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:center];
        [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:_clockwise];
        [path closePath];
        //
        _progressLayer.fillColor = _progressTintColor.CGColor;
        _progressLayer.strokeColor = _progressTintColor.CGColor;
        _progressLayer.lineCap = kCALineCapButt;
        _progressLayer.lineWidth = 0;
        _progressLayer.path = path.CGPath;
    } else {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:_clockwise];
        [path setLineWidth:_lineWidth];
        [path setLineCapStyle:kCGLineCapRound];
        //
        _progressLayer.fillColor = nil;
        _progressLayer.strokeColor = _progressTintColor.CGColor;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineWidth = _lineWidth;
        _progressLayer.path = path.CGPath;
    }
}

- (void)setIntegrity:(float)integrity {
    if (integrity < 0.f) {
        _integrity = 0.f;
    } else if (integrity > 1.f) {
        _integrity = 1.f;
    } else {
        _integrity = integrity;
    }
    [self setNeedsDisplay];
}

- (void)setLineWidth:(float)lineWidth {
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void)setProgress:(float)progress {
    if (progress < 0.f) {
        progress = 0.f;
    }
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = [progressTintColor copy];
    [self setNeedsDisplay];
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    _trackTintColor = [trackTintColor copy];
    [self setNeedsDisplay];
}

@end
