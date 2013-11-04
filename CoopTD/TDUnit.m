//
//  TDUnit.m
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDUnit.h"
#import "TDPathFinder.h"
#import "TDBaseUnitAI.h"
#import "TDPathFinder.h"
#import "TDConstants.h"
#import "TDSpawn.h"
#import "TDPlayer.h"
#import "TDUltimateGoal.h"
#import "TDBaseBullet.h"

static const CGFloat kUnitMovingSpeed = 0.3f;

@interface TDUnit ()

@property (nonatomic, strong) NSArray *path;

@end

@implementation TDUnit

- (id) init {
    self = [super initWithImageNamed:@"pikachu-32"];
    
    if (self) {
        self.displayName = @"Pikachu";
        self.softCurrencyEarningValue = 50;
        self.softCurrencyBuyingValue = 200;
        self.intelligence = [[TDBaseUnitAI alloc] initWithCharacter:self andTarget:nil];
        
        // setup physics
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.categoryBitMask = kPhysicsCategory_Unit;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.collisionBitMask = 0;
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

- (void) setHealth:(NSInteger)health {
    if (health < 0) { health = 0; }
    
    _health = health;
    
    if (_health == 0)
        [self die];
}

#pragma mark - Handle collisions 

- (void) collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super collidedWith:body contact:contact];
    
    if ([body.node isKindOfClass:[TDUltimateGoal class]]) {
        [self reachedUltimateGoal];
    } else if ([body.node isKindOfClass:[TDBaseBullet class]]) {
        [self hitByBullet:(TDBaseBullet *)body.node];
    }
}

- (void) stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super stoppedCollidingWith:body contact:contact];
}

#pragma mark - Unit actions

- (void) reachedUltimateGoal {
    [self.spawn unitWasKilled:self];
    [self removeFromParent];
    
    [TDPlayer localPlayer].remainingLives--;
}

- (void) die {
    [self.spawn unitWasKilled:self];
    [self removeFromParent];
    
    [[TDPlayer localPlayer] addSoftCurrency:self.softCurrencyEarningValue];
}

- (void) hitByBullet:(TDBaseBullet *)bullet {
    self.health -= bullet.attack;
}

#pragma mark - Moving unit along a path

- (void) moveTowards:(CGPoint)mapPosition withTimeInterval:(CFTimeInterval)interval {
    if (self.status != TDUnitStatus_CalculatingPath) {
        self.status = TDUnitStatus_CalculatingPath;
        
        CGPoint selfCoord = [self.gameScene tileCoordinatesForPositionInMap:self.position];
        CGPoint destCoord = [self.gameScene tileCoordinatesForPositionInMap:mapPosition];
        
        __weak TDUnit *weakSelf = self;
        [[TDPathFinder sharedPathCache] pathInExplorableWorld:self.gameScene fromA:selfCoord toB:destCoord usingDiagonal:NO onSuccess:^(TDPath *path) {
            [weakSelf followArrayPath:path.positionsPathArray];
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
