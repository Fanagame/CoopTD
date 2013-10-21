//
//  TDArtificialIntelligence.h
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDMapObject;

@interface TDArtificialIntelligence : NSObject

@property (nonatomic, weak) TDMapObject *character;
@property (nonatomic, weak) TDMapObject *target;

- (id) initWithCharacter:(TDMapObject *)character andTarget:(TDMapObject *)target;
- (void) changeTarget:(TDMapObject *)target;

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval;

@end
