//
//  TDBuilding.m
//  CoopTD
//
//  Created by Rémy Bardou on 01/11/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBaseBuilding.h"
#import "TDConstants.h"
#import "TDProjectileBullet.h"
#import "TDBeamBullet.h"
#import "TDFreezeBeamBullet.h"
#import "TDBaseBuildingAI.h"
#import "TDProgressBar.h"

NSString * const kConstructingBuildingImageName = @"tower_unconstructed";

@interface TDBaseBuilding ()

@property (nonatomic, strong) SKShapeNode *rangeNode;
@property (nonatomic, strong) SKShapeNode *bodyNode;

@end

@implementation TDBaseBuilding

- (id) initWithObjectID:(NSInteger)objectID {
    return [self init];
}

- (id) init {
    return [self initWithAttackableUnitsType:TDUnitType_Ground andBaseCacheKey:@"tower_ground_1"];
}

- (id) initWithAttackableUnitsType:(TDUnitType)attackableUnitsType {
    NSString *baseCacheKey = (attackableUnitsType == TDUnitType_Ground ? @"tower_ground_1" : @"tower_air_1");
    return [self initWithAttackableUnitsType:attackableUnitsType andBaseCacheKey:baseCacheKey];
}

- (id) initWithAttackableUnitsType:(TDUnitType)attackableUnitsType andBaseCacheKey:(NSString *)baseCacheKey {
	self = [super initWithImageNamed:kConstructingBuildingImageName];
    
	if (self) {
        self.unitsInRange = [[NSMutableArray alloc] init];
        self.bullets = [[NSMutableArray alloc] init];
        self.intelligence = [[TDBaseBuildingAI alloc] initWithCharacter:self andTarget:nil];
        
        //TODO: init this from database or something else
        self.baseCacheKey = baseCacheKey;
        self.health = 200;
        self.maxHealth = 200;
        self.softCurrencyPrice = 200;
        self.timeIntervalBetweenShots = 0.2;
        self.timeToBuild = 0.7;
        self.attackableUnitType = attackableUnitsType;
        self.bulletType = (self.attackableUnitType == TDUnitType_Air ? TDBulletType_Beam : TDBulletType_Projectile);
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
//        self.bodyNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width * 0.5 / (1 / 2 * [UIScreen mainScreen].scale), self.size.height * 0.5 * (1 / 2 * [UIScreen mainScreen].scale))];
        self.bodyNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.bodyNode.frame.size.width * 0.5, self.bodyNode.frame.size.height * 0.5)];
        self.bodyNode.physicsBody.categoryBitMask = kPhysicsCategory_Building;
        self.bodyNode.physicsBody.collisionBitMask = 0; // kPhysicsCategory_Unit
        self.bodyNode.physicsBody.friction = 0;
        self.bodyNode.physicsBody.dynamic = NO;
        [self addChild:self.bodyNode];
        
        [self setupRange];
        self.isPlaced = NO; // sets up range visible and all that shit
#ifdef kTDBuilding_SHOW_RANGE_BY_DEFAULT
        [self setRangeVisible:YES];
#endif
        
        // add health bar
        self.healthBar = [[TDProgressBar alloc] initWithTotalTicks:self.maxHealth fillColor:[UIColor greenColor] aboveSprite:self];
#ifndef kTDBuilding_ALWAYS_SHOW_HEALTH
        self.healthBar.hideWhenFull = YES;
#endif
        [self addChild:self.healthBar];
        
        // add construction bar
        self.constructionBar = [[TDProgressBar alloc] initWithTotalTicks:100 fillColor:[UIColor cyanColor] aboveSprite:self];
        self.constructionBar.currentTick = 0;
        [self addChild:self.constructionBar];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitWasKilled:) name:kTDUnitDiedNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bulletWasDestroyed:) name:kTDBulletDestroyedNotificationName object:nil];
	}
	
	return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.physicsBody.contactTestBitMask = [TDUnit physicsCategoryForUnitWithType:self.attackableUnitType];
}

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
    if (!self.isConstructed && self.isPlaced) {
        if (-[self.dateConstructionStarted timeIntervalSinceNow] >= self.timeToBuild) {
            self.isConstructed = YES;
        } else {
            [self updateConstructProgressBar];
        }
    }
    
    if (self.unitsInRange.count == 0 && self.bulletType == TDBulletType_Beam && self.bullets.count > 0) {
        // destroy this laser bullet!
        [[self.bullets lastObject] destroy];
    }
}

- (void) updateConstructProgressBar {
    double timeSpent = -[self.dateConstructionStarted timeIntervalSinceNow];
    double totalTime = self.timeToBuild;
    double ticks = ceil(timeSpent / totalTime * 100);
    self.constructionBar.currentTick = ticks;
}

