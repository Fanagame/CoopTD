//
//  TDArrowBullet.m
//  CoopTD
//
//  Created by Remy Bardou on 11/3/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDProjectileBullet.h"
#import "TDConstants.h"

@implementation TDProjectileBullet

- (id) init {
    self = [super initWithColor:[UIColor purpleColor] size:CGSizeMake(16, 16)];
    
    if (self) {
        self.baseAttack = 20;
        self.baseSpeed = 2;
        self.baseSplash = 0;
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.mass = 1.0;
        self.physicsBody.friction = 0;
        self.physicsBody.linearDamping = 0;
        self.physicsBody.categoryBitMask = kPhysicsCategory_Bullet;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = kPhysicsCategory_Unit;
    }
    
    return self;
}

@end
