//
// AVAudioSession+ZXToolbox.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2018 Zhao Xin
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
#import "NSObject+ZXToolbox.h"
#import "ZXKeyValueObserver.h"

static char isOverrideSpeakerKey;
static char audioSessionRouteChangeKey;
static char audioSessionRouteChangeObserverKey;
static char systemVolumeDidChangeKey;
static char systemVolumeDidChangeObserverKey;

@interface AVAudioSession ()
@property (nonatomic, nullable, strong) id audioSessionRouteChangeObserver;
@property (nonatomic, nullable, strong) ZXKeyValueObserver *systemVolumeDidChangeObserver;

@end

@implementation AVAudioSession (ZXToolbox)

#pragma mark Input & Output

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

#pragma mark Override Speaker

- (void)setOverrideSpeaker:(BOOL)overrideSpeaker {
    [self setAssociatedObject:&isOverrideSpeakerKey value:@(overrideSpeaker) policy:OBJC_ASSOCIATION_RETAIN];
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
    NSNumber *number = [self getAssociatedObject:&isOverrideSpeakerKey];
    return number ? [number boolValue] : false;
}

#pragma mark Audio Session Route Change

- (void)setAudioSessionRouteChange:(void (^)(AVAudioSessionRouteDescription * _Nonnull, AVAudioSessionRouteChangeReason))audioSessionRouteChange {
    [self setAssociatedObject:&audioSessionRouteChangeKey value:audioSessionRouteChange policy:OBJC_ASSOCIATION_COPY];
    if (audioSessionRouteChange) {
        [self addAudioSessionRouteChangeObserver];
    } else {
        [self removeAudioSessionRouteChangeObserver];
    }
}

- (void (^)(AVAudioSessionRouteDescription *, AVAudioSessionRouteChangeReason))audioSessionRouteChange {
    return [self getAssociatedObject:&audioSessionRouteChangeKey];
}

- (void)addAudioSessionRouteChangeObserver {
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

- (void)removeAudioSessionRouteChangeObserver {
    if (self.audioSessionRouteChangeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.audioSessionRouteChangeObserver];
        self.audioSessionRouteChangeObserver = nil;
    }
}

- (void)setAudioSessionRouteChangeObserver:(id)audioSessionRouteChangeObserver {
    [self setAssociatedObject:&audioSessionRouteChangeObserverKey value:audioSessionRouteChangeObserver policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (id)audioSessionRouteChangeObserver {
    return [self getAssociatedObject:&audioSessionRouteChangeObserverKey];
}

#pragma mark System Volume

- (float)systemVolume {
    return self.outputVolume;
}

- (void)setSystemVolume:(float)systemVolume {
    static UISlider *volumeSlider = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeSlider = (UISlider *)view;
                break;
            }
        }
    });
    volumeSlider.value = systemVolume;
}

- (void)setSystemVolumeDidChange:(void (^)(float))systemVolumeDidChange {
    [self setAssociatedObject:&systemVolumeDidChangeKey value:systemVolumeDidChange policy:OBJC_ASSOCIATION_COPY];
    if (systemVolumeDidChange) {
        [self addSystemVolumeDidChangeObserver];
    } else {
        [self removeSystemVolumeDidChangeObserver];
    }
}

- (void (^)(float))systemVolumeDidChange {
    return [self getAssociatedObject:&systemVolumeDidChangeKey];
}

- (void)addSystemVolumeDidChangeObserver {
    if (self.systemVolumeDidChangeObserver == nil) {
        self.systemVolumeDidChangeObserver = [[ZXKeyValueObserver alloc] init];
        __weak typeof(self) weakSelf = self;
        [self.systemVolumeDidChangeObserver observe:self keyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:NULL changeHandler:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, void * _Nullable context) {
            float volume = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            weakSelf.systemVolumeDidChange(volume);
        }];
    }
    [self setActive:YES error:nil];
}

- (void)removeSystemVolumeDidChangeObserver {
    if (self.systemVolumeDidChangeObserver) {
        [self.systemVolumeDidChangeObserver invalidate];
        self.systemVolumeDidChangeObserver = nil;
    }
}

- (void)setSystemVolumeDidChangeObserver:(ZXKeyValueObserver *)systemVolumeDidChangeObserver {
    [self setAssociatedObject:&systemVolumeDidChangeObserverKey value:systemVolumeDidChangeObserver policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (ZXKeyValueObserver *)systemVolumeDidChangeObserver {
    return [self getAssociatedObject:&systemVolumeDidChangeObserverKey];
}

#pragma mark Dealloc

- (void)dealloc {
    [self removeAudioSessionRouteChangeObserver];
    [self removeSystemVolumeDidChangeObserver];
}
@end
