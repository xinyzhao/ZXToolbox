//
// AVAudioSession+ZXToolbox.h
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

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAudioSession (ZXToolbox)
/// eg AVAudioSessionPortHeadsetMic etc.
@property (nonatomic, nullable, copy) NSString *currentInput;
/// eg AVAudioSessionPortBuiltInSpeaker etc.
@property (nonatomic, nullable, readonly) NSString *currentOutput;
/// with AVAudioSessionCategoryPlayAndRecord
@property (nonatomic, getter=isOverrideSpeaker) BOOL overrideSpeaker;
/// Audio session route change observer block
@property (nonatomic, nullable, copy) void (^audioSessionRouteChange)(AVAudioSessionRouteDescription *previousRoute, AVAudioSessionRouteChangeReason reason);
/// The system volume, equivalent to outputVolume, but this property can be assignment..
/// @attention: Cannot be used for KVO, Use "outputVolume" to observing.
@property (nonatomic, assign) float systemVolume;
/// The system volume did change observer block
@property (nonatomic, nullable, copy) void (^systemVolumeDidChange)(float volume);

@end

NS_ASSUME_NONNULL_END
