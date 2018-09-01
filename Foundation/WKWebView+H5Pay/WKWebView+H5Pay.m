//
// WKWebView+H5Pay.m
//
// Copyright (c) 2018 Zhao Xin (https://github.com/xinyzhao/ZXToolbox)
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

#import "WKWebView+H5Pay.h"
#import "NSString+URLEncoding.h"
#import "JSONObject.h"

@implementation WKWebView (H5Pay)

- (BOOL)decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler refererForWeixin:(NSString *)refererForWeixin URLScheme:(NSString *)URLScheme {
    NSURL *url = navigationAction.request.URL;
    if ([url.host isEqualToString:@"wx.tenpay.com"]) {
        NSString *refererKey = @"Referer";
        NSString *refererValue = [refererForWeixin containsString:@"://"] ? refererForWeixin : [refererForWeixin stringByAppendingString:@"://"];
        NSDictionary *headers = [navigationAction.request allHTTPHeaderFields];
        BOOL hasReferer = [[headers objectForKey:refererKey] isEqualToString:refererValue];
        if (hasReferer) {
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:navigationAction.request.timeoutInterval];
                    [request setValue:refererValue forHTTPHeaderField:refererKey];
                    [weakSelf loadRequest:request];
                });
            });
        }
    } else if ([url.scheme isEqualToString:@"weixin"] && [[UIApplication sharedApplication] canOpenURL:url]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        [[UIApplication sharedApplication] openURL:url];
    } else if ([url.scheme isEqualToString:@"alipay"] && [[UIApplication sharedApplication] canOpenURL:url]) {
        if (URLScheme && [url.absoluteString hasPrefix:@"alipay://alipayclient"]) {
            NSString *str = [url.absoluteString stringByURLDecoding:NSUTF8StringEncoding];
            NSMutableArray *components = [[str componentsSeparatedByString:@"?"] mutableCopy];
            NSMutableDictionary *dict = [[JSONObject JSONObjectWithString:components.lastObject] mutableCopy];
            [dict setObject:URLScheme forKey:@"fromAppUrlScheme"];
            str = [JSONObject stringWithJSONObject:dict];
            str = [str stringByURLEncoding:NSUTF8StringEncoding];
            [components replaceObjectAtIndex:(components.count - 1) withObject:str];
            str = [components componentsJoinedByString:@"?"];
            url = [NSURL URLWithString:str];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        [[UIApplication sharedApplication] openURL:url];
    } else {
        return NO;
    }
    return YES;
}

@end
