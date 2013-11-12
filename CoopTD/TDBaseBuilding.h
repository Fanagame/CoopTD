//
//  TDBuilding.h
//  CoopTD
//
//  Created by Rémy Bardou on 01/11/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDMapObject.h"

#import "TDBaseBullet.h"
#import "TDUnit.h"

@class TDProgressBar;

@interface TDBaseBuilding : TDMapObject

// properties set dynamically
@property (nonatomic, assign) CGFloat range;
@property (nonatomic, assign) NSInteger softCurrencyPrice;
@property (nonatomic, assign) CFTimeInterval timeIntervalBetweenShots;
@property (nonatomic, assign) NSUInteger maxBulletsOnScreen;
@property (nonatomic, assign) TDBulletType bulletType;
@property (nonatomic, assign) TDUnitType attackableUnitType;
@property (nonatomic, assign) NSUInteger health;
@property (nonatomic, assign) NSUInteger maxHealth;
@property (nonatomic, assign) CFTimeInterval timeToBuild;

// properties used to make the game do its job
@property (nonatomic, strong) NSMutableArray *unitsInRange;
@property (nonatomic, strong) NSMutableArray *bullets;
@property (nonatomic, strong) NSDate *lastShotDate;
@property (nonatomic, strong) NSDate *dateConstructionStarted;
@property (nonatomic, readonly) TDBaseBullet *nextBullet;
@property (nonatomic, assign) BOOL isConstructed;
@property (nonatomic, assign) BOOL isPlaced;

@property (nonatomic, strong) TDProgressBar *healthBar;
@property (nonatomic, strong) TDProgressBar *constructionBar;

- (id) initWithAttackableUnitsType:(TDUnitType)attackableUnitsType;
- (id) initWithAttackableUnitsType:(TDUnitType)attackableUnitsType andBaseCacheKey:(NSString *)baseCacheKey;

- (BOOL) rangeIsVisibe;
- (void) setRangeVisible:(BOOL)hidden;
- (void) showRangeStatusWihtConstructableColor:(BOOL)isConstructable;

- (void) attackTarget:(TDUnit *)target;

@end
