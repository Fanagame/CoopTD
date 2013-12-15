//
//  TDBaseBuff.m
//  CoopTD
//
//  Created by Remy Bardou on 11/13/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBaseBuff.h"

CGFloat const kTDBuffFreezeFactor = 0.4;
CGFloat const kTDBuffFreezeDuration = 2;

@implementation TDBaseBuff

#pragma mark - Init stuff

- (id) initWithType:(TDBuffType)buffType duration:(CFTimeInterval)duration andStrength:(CGFloat)strength {
    self = [super init];
    
    if (self) {
        self.type = buffType;
        self.duration = duration;
        self.effectPerSec = strength;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    TDBaseBuff *newBuff = [[TDBaseBuff allocWithZone:zone] initWithType:self.type duration:self.duration andStrength:self.effectPerSec];
    return newBuff;
}

- (id) initFreezeBuff {
    return [self initFreezeBuffWithDuration:kTDBuffFreezeDuration andStrength:kTDBuffFreezeFactor];
}

- (id) initFreezeBuffWithDuration:(CFTimeInterval)duration andStrength:(CGFloat)strength {
    return [self initWithType:TDBuffType_Freeze duration:duration andStrength:strength];
}

- (id) initFireBuff {
    return [self initFireBuffWithDuration:0 andStrength:0];
}

- (id) initFireBuffWithDuration:(CFTimeInterval)duration andStrength:(CGFloat)strength {
    return [self initWithType:TDBuffType_Fire duration:duration andStrength:strength];
}

- (id) initPoisonBuff {
    return [self initPoisonBuffWithDuration:0 andDamagesPerSecond:0];
}

- (id) initPoisonBuffWithDuration:(CFTimeInterval)duration andDamagesPerSecond:(CGFloat)strength {
    return [self initWithType:TDBuffType_Poison duration:duration andStrength:MIN(60, strength)]; // should not be smaller than 60, or no damage will be dealt per frame
}

- (id) initHealBuffWithDuration:(CFTimeInterval)duration andStrength:(CGFloat)strength {
    return [self initWithType:TDBuffType_Heal duration:duration andStrength:MIN(60, strength)]; // should not be smaller than 60, or no heal will occur each frame
}

- (void) startBuff {
    self.startDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
}

- (void) stopBuff {
    self.startDate = nil;
}

- (BOOL) isExpired {
    if (self.isActive && self.duration > 0 && -[self.startDate timeIntervalSinceNow] > self.duration) {
        return YES;
    }
    
    return NO;
}

- (BOOL) isActive {
    return (self.startDate != nil);
}

#pragma mark - Private stuff

+ (NSString *) keyForBuff:(TDBaseBuff *)buff {
    return [NSString stringWithFormat:@"%d", buff.type];
}

#pragma mark - Public helper

+ (BOOL) addBuffs:(NSMutableDictionary *)buffs toBuffList:(NSMutableDictionary *)buffList withImmunities:(NSMutableDictionary *)immunities {
    BOOL ok = NO;
    
    for (TDBaseBuff *buff in buffs.allValues) {
        BOOL localOK = [self addBuff:buff toBuffList:buffList withImmunities:immunities];
        
        if (localOK) {
            ok = YES;
        }
    }
    
    return ok;
}

+ (BOOL) addBuff:(TDBaseBuff *)buff toBuffList:(NSMutableDictionary *)buffList withImmunities:(NSMutableDictionary *)immunities {
    BOOL ok = NO;
    
    if (buffList && buff) {
        NSString *key = [self keyForBuff:buff];
        TDBaseBuff *existingBuff = buffList[key];
        BOOL isImmune = (immunities[key] != nil);
        
        if (!isImmune) {
            if (existingBuff) {
                // is the new buff better? then upgrade it!
                if (buff.duration > existingBuff.duration || buff.effectPerSec > existingBuff.effectPerSec) {
                    existingBuff.effectPerSec = buff.effectPerSec;
                    existingBuff.duration = buff.duration;
                    [existingBuff startBuff];
                    ok = YES;
                }
            } else {
                buffList[key] = [buff copy]; // only store a copy of it. we will update its start date
                [buffList[key] startBuff];
                ok = YES;
            }
        }
    }
    
    return ok;
}

+ (BOOL) addImmunity:(TDBaseBuff *)immunity toImmunityList:(NSMutableDictionary *)immunityList {
    return [self addBuff:immunity toBuffList:immunityList withImmunities:nil];
}

+ (BOOL) checkForExpiredBuffsInList:(NSMutableDictionary *)buffList {
    BOOL ok = NO;
    
    NSMutableArray *keysToRemove = [[NSMutableArray alloc] init];
    for (TDBaseBuff *buff in buffList.allValues) {
        if ([buff isExpired]) {
            [keysToRemove addObject:[self keyForBuff:buff]];
            ok = YES;
        }
    }
    
    [buffList removeObjectsForKeys:keysToRemove];
    
    return ok;
}

+ (BOOL) buffs:(NSDictionary *)buffs containsBuffOfType:(TDBuffType)buffType {
    BOOL ok = NO;
    
    for (TDBaseBuff *buff in buffs.allValues) {
        if (buff.type == buffType) {
            ok = YES;
        }
    }
    
    return ok;
}

+ (TDBaseBuff *) buffOfType:(TDBuffType)buffType inBuffs:(NSDictionary *)buffs {
    TDBaseBuff *myBuff = nil;
    
    for (TDBaseBuff *buff in buffs.allValues) {
        if (buff.type == buffType) {
            myBuff = buff;
            break;
        }
    }
    
    return myBuff;
}

@end
