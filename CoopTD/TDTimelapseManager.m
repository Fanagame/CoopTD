//
//  TDTimelapseManager.m
//  CoopTD
//
//  Created by Remy Bardou on 12/14/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDTimelapseManager.h"

#define BASE_FRAMERATE (1.0f / 60.0f)

@implementation TDTimelapseManager

+ (CGFloat) convertPerSecondFloat:(CGFloat)floatValue toFrameWithInterval:(NSTimeInterval)interval {
    // if poison deals 120hp per sec, each frame should take out 2hp, since the game normally runs at 60 fps
    if (interval <= BASE_FRAMERATE) {
        return BASE_FRAMERATE * floatValue;
    } else {
        // if the game is slow and takes more than 1/60 sec to refresh, we calculate how many ticks should have passed
        // note that this could have been the main formula, withou any if, but this way should spare some calculations
        // to the cpu (dividing float values is expensive)
        
        CGFloat ticks = MIN(floorf(interval / BASE_FRAMERATE), 1);
        return ticks * BASE_FRAMERATE * floatValue;
    }
}

@end
