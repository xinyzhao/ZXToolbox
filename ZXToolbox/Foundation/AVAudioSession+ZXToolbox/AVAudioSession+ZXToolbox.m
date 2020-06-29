//
// AVAudioSession+ZXToolbox.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2020 Zhao Xin
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

#import "AVAudioSession+ZXToolbox.h"
#import <objc/runtime.h>

@interface AVAudioSession ()
@property (nonatomic, weak) id audioSessionRouteChangeObserver;

@end

@implementation AVAudioSession (ZXToolbox)

- (NSString *)currentInput {
    NSArray *inputs = self.currentRoute.inputs;
    AVAudioSessionPortDescription *desc = [inputs firstObject];
    return desc.portType;
}

- (void)setCurrentInput:(NSString *)currentInput {
    NSArray *inputs = [self availableInputs];
    for (AVAudioSessionPortDescription *input in inputs) {
        if ([input.portType isEqualToString:currentInput]) {
            NSError *error = nil;
            [self setPreferredInput:input error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
            break;
        }
    }
}

- (NSString *)currentOutput {
    NSArray *outputs = self.currentRoute.outputs;
    AVAudioSessionPortDescription *desc = [outputs firstObject];
    return desc.portType;
}

- (void)setOverrideSpeaker:(BOOL)overrideSpeaker {
    objc_setAssociatedObject(self, @selector(isOverrideSpeaker), @(overrideSpeaker), OBJC_ASSOCIATION_RETAIN);
    //
    if ([self.category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
        NSError *error = nil;
        if (overrideSpeaker && [self.currentOutput isEqualToString:AVAudioSessionPortBuiltInReceiver]) {
            [self overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        } else if (!overrideSpeaker && [self.currentOutput isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
            [self overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        }
        if (error) {
            NSLog(@"%@", error);
        }
    }
}

- (BOOL)isOverrideSpeaker {
    NSNumber *number = objc_getAssociatedObject(self, @selector(isOverrideSpeaker));
    return number ? [number boolValue] : false;
}

- (void)setAudioSessionRouteChange:(void (^)(AVAudioSessionRouteDescription * _Nonnull, AVAudioSessionRouteChangeReason))audioSessionRouteChange {
    objc_setAssociatedObject(self, @selector(audioSessionRouteChange), audioSessionRouteChange, OBJC_ASSOCIATION_COPY);
    //
    if (self.audioSessionRouteChangeObserver == nil) {
        __weak typeof(self) weakSelf = self;
        self.audioSessionRouteChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVAudioSessionRouteChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
#if DEBUG
            AVAudioSession *session = note.object;
            AVAudioSessionRouteDescription *route = [session currentRoute];
            for (AVAudioSessionPortDescription *port in [route inputs]) {
                NSLog(@"\nCategory: %@(%llu)/%@(%@)",
                      session.category, (uint64_t)session.categoryOptions,
                      [port portType], [port portName]);
            }
            for (AVAudioSessionPortDescription *port in [route outputs]) {
                NSLog(@"\nCategory: %@(%llu)/%@(%@)",
                      session.category, (uint64_t)session.categoryOptions,
                      [port portType], [port portName]);
            }
#endif
            if (weakSelf.audioSessionRouteChange) {
                AVAudioSessionRouteChangeReason reason = [note.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
                AVAudioSessionRouteDescription *previousRoute = note.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
                weakSelf.audioSessionRouteChange(previousRoute, reason);
            }
            if (weakSelf.isOverrideSpeaker) {
                weakSelf.overrideSpeaker = YES;
            }
        }];
    }
}

- (void (^)(AVAudioSessionRouteDescription *, AVAudioSessionRouteChangeReason))audioSessionRouteChange {
    return objc_getAssociatedObject(self, @selector(audioSessionRouteChange));
}

- (void)setAudioSessionRouteChangeObserver:(id)audioSessionRouteChangeObserver {
    objc_setAssociatedObject(self, @selector(audioSessionRouteChangeObserver), audioSessionRouteChangeObserver, OBJC_ASSOCIATION_ASSIGN);
}

- (id)audioSessionRouteChangeObserver {
    return objc_getAssociatedObject(self, @selector(audioSessionRouteChangeObserver));
}

- (void)dealloc
{
    if (self.audioSessionRouteChangeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.audioSessionRouteChangeObserver];
        self.audioSessionRouteChangeObserver = nil;
    }
}

@end
