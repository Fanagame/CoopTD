//
//  TDBaseBuff.h
//  CoopTD
//
//  Created by Remy Bardou on 11/13/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDEnums.h"

@interface TDBaseBuff : NSObject<NSCopying>

@property (nonatomic, assign) TDBuffType type;
@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) CGFloat effectPerSec; // could be damage or heal
@property (nonatomic, strong) NSDate *startDate;

- (id) initWithType:(TDBuffType)buffType duration:(CFTimeInterval)duration andStrength:(CGFloat)strength;

- (id) initFreezeBuff;
- (id) initFreezeBuffWithDuration:(CFTimeInterval)duration andStrength:(CGFloat)strength;
- (id) initFireBuff;
- (id) initFireBuffWithDuration:(CFTimeInterval)duration andStrength:(CGFloat)strength;
- (id) initPoisonBuff;
- (id) initPoisonBuffWithDuration:(CFTimeInterval)duration andDamagesPerSecond:(CGFloat)strength;
- (id) initHealBuffWithDuration:(CFTimeInterval)duration andStrength:(CGFloat)strength;

- (void) startBuff;
- (void) stopBuff;
- (BOOL) isActive;
- (BOOL) isExpired;

// Helpers
+ (BOOL) addBuff:(TDBaseBuff *)buff toBuffList:(NSMutableDictionary *)buffList withImmunities:(NSMutableDictionary *)immunities;
+ (BOOL) addBuffs:(NSMutableDictionary *)buffs toBuffList:(NSMutableDictionary *)buffList withImmunities:(NSMutableDictionary *)immunities;
+ (BOOL) addImmunity:(TDBaseBuff *)immunity toImmunityList:(NSMutableDictionary *)immunityList;
+ (BOOL) checkForExpiredBuffsInList:(NSMutableDictionary *)buffList;
+ (BOOL) buffs:(NSDictionary *)buffs containsBuffOfType:(TDBuffType)buffType;
+ (TDBaseBuff *) buffOfType:(TDBuffType)buffType inBuffs:(NSDictionary *)buffs;

@end
