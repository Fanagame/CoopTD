//
//  TDUnit.h
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "TDMapObject.h"
#import "TDPathFinder.h"
#import "TDEnums.h"

extern NSString * const kTDUnitDiedNotificationName;

@class TDSpawn, TDPath, TDPlayer;

@interface TDUnit : TDMapObject<ExploringObjectDelegate>

// properties from DB
@property (nonatomic, assign) TDUnitType type;
@property (nonatomic, assign) CFTimeInterval timeIntervalBetweenHits;
@property (nonatomic, assign) NSUInteger health;
@property (nonatomic, assign) NSUInteger maxHealth;
@property (nonatomic, assign) NSInteger softCurrencyEarningValue;
@property (nonatomic, assign) NSInteger softCurrencyBuyingValue;
@property (nonatomic, assign) uint32_t statusEffectsImmunity;

// properties to make the game work
@property (nonatomic, strong) NSDate* lastHitDate;
@property (nonatomic, assign) TDUnitPathFindingStatus pathFindingStatus;
@property (nonatomic, strong) TDPath *path;
@property (nonatomic, weak)   TDPlayer *player;
@property (nonatomic, assign) uint32_t currentStatusEffects;

+ (uint32_t) physicsCategoryForUnitType:(TDUnitType)unitType;
+ (uint32_t) physicsCategoryForUnitWithType:(TDUnitType)unitType;

+ (TDUnit *) unitWithType:(TDUnitType)unitType;

- (id) initWithType:(TDUnitType)unitType andBaseCacheKey:(NSString *)baseCacheKey;

- (void) die;

- (void) moveTowards:(CGPoint)mapPosition withTimeInterval:(CFTimeInterval)interval;
- (void) followPath:(TDPath *)path withCompletionHandler:(void (^)())onComplete;
- (void) followPath:(TDPath *)path;

@end
