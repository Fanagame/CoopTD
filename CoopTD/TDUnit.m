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
#import "TDBaseBuilding.h"
#import "TDHealthBar.h"

static const CGFloat kUnitMovingSpeed = 0.3f;
NSString * const kTDUnitDiedNotificationName = @"kUnitDiedNotificationName";

@interface TDUnit ()

@property (nonatomic, strong) NSArray *path;
@property (nonatomic, strong) TDHealthBar *healthBar;

@end

@implementation TDUnit

- (id) init {
    self = [super initWithImageNamed:@"pikachu-32"];
    
    if (self) {
        // this should be made dynamic
        self.displayName = @"Pikachu";
        self.maxHealth = 200;
        self.health = self.maxHealth;
        self.softCurrencyEarningValue = 50;
        self.softCurrencyBuyingValue = 200;
        self.timeIntervalBetweenHits = 0;
        
        // setup intelligence
        self.intelligence = [[TDBaseUnitAI alloc] initWithCharacter:self andTarget:nil];
        
        // add health bar
        self.healthBar = [[TDHealthBar alloc] initWithTotalHP:self.maxHealth aboveSprite:self];
        [self addChild:self.healthBar];
        
        // setup physics
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.categoryBitMask = kPhysicsCategory_Unit;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.collisionBitMask = 0;
        
        // await for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pathDidUpdate:) name:kTDPathFindingInvalidatePathNotificationName object:nil];
    }
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// @description Change the unit status. Going to standby cancels any of its ongoing actions.
- (void) setStatus:(TDUnitStatus)status {
    if (status == TDUnitStatus_Standy || status == TDUnitStatus_CalculatingPath) {
        self.path = nil;
        [self removeAllActions];
    }
    
    _status = status;
}

- (void) setHealth:(NSUInteger)health {
    _health = health;
    
    self.healthBar.currentHP = health;
    
    if (_health == 0)
        [self die];
}

- (void) setMaxHealth:(NSUInteger)maxHealth {
    _maxHealth = maxHealth;
    
    self.healthBar.totalHP = maxHealth;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kTDUnitDiedNotificationName object:self];
    [self removeFromParent];
    
    [TDPlayer localPlayer].remainingLives--;
}

- (void) die {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTDUnitDiedNotificationName object:self];
    [self removeFromParent];
    
    [[TDPlayer localPlayer] addSoftCurrency:self.softCurrencyEarningValue];
}

- (void) hitByBullet:(TDBaseBullet *)bullet {
//    if (!self.lastHitDate || [self.lastHitDate timeIntervalSinceNow] > self.timeIntervalBetweenHits) {
//        self.lastHitDate = [NSDate date];
//        NSLog(@"before hitByBullet: %d", self.healthBar.currentHP);
        self.health -= bullet.attack;
//        NSLog(@"after hitByBullet: %d", self.healthBar.currentHP);
//    }
}

#pragma mark - Moving unit along a path

- (void) pathDidUpdate:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[TDPath class]]) {
        if (self.pathToVictory == notification.object) {
            CGPoint oldDestination = [[self.path lastObject] position];
            
            self.path = nil;
            self.pathToVictory = nil;
            [self removeAllActions];
            
            [self moveTowards:oldDestination withTimeInterval:0];
        }
    }
}

- (void) moveTowards:(CGPoint)mapPosition withTimeInterval:(CFTimeInterval)interval {
    if (self.status != TDUnitStatus_CalculatingPath) {
        self.status = TDUnitStatus_CalculatingPath;
        
        CGPoint selfCoord = [self.gameScene tileCoordinatesForPositionInMap:self.position];
        CGPoint destCoord = [self.gameScene tileCoordinatesForPositionInMap:mapPosition];
        
        __weak TDUnit *weakSelf = self;
        [[TDPathFinder sharedPathCache] pathInExplorableWorld:self.gameScene fromA:selfCoord toB:destCoord usingDiagonal:NO onSuccess:^(TDPath *path) {
            weakSelf.pathToVictory = path;
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
