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

extern NSString * const kTDUnitDiedNotificationName;

@class TDSpawn, TDPath, TDPlayer;

typedef enum TDUnitStatus : NSUInteger {
    TDUnitStatus_Standy,
    TDUnitStatus_CalculatingPath,
    TDUnitStatus_Moving
} TDUnitStatus;

typedef enum TDUnitType : NSUInteger {
    TDUnitType_Ground,
    TDUnitType_Air
} TDUnitType;

@interface TDUnit : TDMapObject<ExploringObjectDelegate>

// properties from DB
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) TDUnitType type;

@property (nonatomic, assign) CFTimeInterval timeIntervalBetweenHits;
@property (nonatomic, assign) NSUInteger health;
@property (nonatomic, assign) NSUInteger maxHealth;

@property (nonatomic, assign) NSInteger softCurrencyEarningValue;
@property (nonatomic, assign) NSInteger softCurrencyBuyingValue;

// properties to make the game work
@property (nonatomic, strong) NSDate* lastHitDate;
@property (nonatomic, assign) TDUnitStatus status;
@property (nonatomic, strong, readonly) NSArray *path;
@property (nonatomic, strong) TDPath *pathToVictory;
@property (nonatomic, weak)   TDPlayer *player;

+ (uint32_t) physicsCategoryForUnitType:(TDUnitType)unitType;
+ (uint32_t) physicsCategoryForUnitWithType:(TDUnitType)unitType;

+ (TDUnit *) unitWithType:(TDUnitType)unitType;

- (id) initWithType:(TDUnitType)unitType andBaseCacheKey:(NSString *)baseCacheKey;

- (void) die;

- (void) moveTowards:(CGPoint)mapPosition withTimeInterval:(CFTimeInterval)interval;
- (void) followArrayPath:(NSArray *)path withCompletionHandler:(void (^)())onComplete;
- (void) followArrayPath:(NSArray *)path;

@end
