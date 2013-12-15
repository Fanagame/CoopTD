//
//  TDTimelapseManager.h
//  CoopTD
//
//  Created by Remy Bardou on 12/14/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDTimelapseManager : NSObject

+ (CGFloat) convertPerSecondFloat:(CGFloat)floatValue toFrameWithInterval:(NSTimeInterval)interval;

@end
