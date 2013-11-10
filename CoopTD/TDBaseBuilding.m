//
//  TDBuilding.m
//  CoopTD
//
//  Created by Rémy Bardou on 01/11/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBaseBuilding.h"
#import "TDUnit.h"
#import "TDConstants.h"
#import "TDProjectileBullet.h"
#import "TDBeamBullet.h"
#import "TDBaseBuildingAI.h"

@interface TDBaseBuilding ()

@property (nonatomic, strong) SKShapeNode *rangeNode;
@property (nonatomic, strong) SKShapeNode *bodyNode;

@end

@implementation TDBaseBuilding

- (id) init {
	self = [super initWithImageNamed:@"Tower-Single-Sprite"];
    
	if (self) {
        self.unitsInRange = [[NSMutableArray alloc] init];
        self.bullets = [[NSMutableArray alloc] init];
        self.intelligence = [[TDBaseBuildingAI alloc] initWithCharacter:self andTarget:nil];
        
        //TODO: init this from database or something else
        self.softCurrencyPrice = 200;
        self.timeIntervalBetweenShots = 0.2;
        self.bulletType = TDBulletType_Beam;
        self.maxBulletsOnScreen = (self.bulletType != TDBulletType_Beam ? 3 : 1);
        self.range = (self.bulletType != TDBulletType_Beam ? 100.0f : 200.0f);
        
        self.bodyNode = [[SKShapeNode alloc] init];
        CGPathRef path = CGPathCreateWithRect(self.frame, NULL);
        self.bodyNode.path = path;
        CGPathRelease(path);
#ifdef kTDBuilding_SHOW_PHYSICS_BODY
        self.bodyNode.fillColor = [UIColor redColor];
#else
        self.bodyNode.strokeColor = [UIColor clearColor];
#endif
        self.bodyNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.bodyNode.physicsBody.categoryBitMask = kPhysicsCategory_Building;
        self.bodyNode.physicsBody.collisionBitMask = 0; // kPhysicsCategory_Unit
        self.bodyNode.physicsBody.friction = 0;
        self.bodyNode.physicsBody.dynamic = NO;
        [self addChild:self.bodyNode];
        
        [self setupRange];
#ifdef kTDBuilding_SHOW_RANGE_BY_DEFAULT
        [self setRangeVisible:YES];
#endif
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitWasKilled:) name:kTDUnitDiedNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bulletWasDestroyed:) name:kTDBulletDestroyedNotificationName object:nil];
	}
	
	return self;
}

- (void) setupRange {
    // setup range node
    self.rangeNode = [[SKShapeNode alloc] init];
    self.rangeNode.position = CGPointMake(0, 0);
    self.rangeNode.fillColor = [UIColor greenColor];
    self.rangeNode.strokeColor = [UIColor clearColor];
    self.rangeNode.zPosition = -1;
    self.rangeNode.alpha = 0.2;
    
    // precalculate the range
    CGRect baseRect = CGRectMake(- self.size.width * 0.5, - self.size.height * 0.5, self.size.width, self.size.height);
    CGRect rangeRect = baseRect;
    rangeRect.origin.x -= self.range;
    rangeRect.origin.y -= self.range;
    rangeRect.size.width += self.range * 2;
    rangeRect.size.height += self.range * 2;
    
    // create the path for the circle
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, rangeRect);
    self.rangeNode.path = path;
    CGPathRelease(path);
    
    // setup physics
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.range / [UIScreen mainScreen].scale];
    self.physicsBody.categoryBitMask = kPhysicsCategory_BuildingRange;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = kPhysicsCategory_Unit;
}

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
    if (self.unitsInRange.count == 0 && self.bulletType == TDBulletType_Beam && self.bullets.count > 0) {
        // destroy this laser bullet!
        [[self.bullets lastObject] destroy];
    }
}

#pragma mark - Range detection

- (BOOL) rangeIsVisibe {
    return (self.rangeNode.parent != nil);
}

- (void) setRangeVisible:(BOOL)visible {
    if (visible && ![self rangeIsVisibe])
        [self addChild:self.rangeNode];
    else if (!visible)
        [self.rangeNode removeFromParent];
}

- (void) updateRangeStatus { // might not keep this until the end
    if (self.unitsInRange.count > 0)
        self.rangeNode.fillColor = [UIColor redColor];
    else
        self.rangeNode.fillColor = [UIColor greenColor];
}

#pragma mark - Attacking targets

//TODO: make this better
- (TDBaseBullet *) nextBullet {
    TDBaseBullet *b = nil;
    
    switch (self.bulletType) {
        case TDBulletType_Beam:
            b = [[TDBeamBullet alloc] init];
            break;
            
        default:
            b = [[TDProjectileBullet alloc] init];
            break;
    }
    
    return b;
}

- (void) addPossibleTarget:(TDUnit *)target {
    [self.unitsInRange addObject:target];
    [self updateRangeStatus];
}

- (void) removePossibleTarget:(TDUnit *)target {
    [self.unitsInRange removeObject:target];
    [self updateRangeStatus];
}

- (void) attackTarget:(TDUnit *)target {
#ifndef kTDBuilding_DISABLE_SHOOTING
    if (target) {
        if (self.bulletType == TDBulletType_Beam) {
            
            TDBeamBullet *bullet = nil;
            if (self.bullets.count == 0) {
                bullet = (TDBeamBullet *)self.nextBullet;
                bullet.position = self.position;
                bullet.anchorPoint = CGPointMake(0, 0.5);
                [self.gameScene addNode:bullet atWorldLayer:TDWorldLayerAboveCharacter];
                [self.bullets addObject:bullet];
            } else {
                bullet = [self.bullets lastObject];
            }
            
            // update the height of the bullet, then the angle
            CGFloat deltaX = target.position.x - self.position.x;
            CGFloat deltaY = target.position.y - self.position.y;
            CGFloat width = sqrtf(deltaX * deltaX + deltaY * deltaY);
            [bullet updateWidth:width];
            bullet.zRotation = atan2f(deltaY, deltaX);
            
        } else if ((!self.lastShotDate || [self.lastShotDate timeIntervalSinceNow] < -self.timeIntervalBetweenShots) && self.bullets.count <= self.maxBulletsOnScreen) {
            self.lastShotDate = [NSDate date];
            
            // shoot
            TDBaseBullet *bullet = self.nextBullet;
            bullet.position = self.position;
            [self.gameScene addNode:bullet atWorldLayer:TDWorldLayerAboveCharacter];
            [self.bullets addObject:bullet];
            
            // we need to move the bullet now! use physics
            [bullet.physicsBody applyImpulse:CGVectorMake((target.position.x - self.position.x) * bullet.speed, (target.position.y - self.position.y) * bullet.speed)];
        }
    }
#endif
}

#pragma mark - Handle other events

- (void) unitWasKilled:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[TDUnit class]]) {
        [self stoppedCollidingWith:[notification.object physicsBody] contact:nil];
    }
}

- (void) bulletWasDestroyed:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[TDBaseBullet class]]) {
        [self.bullets removeObject:notification.object];
    }
}

#pragma mark - Handle collisions

- (void) collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super collidedWith:body contact:contact];
    
    if (body.categoryBitMask == kPhysicsCategory_Unit && [body.node isKindOfClass:[TDUnit class]]) {
        [self addPossibleTarget:(TDUnit *)body.node];
    }
}

- (void) stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super stoppedCollidingWith:body contact:contact];
    
    if ([body.node isKindOfClass:[TDUnit class]]) {
        [self removePossibleTarget:(TDUnit *)body.node];
    }
}

@end
