//
//  TDLaserBullet.m
//  CoopTD
//
//  Created by Remy Bardou on 11/8/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBeamBullet.h"
#import "TDConstants.h"

@implementation TDBeamBullet

- (id) init {
    self = [super initWithColor:[UIColor redColor] size:CGSizeMake(0, 4)];
    
    if (self) {
        self.baseAttack = 5; // dmg/sec
        self.baseSpeed = 0; // infinite speed?
        self.baseSplash = 0;
        
        [self setupPhysics];
    }
    
    return self;
}

- (void) setupPhysics {
    CGSize size = self.size;
    if (size.height > 0 && size.width > 0) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.mass = 1.0;
        self.physicsBody.friction = 0;
        self.physicsBody.linearDamping = 0;
        self.physicsBody.categoryBitMask = kPhysicsCategory_Bullet;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = kPhysicsCategory_Unit;
    }
}

- (void) updateWidth:(CGFloat)width {
    self.size = CGSizeMake(width, self.size.height);
    
    [self setupPhysics];
}

- (void) collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    // do nothing (don't call super method or we'll get destroyed!
}

- (void) stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super stoppedCollidingWith:body contact:contact];
    
    [self destroy];
}

@end
