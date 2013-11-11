//
//  TDMapObject.h
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "TDNewGameScene.h"

@class TDArtificialIntelligence;

@interface TDMapObject : SKSpriteNode

@property (nonatomic, assign) NSInteger objectID;
@property (nonatomic, assign) NSInteger uniqueID;
@property (nonatomic, strong) NSString *baseCacheKey;
@property (nonatomic, strong) TDArtificialIntelligence *intelligence;

- (id) initWithObjectID:(NSInteger)objectID;

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval;
- (TDNewGameScene *)gameScene;
- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact;
- (void)stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact;

@end
