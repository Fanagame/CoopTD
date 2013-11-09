//
//  TDBaseBullet.m
//  CoopTD
//
//  Created by Remy Bardou on 11/3/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBaseBullet.h"

NSString * const kTDBulletDestroyedNotificationName = @"kTDBulletDestroyedNotificationName";

@implementation TDBaseBullet

- (CGFloat) attack {
    return self.baseAttack + self.bonusAttack;
}

- (CGFloat) speed {
    return self.baseSpeed + self.bonusSpeed;
}

- (CGFloat) splash {
    return self.baseSplash + self.bonusSplash;
}

- (void) destroy {
    // run some kind of animation maybe?
    
    // then disappear
    [self removeFromParent];
    
    // tell the world about it!
    [[NSNotificationCenter defaultCenter] postNotificationName:kTDBulletDestroyedNotificationName object:self];
}

#pragma mark - Handle collisions

- (void) collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super collidedWith:body contact:contact];
    
    [self destroy];
}

- (void) stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super stoppedCollidingWith:body contact:contact];
}

@end
