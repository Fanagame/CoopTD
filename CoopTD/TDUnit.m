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
#import "TDProgressBar.h"

static const CGFloat kUnitMovingSpeed = 0.3f;
NSString * const kTDUnitDiedNotificationName = @"kUnitDiedNotificationName";

@interface TDUnit ()

@property (nonatomic, strong) TDProgressBar *healthBar;
@property (nonatomic, strong) NSPredicate *bulletFilter;

@end

@implementation TDUnit

+ (uint32_t) physicsCategoryForUnitType:(TDUnitType)unitType {
    uint32_t category;
    
    switch (unitType) {
        case TDUnitType_Ground:
            category = kPhysicsCategory_UnitType_Ground;
            break;
            
        default:
            category = kPhysicsCategory_UnitType_Air;
            break;
    }
    
    return category;
}

+ (uint32_t) physicsCategoryForUnitWithType:(TDUnitType)unitType {
    return (kPhysicsCategory_Unit | [TDUnit physicsCategoryForUnitType:unitType]);
}

+ (TDUnit *) unitWithType:(TDUnitType)unitType {
    NSString *baseCacheKey = (unitType == TDUnitType_Ground ? @"monster_ground_1" : @"monster_air_1");
    TDUnit *unit = [[self alloc] initWithType:unitType andBaseCacheKey:baseCacheKey];
    
    return unit;
}

// This should eventually be the only method to load a mob
- (id) init {
    return [self initWithType:TDUnitType_Ground andBaseCacheKey:@"monster_ground_1"];
}

- (id) initWithObjectID:(NSInteger)objectID {
    return [self init];
}

- (id) initWithType:(TDUnitType)unitType andBaseCacheKey:(NSString *)baseCacheKey {
    self = [super initWithImageNamed:baseCacheKey];
    
    if (self) {
        // this should be made dynamic
        self.baseCacheKey = baseCacheKey;
        self.type = unitType;
        self.displayName = baseCacheKey;
        self.maxHealth = 200;
        self.health = self.maxHealth;
        self.softCurrencyEarningValue = 50;
        self.softCurrencyBuyingValue = 200;
        self.timeIntervalBetweenHits = 0;
        self.statusEffectsImmunity = kTDBulletEffect_Fire | kTDBulletEffect_Poison;
        
        // setup intelligence
        self.intelligence = [[TDBaseUnitAI alloc] initWithCharacter:self andTarget:nil];
        
        // add health bar
        self.healthBar = [[TDProgressBar alloc] initWithTotalTicks:self.maxHealth aboveSprite:self];
#ifndef kTDUnit_ALWAYS_SHOW_HEALTH
        self.healthBar.hideWhenFull = YES;
#endif
        [self addChild:self.healthBar];
        
        // misc
        self.bulletFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            SKPhysicsBody *body = (SKPhysicsBody *)evaluatedObject;
            if (body.categoryBitMask == (kPhysicsCategory_Bullet | [TDUnit physicsCategoryForUnitType:self.type]) && [body.node.parent isKindOfClass:[TDBaseBullet class]]) {
                return YES;
            }
            return NO;
        }];
        
        // setup physics
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.categoryBitMask = [TDUnit physicsCategoryForUnitWithType:self.type];
        self.physicsBody.collisionBitMask = 0; // kPhysicsCategory_Building
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.mass = 1000;
        self.physicsBody.restitution = 1;
        
        // await for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pathDidUpdate:) name:kTDPathFindingPathWasInvalidatedNotificationName object:nil];
    }
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.path = nil; // releases the cache
}

/// @description Change the unit status. Going to standby cancels any of its ongoing actions.
- (void) setPathFindingStatus:(TDUnitPathFindingStatus)status {
    if (status == TDUnitPathFindingStatus_Standy || status == TDUnitPathFindingStatus_CalculatingPath) {
        self.path = nil;
        [self removeAllActions];
    }
    
    _pathFindingStatus = status;
}

- (void) setPath:(TDPath *)path {
    [self.path removeOwner:self];
    
    _path = path;
    
    [self.path addOwner:self];
}

- (void) setHealth:(NSUInteger)health {
    _health = health;
    
    self.healthBar.currentTick = health;
    
    if (_health == 0)
        [self die];
}

- (void) increaseHealth:(NSUInteger)amount {
    amount = MIN(amount, self.maxHealth - self.health);
    self.health += amount;
}

- (void) decreaseHealth:(NSUInteger)amount {
    amount = MIN(self.health, amount);
    self.health -= amount;
}

- (void) setMaxHealth:(NSUInteger)maxHealth {
    _maxHealth = maxHealth;
    
    self.healthBar.totalTicks = maxHealth;
}

