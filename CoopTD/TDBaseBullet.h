//
//  TDBaseBullet.h
//  CoopTD
//
//  Created by Remy Bardou on 11/3/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDMapObject.h"
#import "TDEnums.h"
#import "TDUnit.h"

extern NSString * const kTDBulletDestroyedNotificationName;

@interface TDBaseBullet : TDMapObject

@property (nonatomic, assign) CGFloat baseAttack;
@property (nonatomic, assign) CGFloat bonusAttack;

@property (nonatomic, assign) CGFloat baseSpeed;
@property (nonatomic, assign) CGFloat bonusSpeed;

@property (nonatomic, assign) CGFloat baseSplash;
@property (nonatomic, assign) CGFloat bonusSplash;

@property (nonatomic, assign) uint32_t attackEffect; //TODO: review, should we really keep it like this?
@property (nonatomic, assign) CGFloat  attackEffectPerSec;
@property (nonatomic, assign) CFTimeInterval attackEffectDuration;

@property (nonatomic, readonly) CGFloat attack;
@property (nonatomic, readonly) CGFloat speed;
@property (nonatomic, readonly) CGFloat splash;

@property (nonatomic, assign) TDUnitType attackableUnitsType;

- (void) attackTarget:(TDMapObject *)target fromObject:(TDMapObject *)attacker;
- (void) startAnimation;
- (void) destroy;

@end
