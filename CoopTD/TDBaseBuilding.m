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
#import "TDArrowBullet.h"
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
        self.range = 100.0f;
        self.softCurrencyPrice = 200;
        self.timeIntervalBetweenShots = 0.2;
        self.maxBulletsOnScreen = 3;
        
        self.bodyNode = [[SKShapeNode alloc] init];
        self.bodyNode.path = CGPathCreateWithRect(self.frame, NULL);
#ifdef kTDBuilding_SHOW_PHYSICS_BODY
        self.bodyNode.fillColor = [UIColor redColor];
#else
        self.bodyNode.strokeColor = [UIColor clearColor];
#endif
        self.bodyNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.bodyNode.physicsBody.categoryBitMask = kPhysicsCategory_Building;
        self.bodyNode.physicsBody.collisionBitMask = kPhysicsCategory_Unit;
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
    if (target && (!self.lastShotDate || [self.lastShotDate timeIntervalSinceNow] < -self.timeIntervalBetweenShots) && self.bullets.count <= self.maxBulletsOnScreen) {
        self.lastShotDate = [NSDate date];
        
        // shoot
        TDArrowBullet *arrow = [[TDArrowBullet alloc] init];
        arrow.position = self.position;
        [self.gameScene addNode:arrow atWorldLayer:TDWorldLayerAboveCharacter];
        [self.bullets addObject:arrow];
        
        // we need to move the bullet now! use physics
        [arrow.physicsBody applyImpulse:CGVectorMake((target.position.x - self.position.x) * arrow.speed, (target.position.y - self.position.y) * arrow.speed)];
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
    
    if ([body.node isKindOfClass:[TDUnit class]]) {
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
