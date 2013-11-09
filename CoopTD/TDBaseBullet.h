//
//  TDBaseBullet.h
//  CoopTD
//
//  Created by Remy Bardou on 11/3/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDMapObject.h"

extern NSString * const kTDBulletDestroyedNotificationName;

typedef enum : uint8_t {
    TDBulletType_Projectile,
    TDBulletType_Beam
} TDBulletType;

@interface TDBaseBullet : TDMapObject

@property (nonatomic, assign) CGFloat baseAttack;
@property (nonatomic, assign) CGFloat bonusAttack;

@property (nonatomic, assign) CGFloat baseSpeed;
@property (nonatomic, assign) CGFloat bonusSpeed;

@property (nonatomic, assign) CGFloat baseSplash;
@property (nonatomic, assign) CGFloat bonusSplash;

@property (nonatomic, readonly) CGFloat attack;
@property (nonatomic, readonly) CGFloat speed;
@property (nonatomic, readonly) CGFloat splash;

- (void) destroy;

@end
