//
// ZXScriptMessageHandler.m
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

#import "ZXScriptMessageHandler.h"

@implementation ZXScriptMessageHandler

- (instancetype)initWithUserContentController:(WKUserContentController *)userContentController {
    self = [super init];
    if (self) {
        self.userContentController = userContentController;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)addScriptMessageNames:(NSArray *)scriptMessageNames {
    if (self.scriptMessageNames == nil) {
        self.scriptMessageNames = [scriptMessageNames copy];
    } else {
        self.scriptMessageNames = [self.scriptMessageNames arrayByAddingObjectsFromArray:scriptMessageNames];
    }
    __weak typeof(self) weakSelf = self;
    for (NSString *name in scriptMessageNames) {
        [self.userContentController addScriptMessageHandler:weakSelf name:name];
    }
}

- (void)removeScriptMessageHandlers {
    for (NSString *name in self.scriptMessageNames) {
        [self.userContentController removeScriptMessageHandlerForName:name];
    }
}

#pragma mark <WKScriptMessageHandler>

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.didReceiveScriptMessage) {
        self.didReceiveScriptMessage(message);
    }
}

@end
