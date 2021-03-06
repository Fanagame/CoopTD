//
//  TDArrowBullet.m
//  CoopTD
//
//  Created by Remy Bardou on 11/3/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDProjectileBullet.h"
#import "TDConstants.h"
#import "TDSoundManager.h"

@implementation TDProjectileBullet

- (id) init {
    self = [super init];
    
    if (self) {
        self.size = CGSizeMake(16, 16);
        self.color = [UIColor purpleColor];
        
        self.baseAttack = 20;
        self.baseSpeed = 1;
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

- (void) attackTarget:(TDMapObject *)target fromObject:(TDMapObject *)attacker {
    [self startAnimation];
    
    self.position = attacker.position;
    
    // we need to move the bullet now! use physics
//    [self.physicsBody applyImpulse:CGVectorMake((target.position.x - self.position.x) * self.speed, (target.position.y - attacker.position.y) * self.speed)];
}

- (void) startAnimation {
    [[TDSoundManager sharedManager] playSoundNamed:@"gunshot" withLoop:NO andKey:self.key];
}

- (void) stopAnimation {
}

@end
