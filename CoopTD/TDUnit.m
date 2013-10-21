//
//  TDUnit.m
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDUnit.h"
#import "PathFinder.h"
#import "TDBaseUnitAI.h"

CGFloat const kUnitMovingSpeed = 0.3f;

@interface TDUnit ()

@property (nonatomic, strong) NSArray *path;

@end

@implementation TDUnit

- (id) init {
    self = [super initWithImageNamed:@"pikachu-32"];
    
    if (self) {
        self.displayName = @"Pikachu";
        self.intelligence = [[TDBaseUnitAI alloc] initWithCharacter:self andTarget:nil];
    }
    
    return self;
}

/// @description Change the unit status. Going to standby cancels any of its ongoing actions.
- (void) setStatus:(TDUnitStatus)status {
    if (status == TDUnitStatus_Standy || status == TDUnitStatus_CalculatingPath) {
        self.path = nil;
        [self removeAllActions];
    }
    
    _status = status;
}

- (void) moveTowards:(CGPoint)mapPosition withTimeInterval:(CFTimeInterval)interval {
    if (self.status != TDUnitStatus_CalculatingPath) {
        self.status = TDUnitStatus_CalculatingPath;
        
        CGPoint selfCoord = [self.gameScene tileCoordinatesForPosition:self.position];
        CGPoint destCoord = [self.gameScene tileCoordinatesForPosition:mapPosition];
        
        __weak TDUnit *weakSelf = self;
        [[PathFinder sharedInstance] pathInExplorableWorld:self.gameScene fromA:selfCoord toB:destCoord usingDiagonal:YES onSuccess:^(NSArray *path)
        {
            [self.gameScene convertCoordinatesArrayToPositionsArray:path];
            [weakSelf followArrayPath:path];
            weakSelf.status = TDUnitStatus_Moving;
        }];
    }
}

/// @description Makes a unit follow a path from point A to point B
- (void) followArrayPath:(NSArray *)path withCompletionHandler:(void (^)())onComplete {
    self.path = path;
    
    NSMutableArray *moveActions = [[NSMutableArray alloc] init];
    for (PathNode *node in path) {
        SKAction *action = [SKAction moveTo:node.position duration:kUnitMovingSpeed];
        [moveActions addObject:action];
    }
    
    [self runAction:[SKAction sequence:moveActions] completion:onComplete];
}

/// @description Makes a unit follow a path from point A to point B
- (void) followArrayPath:(NSArray *)path {
    [self followArrayPath:path withCompletionHandler:nil];
}

@end
