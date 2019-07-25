//
// ZXAudioDevice.m
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

#import "ZXAudioDevice.h"

@implementation ZXAudioDevice

+ (instancetype)sharedDevice {
    static ZXAudioDevice *sharedDevice;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDevice = [[ZXAudioDevice alloc] init];
    });
    return sharedDevice;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioSessionRouteChange:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(proximityStateDidChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Audio session

- (NSString *)category {
    return [AVAudioSession sharedInstance].category;
}

- (void)setCategory:(NSString *)category {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:category error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    if (self.overrideSpeaker) {
        self.overrideSpeaker = _overrideSpeaker;
    }
}

- (NSString *)currentInput {
    NSArray *inputs = [AVAudioSession sharedInstance].currentRoute.inputs;
    AVAudioSessionPortDescription *desc = [inputs firstObject];
    return desc.portType;
}

- (void)setCurrentInput:(NSString *)currentInput {
    NSArray *inputs = [[AVAudioSession sharedInstance] availableInputs];
    for (AVAudioSessionPortDescription *input in inputs) {
        if ([input.portType isEqualToString:currentInput]) {
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setPreferredInput:input error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
            break;
        }
    }
}

- (NSString *)currentOutput {
    NSArray *outputs = [AVAudioSession sharedInstance].currentRoute.outputs;
    AVAudioSessionPortDescription *desc = [outputs firstObject];
    return desc.portType;
}

- (void)setOverrideSpeaker:(BOOL)overrideSpeaker {
    _overrideSpeaker = overrideSpeaker;
    if ([self.category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
        NSError *error = nil;
        if (_overrideSpeaker && [self.currentOutput isEqualToString:AVAudioSessionPortBuiltInReceiver]) {
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        } else if (!_overrideSpeaker && [self.currentOutput isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        }
        if (error) {
            NSLog(@"%@", error);
        }
    }
}

- (void)audioSessionRouteChange:(NSNotification *)notification {
#if DEBUG
    AVAudioSession *session = notification.object;
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
    if (_audioSessionRouteChange) {
        AVAudioSessionRouteChangeReason reason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
        AVAudioSessionRouteDescription *previousRoute = notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
        _audioSessionRouteChange(previousRoute, reason);
    }
    if (self.overrideSpeaker) {
        self.overrideSpeaker = _overrideSpeaker;
    }
}

#pragma mark Proximity Monitoring

- (void)setProximityMonitoringEnabled:(BOOL)proximityMonitoringEnabled {
    [UIDevice currentDevice].proximityMonitoringEnabled = proximityMonitoringEnabled;
}

- (BOOL)isProximityMonitoringEnabled {
    return [UIDevice currentDevice].isProximityMonitoringEnabled;
}

- (BOOL)proximityState {
    return [UIDevice currentDevice].proximityState;
}

- (void)proximityStateDidChange:(NSNotification *)notification {
    UIDevice *device = notification.object;
    if (_proximityStateDidChange) {
        _proximityStateDidChange(device.proximityState);
    }
}

@end