#pragma mark - Updates

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
    NSArray *beamBullets = [self.physicsBody.allContactedBodies filteredArrayUsingPredicate:self.bulletFilter];

    for (SKPhysicsBody *body in beamBullets) {
        [self hitByBullet:(TDBaseBullet *)body.node.parent];
    }
    
    //TODO: take status effects into account here
}

#pragma mark - Handle collisions 

- (void) collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super collidedWith:body contact:contact];
    
    if (body.categoryBitMask == kPhysicsCategory_UltimateGoal && [body.node isKindOfClass:[TDUltimateGoal class]]) {
        [self reachedUltimateGoal];
    } else if (body.categoryBitMask == (kPhysicsCategory_Bullet | [TDUnit physicsCategoryForUnitType:self.type])) {
        TDBaseBullet *bullet = nil;
        
        if ([body.node isKindOfClass:[TDBaseBullet class]])
            bullet = (TDBaseBullet *)body.node;
        
        if (bullet)
            [self hitByBullet:bullet];
    }
}

- (void) stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super stoppedCollidingWith:body contact:contact];
}

#pragma mark - Unit actions

- (void) reachedUltimateGoal {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTDUnitDiedNotificationName object:self];
    [self removeFromParent];
    
    if (self.player != [TDPlayer localPlayer])
        self.player.remainingLives++;
    
    [TDPlayer localPlayer].remainingLives--;
}

- (void) die {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTDUnitDiedNotificationName object:self];
    [self removeFromParent];
    
    [[TDPlayer localPlayer] addSoftCurrency:self.softCurrencyEarningValue];
}

- (void) hitByBullet:(TDBaseBullet *)bullet {
    [self decreaseHealth:bullet.attack];
    [self updateStatusEffects:bullet];
}

/*
 * Attack : 0000 0011
 * Immune : 0000 0110
 * A&I    : 0000 0010
 * A^(A&I): 0000 0001 (XOR)
 */
- (void) updateStatusEffects:(TDBaseBullet *)bullet {
    uint32_t statusEffectsToApply = bullet.attackEffect ^ (bullet.attackEffect & self.statusEffectsImmunity);
    
//    NSLog(@"Attack %d", bullet.attackEffect); // 3 => Freeze + Fire
//    NSLog(@"Immune %d", self.statusEffectsImmunity); // 6 => Fire + Poison
//    NSLog(@"Applied %d", statusEffectsToApply); // 1 => Freeze
    
    uint32_t newStatusEffects = self.currentStatusEffects | statusEffectsToApply;
    
    if (newStatusEffects != self.currentStatusEffects) {
        self.currentStatusEffects |= statusEffectsToApply;

        // do something special?
    }
}

#pragma mark - ExploringObjectDelegate

- (NSString *) exploringObjectType {
    return [NSString stringWithFormat:@"%d", self.type];
}

#pragma mark - Moving unit along a path

- (void) pathDidUpdate:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[TDPath class]]) {
        if (self.path == notification.object) {
            CGPoint oldDestination = [[self.path.positionsPathArray lastObject] position];
            
            self.path = nil;
            [self removeAllActions];
            
            [self moveTowards:oldDestination withTimeInterval:0];
        }
    }
}

- (void) moveTowards:(CGPoint)mapPosition withTimeInterval:(CFTimeInterval)interval {
    if (self.pathFindingStatus != TDUnitPathFindingStatus_CalculatingPath) {
        self.pathFindingStatus = TDUnitPathFindingStatus_CalculatingPath;
        
        CGPoint selfCoord = [self.gameScene tileCoordinatesForPositionInMap:self.position];
        CGPoint destCoord = [self.gameScene tileCoordinatesForPositionInMap:mapPosition];
        
        __weak TDUnit *weakSelf = self;
        [[TDPathFinder sharedPathCache] pathInExplorableWorld:self.gameScene fromA:selfCoord toB:destCoord usingDiagonal:NO withObject:self onSuccess:^(TDPath *path) {
            [weakSelf followPath:path];
            weakSelf.pathFindingStatus = TDUnitPathFindingStatus_Moving;
        }];
    }
}

- (void) followPath:(TDPath *)path withCompletionHandler:(void (^)())onComplete {
    self.path = path;
    
    NSMutableArray *moveActions = [[NSMutableArray alloc] init];
    for (PathNode *node in path.positionsPathArray) {
        SKAction *action = [SKAction moveTo:node.position duration:kUnitMovingSpeed];
        [moveActions addObject:action];
    }
    
    [self runAction:[SKAction sequence:moveActions] completion:onComplete];
}

- (void) followPath:(TDPath *)path {
    [self followPath:path withCompletionHandler:nil];
}

@end
