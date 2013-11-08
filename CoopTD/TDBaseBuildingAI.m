//
//  TDBaseBuildingAI.m
//  CoopTD
//
//  Created by Remy Bardou on 11/5/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBaseBuildingAI.h"
#import "TDBaseBuilding.h"
#import "TDUnit.h"
#import "TDConstants.h"

@implementation TDBaseBuildingAI

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
    if ([self.character isKindOfClass:[TDBaseBuilding class]]) {
        TDBaseBuilding *building = (TDBaseBuilding *)self.character;
        
        // Find a target
#ifndef kTDBuildingAI_ALWAYS_SHOOT_THE_NEW_GUY
        if (![building.unitsInRange containsObject:self.target])
#endif
            self.target = [building.unitsInRange lastObject];
        
        if (self.target && [self.target isKindOfClass:[TDUnit class]]) {
            [building attackTarget:(TDUnit *)self.target];
        }
    }
}

@end
