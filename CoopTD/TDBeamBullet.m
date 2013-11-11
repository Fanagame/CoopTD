//
//  TDLaserBullet.m
//  CoopTD
//
//  Created by Remy Bardou on 11/8/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBeamBullet.h"
#import "TDConstants.h"

#define kTDBeamBullet_DeltaUpdateInPx 0 // refresh the beam every 10px moved

@interface TDBeamBullet ()

@property (nonatomic, strong) SKShapeNode *laserTipNode;

@end

@implementation TDBeamBullet

- (id) init {
    self = [super initWithColor:[UIColor redColor] size:CGSizeMake(0, 4)];
    
    if (self) {
        self.baseAttack = 1; // dmg/sec
        self.baseSpeed = 0; // infinite speed?
        self.baseSplash = 0;
        
        [self setupPhysics];
    }
    
    return self;
}

- (void) setupPhysics {
    self.laserTipNode = [[SKShapeNode alloc] init];
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, self.size.height, self.size.height), NULL);
    self.laserTipNode.path = path;
    CGPathRelease(path);
#ifdef kTDBeamBullet_SHOW_PHYSICS_BODY
    self.laserTipNode.fillColor = [UIColor greenColor];
#else
    self.laserTipNode.strokeColor = [UIColor clearColor];
#endif
    [self addChild:self.laserTipNode];
    
    CGSize size = self.laserTipNode.frame.size;
    if (size.height > 0 && size.width > 0) {
         //need to change physicsBody's position to the end of the beam (we only wanna do damages to the targetted unit)
        self.laserTipNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(size.height, size.height)];
        self.laserTipNode.physicsBody.categoryBitMask = kPhysicsCategory_Bullet;
        self.laserTipNode.physicsBody.collisionBitMask = 0;
        self.laserTipNode.physicsBody.contactTestBitMask = kPhysicsCategory_Unit;
    }
}

- (void) setAttackableUnitsType:(TDUnitType)attackableUnitsType {
    [super setAttackableUnitsType:attackableUnitsType];
    
    self.laserTipNode.physicsBody.categoryBitMask = kPhysicsCategory_Bullet | [TDUnit physicsCategoryForUnitType:attackableUnitsType];
    self.laserTipNode.physicsBody.contactTestBitMask = [TDUnit physicsCategoryForUnitWithType:attackableUnitsType];
}

- (void) startAnimation {
//    static BOOL playing = NO;
//    if (!playing && !self.soundAction) {
//        self.soundAction = [SKAction playSoundFileNamed:@"bullets_laser_pulse.mp3" waitForCompletion:NO];
//        [self runAction:self.soundAction];
//        playing = YES;
//    }
}

- (void) updateWidth:(CGFloat)width {
    if (abs(width - self.size.width) > kTDBeamBullet_DeltaUpdateInPx) {
        self.size = CGSizeMake(width, self.size.height);
        self.laserTipNode.position = CGPointMake(self.size.width - self.laserTipNode.frame.size.width, -self.laserTipNode.frame.size.height * 0.5);
    }
}

- (void) collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    // do nothing (don't call super method or we'll get destroyed!
}

- (void) stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super stoppedCollidingWith:body contact:contact];
    
    [self destroy];
}

@end
