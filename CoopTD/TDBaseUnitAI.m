//
//  TDBaseUnitAI.m
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBaseUnitAI.h"
#import "TDMapObject.h"
#import "TDUnit.h"
#import "TDUltimateGoal.h"

@implementation TDBaseUnitAI

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
    if ([self.character isKindOfClass:[TDUnit class]]) {
        TDUnit *unit = (TDUnit *)self.character;
        TDNewGameScene *gameScene = self.character.gameScene;

        // Find a goal in the map
        self.target = gameScene.defaultGoalPoint;
        
        if (self.target) {
            // could complexify the AI later on with target priorities and stuff
            if (unit.status == TDUnitStatus_Standy) {
                [unit moveTowards:self.target.position withTimeInterval:interval];
            }
        }
    }
}

@end
