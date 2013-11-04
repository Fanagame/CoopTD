//
//  TDBuilding.h
//  CoopTD
//
//  Created by Rémy Bardou on 01/11/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDMapObject.h"

@class TDUnit;

@interface TDBuilding : TDMapObject

@property (nonatomic, assign) CGFloat range;
@property (nonatomic, assign) NSInteger softCurrencyPrice;

- (BOOL) rangeIsVisibe;
- (void) setRangeVisible:(BOOL)hidden;
- (void) attackTarget:(TDUnit *)unit;

@end
