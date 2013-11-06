//
//  TDBuilding.h
//  CoopTD
//
//  Created by Rémy Bardou on 01/11/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDMapObject.h"

@class TDUnit;

@interface TDBaseBuilding : TDMapObject

// properties set dynamically
@property (nonatomic, assign) CGFloat range;
@property (nonatomic, assign) NSInteger softCurrencyPrice;
@property (nonatomic, assign) CFTimeInterval timeIntervalBetweenShots;
@property (nonatomic, assign) NSUInteger maxBulletsOnScreen;

// properties used to make the game do its job
@property (nonatomic, strong) NSMutableArray *unitsInRange;
@property (nonatomic, strong) NSMutableArray *bullets;
@property (nonatomic, strong) NSDate *lastShotDate;

- (BOOL) rangeIsVisibe;
- (void) setRangeVisible:(BOOL)hidden;

- (void) attackTarget:(TDUnit *)target;

@end
