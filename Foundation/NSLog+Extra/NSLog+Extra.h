//
// NSLog+Extra.h
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

#ifdef __OBJC__

// The __FILE__ lastPathComponent
#ifndef __FILENAME__
#define __FILENAME__ [[[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lastPathComponent] cStringUsingEncoding:NSUTF8StringEncoding]
#endif

// NSLogA will always output like NSLog
#define NSLogA(format, ...) NSLog(@"%@\n%s (%s:%d)", [NSString stringWithFormat:format, ##__VA_ARGS__], __FUNCTION__, __FILENAME__, __LINE__)

// NSLogD will output like NSLog only when the DEBUG variable is set
#ifdef DEBUG
#define NSLogD(format, ...) NSLogA(format, ##__VA_ARGS__)
#else
#define NSLogD(format, ...)
#endif

#endif //__OBJC__
