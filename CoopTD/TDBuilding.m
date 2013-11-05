//
//  TDBuilding.m
//  CoopTD
//
//  Created by Rémy Bardou on 01/11/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBuilding.h"
#import "TDUnit.h"
#import "TDConstants.h"

@interface TDBuilding ()

@property (nonatomic, strong) SKShapeNode *rangeNode;
@property (nonatomic, strong) NSMutableArray *activeTargets;

@end

@implementation TDBuilding

- (id) init {
	self = [super initWithImageNamed:@"Tower-Single-Sprite"];
    
	if (self) {
        self.activeTargets = [[NSMutableArray alloc] init];
        self.range = 100.0f;
        self.softCurrencyPrice = 200;
        
        [self initRangeNode];
        
        [self setRangeVisible:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitWasKilled:) name:kTDUnitDiedNotificationName object:nil];
	}
	
	return self;
}

- (void) initRangeNode {
    // setup range node
    self.rangeNode = [[SKShapeNode alloc] init];
    self.rangeNode.position = CGPointMake(0, 0);
    self.rangeNode.fillColor = [UIColor greenColor];
    self.rangeNode.strokeColor = [UIColor clearColor];
    self.rangeNode.zPosition = -1;
    self.rangeNode.alpha = 0.2;
    self.rangeNode.hidden = YES;
    [self addChild:self.rangeNode];
    
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
    return self.rangeNode.hidden;
}

- (void) setRangeVisible:(BOOL)visible {
    self.rangeNode.hidden = !visible;
}

#pragma mark - Attacking targets

- (void) addTarget:(TDUnit *)target {
    __weak TDUnit *weakTarget = target;
    [self.activeTargets addObject:weakTarget];
    
    [self updateRangeStatus];
}

- (void) removeTarget:(TDUnit *)target {
    [self.activeTargets removeObject:target];
    
    [self updateRangeStatus];
}

- (void) updateRangeStatus {
    if (self.activeTargets.count > 0)
        self.rangeNode.fillColor = [UIColor redColor];
    else
        self.rangeNode.fillColor = [UIColor greenColor];
}

- (TDUnit *) activeTarget {
    if (self.activeTargets.count > 0) {
        return [self.activeTargets lastObject];
    }
    
    return nil;
}

// should be called by AI
- (void) attackTargets {
//    if (self.activeTargets > 0) {
//        // attack the latest target only
//        TDUnit *target = [self activeTarget];
//        
//        // attack with a bullet?
//    }
}

#pragma mark - Handle other events

- (void) unitWasKilled:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[TDUnit class]]) {
        [self stoppedCollidingWith:[notification.object physicsBody] contact:nil];
    }
}

#pragma mark - Handle collisions

- (void) collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super collidedWith:body contact:contact];
    
    if ([body.node isKindOfClass:[TDUnit class]]) {
        [self addTarget:(TDUnit *)body.node];
    }
}

- (void) stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super stoppedCollidingWith:body contact:contact];
    
    if ([body.node isKindOfClass:[TDUnit class]]) {
        [self removeTarget:(TDUnit *)body.node];
    }
}

@end
