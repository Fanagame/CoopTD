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

@class TDSpawn;

typedef enum TDUnitStatus : NSUInteger {
    TDUnitStatus_Standy,
    TDUnitStatus_CalculatingPath,
    TDUnitStatus_Moving
} TDUnitStatus;

@interface TDUnit : TDMapObject

@property (nonatomic, assign) NSInteger unitID;
@property (nonatomic, strong) NSString *displayName;

@property (nonatomic, assign) NSInteger health;
@property (nonatomic, assign) NSInteger maxHealth;

@property (nonatomic, assign) NSInteger softCurrencyEarningValue;
@property (nonatomic, assign) NSInteger softCurrencyBuyingValue;

@property (nonatomic, assign) TDUnitStatus status;
@property (nonatomic, strong, readonly) NSArray *path;

@property (nonatomic, weak) TDSpawn *spawn;

- (void) die;

- (void) moveTowards:(CGPoint)mapPosition withTimeInterval:(CFTimeInterval)interval;
- (void) followArrayPath:(NSArray *)path withCompletionHandler:(void (^)())onComplete;
- (void) followArrayPath:(NSArray *)path;

@end
