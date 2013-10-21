//
//  TDMapObject.m
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDMapObject.h"
#import "TDArtificialIntelligence.h"

@implementation TDMapObject

- (TDNewGameScene *)gameScene {
    TDNewGameScene *scene = (id)[self scene];
    
    if ([scene isKindOfClass:[TDNewGameScene class]]) {
        return scene;
    } else {
        return nil;
    }
}

#pragma mark - Loop Update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [self.intelligence updateWithTimeSinceLastUpdate:interval];
}

@end
