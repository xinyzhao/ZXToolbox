//
// WKWebView+H5Pay.h
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

#import <WebKit/WebKit.h>

WK_EXTERN API_AVAILABLE(macosx(10.10), ios(8.0))
@interface WKWebView (H5Pay)

/**
 在 WKNavigationDelegate 的实现
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
 内调用本方法，当前支持的H5支付平台：微信、支付宝

 @param navigationAction navigationAction
 @param decisionHandler decisionHandler
 @param refererForWeixin 微信H5支付域名
        支持多个APP使用同一个支付域名并且可以正确返回到APP，条件为：
        * 不带 scheme 的顶级域名，如 pay.cn，
        * APP 需要注册格式为 app.pay.cn 的 URLScheme 并传入 refererForWeixin，其中app可为任意名称
 @param URLScheme APP 注册的 URLScheme，用于支付宝返回APP
 @return 返回YES说明进入支付流程，NO则说明非支付请求，需要用户自行处理，比如 decisionHandler(WKNavigationActionPolicyAllow)
 */
- (BOOL)decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler refererForWeixin:(NSString *)refererForWeixin URLScheme:(NSString *)URLScheme;

@end