- (void) setIsConstructed:(BOOL)isConstructed {
    _isConstructed = isConstructed;
    
    if (isConstructed) {
        self.texture = [SKTexture textureWithImageNamed:self.baseCacheKey];
        [self.constructionBar removeFromParent];
    } else {
        self.texture = [SKTexture textureWithImageNamed:kConstructingBuildingImageName];
        
        if (!self.constructionBar.parent)
            [self addChild:self.constructionBar];
    }
}

- (void) setIsPlaced:(BOOL)isPlaced {
    _isPlaced = isPlaced;
    
    // Change some visual things
    
    // Not placed? Grey out the building, but show the actual building image
    if (!_isPlaced) {
        self.texture = [SKTexture textureWithImageNamed:self.baseCacheKey];
		
        // add some kind of effect
		self.color = [UIColor grayColor];
		self.colorBlendFactor = 1;
        
        [self setRangeVisible:YES];
    } else  {
        // We just placed it!
		
		self.color = nil;
		self.colorBlendFactor = 0;
	    
        // If it wasn't already constructed (maybe we just moved it afterwards), start constructing it!
        if (!self.isConstructed) {
            self.dateConstructionStarted = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        }
        
        self.isConstructed = self.isConstructed; // might look silly, but this just refreshes the right sprite
        [self setRangeVisible:NO];
    }
}

#pragma mark - Health

- (void) setHealth:(NSUInteger)health {
    _health = health;
    
    self.healthBar.currentTick = health;
    
    if (_health == 0)
        [self die];
}

// do we really need this?
- (void) increaseHealth:(NSUInteger)amount {
    amount = MIN(amount, self.maxHealth - self.health);
    self.health += amount;
}

// do we really need this?
- (void) decreaseHealth:(NSUInteger)amount {
    amount = MIN(self.health, amount);
    self.health -= amount;
}

- (void) setMaxHealth:(NSUInteger)maxHealth {
    _maxHealth = maxHealth;
    
    self.healthBar.totalTicks = maxHealth;
}

#pragma mark - Actions

- (void) die {
    // destroy the building
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

- (void) showRangeStatusWihtConstructableColor:(BOOL)isConstructable {
    if (!isConstructable)
        self.rangeNode.fillColor = [UIColor redColor];
    else
        self.rangeNode.fillColor = [UIColor greenColor];
}

#pragma mark - Attacking targets

//TODO: make this better
- (TDBaseBullet *) nextBullet {
    TDBaseBullet *b = nil;
    
    switch (self.bulletType) {
        case TDBulletType_Beam: {
#ifdef kTDBullet_BEAM_IS_FREEZERAY
            b = [[TDFreezeBeamBullet alloc] init];
#else
			b = [[TDBeamBullet alloc] init];
#endif
            break;
		}
        default:
            b = [[TDProjectileBullet alloc] init];
            break;
    }
    
    b.attackableUnitsType = self.attackableUnitType;
    
    return b;
}

- (void) addPossibleTarget:(TDUnit *)target {
    [self.unitsInRange addObject:target];
}

- (void) removePossibleTarget:(TDUnit *)target {
    [self.unitsInRange removeObject:target];
}

- (void) attackTarget:(TDUnit *)target {
#ifndef kTDBuilding_DISABLE_SHOOTING
    if (target && self.isConstructed) {
        if (self.bulletType == TDBulletType_Beam) {
            
            TDBeamBullet *bullet = nil;
            if (self.bullets.count == 0) {
                bullet = (TDBeamBullet *)self.nextBullet;
                bullet.position = self.position;
                bullet.anchorPoint = CGPointMake(0, 0.5);
                [self.gameScene addNode:bullet atWorldLayer:TDWorldLayerAboveCharacter];
                [self.bullets addObject:bullet];
                [bullet startAnimation];
            } else {
                bullet = [self.bullets lastObject];
            }
            
            [bullet attackTarget:target fromObject:self];
        } else if ((!self.lastShotDate || [self.lastShotDate timeIntervalSinceNow] < -self.timeIntervalBetweenShots) && self.bullets.count <= self.maxBulletsOnScreen) {
            self.lastShotDate = [NSDate date];
            
            // shoot
            TDBaseBullet *bullet = self.nextBullet;
            [self.gameScene addNode:bullet atWorldLayer:TDWorldLayerAboveCharacter];
            [self.bullets addObject:bullet];
            [bullet attackTarget:target fromObject:self];
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
    if (body.categoryBitMask == [TDUnit physicsCategoryForUnitWithType:self.attackableUnitType] && [body.node isKindOfClass:[TDUnit class]]) {
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
