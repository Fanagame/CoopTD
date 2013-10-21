//
//  TDArtificialIntelligence.m
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDArtificialIntelligence.h"

@implementation TDArtificialIntelligence

- (id) initWithCharacter:(TDMapObject *)character andTarget:(TDMapObject *)target {
    self = [super init];
    
    if (self) {
        _character = character;
        _target = target;
    }
    
    return self;
}

#pragma mark - Loop Update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    /* Overridden by subclasses. */
}

#pragma mark - Targets
- (void)changeTarget:(TDMapObject *)target {
    if (self.target == target) {
        self.target = nil;
    }
}

@end
