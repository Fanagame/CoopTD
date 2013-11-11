//
//  TDBaseBullet.m
//  CoopTD
//
//  Created by Remy Bardou on 11/3/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBaseBullet.h"
#import "TDConstants.h"

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

- (void) setAttackableUnitsType:(TDUnitType)attackableUnitsType {
    if (attackableUnitsType != _attackableUnitsType) {
        _attackableUnitsType = attackableUnitsType;
        
        // Update the physics body category (might need to override this in subclasses)
        self.physicsBody.categoryBitMask = kPhysicsCategory_Bullet | [TDUnit physicsCategoryForUnitType:attackableUnitsType];
        self.physicsBody.contactTestBitMask = [TDUnit physicsCategoryForUnitWithType:attackableUnitsType];
    }
}

- (void) startAnimation {
    
}

- (void) destroy {
    // cancel all actions
    [self removeAllActions];
    
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
