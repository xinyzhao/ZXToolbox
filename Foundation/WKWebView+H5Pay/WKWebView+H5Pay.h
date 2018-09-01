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
 @param refererForWeixin 微信H5支付域名（比如https://pay.cn），建议定为不带scheme的格式，如 pay.cn，
 然后在APP内新建一个名为 pay.cn 的 scheme，在微信内支付成功或取消时可以直接返回到APP，否则只能手动切换回APP
 @return 返回YES说明进入支付流程，NO则说明非支付请求，需要用户自行处理，比如 decisionHandler(WKNavigationActionPolicyAllow)
 */
- (BOOL)decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler refererForWeixin:(NSString *)refererForWeixin;

@end
