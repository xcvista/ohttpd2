//
//  CKCommon.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#ifndef CGIKIT_CGICOMMON_H
#define CGIKIT_CGICOMMON_H

// C++-safe code.

#ifdef     __cplusplus

#define CGIBeginDecls   extern "C" {
#define CGIEndDecls     }
#define CGIExtern       extern "C"

#else   // __cplusplus

#define CGIBeginDecls
#define CGIEndDecls
#define CGIExtern       extern

#endif  // __cplusplus

// C-safe Objective-C code.

CGIBeginDecls

#ifdef     __OBJC__

#import <Foundation/Foundation.h>

#define CGIClass        @class

// Providing retain/release functions without triggering ARC errors.

#ifdef     GNUSTEP

#import <objc/objc_arc.h>

static inline id CGIRetain(id obj)
{
    return objc_retain(obj);
}

static inline void CGIRelease(id obj)
{
    objc_release(obj);
}

#else   // GNUSTEP

#import <CoreFoundation/CoreFoundation.h>

static inline id CGIRetain(id obj)
{
    return (__bridge id)CFRetain((__bridge CFTypeRef)obj);
}

static inline void CGIRelease(id obj)
{
    CFRelease((__bridge CFTypeRef)obj);
}

#endif  // GNUSTEP

#else   // __OBJC__

#include <objc/runtime.h>

#define CGIClass        typedef struct objc_object

#endif  // __OBJC__

// Handy functions

#define eprintf(format, ...) fprintf(stderr, format, ##__VA_ARGS__)

#if DEBUG
#define dbgprintf(format, ...) fprintf(stderr, format, ##__VA_ARGS__)
#else
#define dbgprintf(format, ...)
#endif

#define CGIAssignPointer(ptr, val) \
do { typeof(ptr) __ptr = (ptr); \
if (__ptr) *__ptr = (val); \
} while (0)

#ifdef     __OBJC__

#define CGISTR(format, ...) [NSString stringWithFormat:format, ##__VA_ARGS__]

static inline const char *CGICSTR(NSString *string)
{
    return [string cStringUsingEncoding:NSUTF8StringEncoding];
}

CGIExtern NSString *CGIStringFromBufferedAction(NSUInteger size, NSStringEncoding encoding, void (^action)(char *buffer, NSUInteger size));

#endif  // __OBJC__

CGIEndDecls

#endif  // CGIKIT_CGICOMMON_H
