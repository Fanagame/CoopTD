//
//  TDUltimateGoal.m
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDUltimateGoal.h"
#import "TDUnit.h"
#import "TDConstants.h"

@implementation TDUltimateGoal

- (void) setup {
    self.color = [UIColor greenColor];
    
    // setup physics
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.categoryBitMask = kPhysicsCategory_UltimateGoal;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = kPhysicsCategory_Unit;
}

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
}

#pragma mark - Handle collisions

- (void) collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super collidedWith:body contact:contact];
    
    if (body.categoryBitMask == kPhysicsCategory_Unit && [body.node isKindOfClass:[TDUnit class]]) {
        // play animation!!
    }
}

- (void) stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super stoppedCollidingWith:body contact:contact];
    
    NSLog(@"YOUHOUHOU");
}

@end
