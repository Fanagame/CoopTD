//
//  TDNewGameScene.m
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDNewGameScene.h"
#import "TDUnit.h"
#import "TDSpawn.h"
#import "TDTiledMap.h"
#import "TDMapCache.h"

NSString * const kGameSceneMapName = @"Demo";

@implementation TDNewGameScene

- (id) initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        
        // initialize the main layers
        _world = [[SKNode alloc] init];
        [_world setName:@"world"];
        _layers = [NSMutableArray arrayWithCapacity:kWorldLayerCount];
        for (int i = 0; i < kWorldLayerCount; i++) {
            SKNode *layer = [[SKNode alloc] init];
            layer.zPosition = i - kWorldLayerCount;
            [_world addChild:layer];
            [(NSMutableArray *)_layers addObject:layer];
        }
        
        [self addChild:_world];
        
        [self buildHUD];
        [self buildWorld];
        
        
        // Center the camera on the hero spawn point.
        CGPoint startPosition = self.defaultSpawnPoint.position;
        [self centerWorldOnPosition:startPosition];
    }
    
    return self;
}

- (void)addNode:(SKNode *)node atWorldLayer:(TDWorldLayer)layer {
    SKNode *layerNode = self.layers[layer];
    [layerNode addChild:node];
}

- (void)didMoveToView:(SKView *)view {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchRecognizer];
}

#pragma mark - World building

- (void) buildWorld {
    // Configure physics for the world.
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f); // no gravity
    self.physicsWorld.contactDelegate = self;
    
    [self addBackgroundTiles];
    [self addSpawnPoints];
    [self addGoalPoints];
}

- (void)addBackgroundTiles {
    self.backgroundMap = [[TDMapCache sharedCache] cachedMapForMapName:kGameSceneMapName];
    [self addNode:self.backgroundMap atWorldLayer:TDWorldLayerGround];
}

- (void)addSpawnPoints {
    self.spawnPoints = self.backgroundMap.spawnPoints;
    
    if (self.spawnPoints.count > 0) {
        self.defaultSpawnPoint = self.spawnPoints[0];
    }
}

- (void)addGoalPoints {
    self.goalPoints = self.backgroundMap.goalPoints;
    
    if (self.goalPoints.count > 0) {
        self.defaultGoalPoint = self.goalPoints[0];
    }
}

#pragma mark - HUD and Scores

- (void) buildHUD {
    
}

#pragma mark - Mapping
- (void)centerWorldOnPosition:(CGPoint)position {
    position = CGPointMake(-(position.x) + CGRectGetMidX(self.frame),
                           -(position.y) + CGRectGetMidY(self.frame));
    
    [self pointCameraToPoint:position];
    
//    self.worldMovedForUpdate = YES;
}

- (void)centerWorldOnSpriteNode:(SKSpriteNode *)character {
    [self centerWorldOnPosition:character.position];
}

- (void) pointCameraToPoint:(CGPoint)position {
    self.world.position = [self boundedLayerPosition:position];
}

- (void) pointCameraToSpawn:(TDSpawn *)spawn {
    [self pointCameraToPoint:spawn.position];
}

- (void) pointCameraToUnit:(TDUnit *)unit {
    //TODO: make it follow the unit at the same time?
//    [self zoomOnObjectWithRect:unit.frame withDesiredSpaceOccupation:0.2]; // 20%
    //[self pointCameraToPoint:unit.spriteNode.position];
}

- (void) pointCameraToBuilding:(id)building {
    
}

- (void) pointCameraToDefaultElement {
    TDSpawn *spawn = self.defaultSpawnPoint;
    
    if (spawn)
        [self pointCameraToSpawn:spawn];
}

//TODO: cache the value for best performance?
- (CGFloat) bestScaleForDevice {
    CGSize winSize = self.size;
    CGSize actualMapSize = CGSizeMake(self.backgroundMap.tiledMap.mapSize.width * self.backgroundMap.tiledMap.tileSize.width, self.backgroundMap.tiledMap.mapSize.height * self.backgroundMap.tiledMap.tileSize.height);
    
    CGFloat bestXScale = winSize.width / actualMapSize.width;
    CGFloat bestYScale = winSize.height / actualMapSize.height;
    
    return MAX(bestXScale, bestYScale);
}

- (CGPoint) boundedLayerPosition:(CGPoint)newPos {
    CGSize winSize = self.size;
    CGSize mapSize = self.backgroundMap.tiledMap.calculateAccumulatedFrame.size;
    
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -mapSize.width + winSize.width);
    retval.y = MIN(retval.y, 0);
    retval.y = MAX(retval.y, -mapSize.height + winSize.height);
    
    return retval;
}

#pragma mark - Position conversion

- (CGPoint) tileCoordinatesForPosition:(CGPoint)position {
    return [self.backgroundMap tileCoordinatesForPosition:position];
}

- (CGPoint) tilePositionForCoordinate:(CGPoint)position {
    return [self.backgroundMap tilePositionForCoordinate:position];
}

- (void) convertCoordinatesArrayToPositionsArray:(NSArray *)coords {
    [self.backgroundMap convertCoordinatesArrayToPositionsArray:coords];
}

#pragma mark - Loop Update
- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = kMinTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
//        self.worldMovedForUpdate = YES;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

- (void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLast {
    // Game logic
    for (TDSpawn *spawnPoint in self.spawnPoints) {
        [spawnPoint updateWithTimeSinceLastUpdate:timeSinceLast];
    }
}

- (void)didSimulatePhysics {
    
    // Move the world relative to the target unit position.
    if (self.targetUnit) {
        CGPoint heroPosition = self.targetUnit.position;
        CGPoint worldPos = self.world.position;
        CGFloat yCoordinate = worldPos.y + heroPosition.y;
        if (yCoordinate < kMinHeroToEdgeDistance) {
            worldPos.y = worldPos.y - yCoordinate + kMinHeroToEdgeDistance;
//            self.worldMovedForUpdate = YES;
        } else if (yCoordinate > (self.frame.size.height - kMinHeroToEdgeDistance)) {
            worldPos.y = worldPos.y + (self.frame.size.height - yCoordinate) - kMinHeroToEdgeDistance;
//            self.worldMovedForUpdate = YES;
        }
        
        CGFloat xCoordinate = worldPos.x + heroPosition.x;
        if (xCoordinate < kMinHeroToEdgeDistance) {
            worldPos.x = worldPos.x - xCoordinate + kMinHeroToEdgeDistance;
//            self.worldMovedForUpdate = YES;
        } else if (xCoordinate > (self.frame.size.width - kMinHeroToEdgeDistance)) {
            worldPos.x = worldPos.x + (self.frame.size.width - xCoordinate) - kMinHeroToEdgeDistance;
//            self.worldMovedForUpdate = YES;
        }
        self.world.position = worldPos;
    }
}

#pragma mark - Event Handling - iOS

- (void) handlePan:(UIPanGestureRecognizer *)pan {
    // get the translation info
    CGPoint trans = [pan translationInView:pan.view];
    
    // calculate the new map position
    CGPoint pos = self.world.position;
    CGPoint newPos = CGPointMake(pos.x + trans.x, pos.y - trans.y);
    [self pointCameraToPoint:newPos];
    
    // "reset" the translation
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void) handlePinch:(UIPinchGestureRecognizer *)pinch {
    static CGFloat startScale = 1;
    if (pinch.state == UIGestureRecognizerStateBegan)
    {
        //        startScale = self.world.cameraZoomLevel;
        startScale = self.world.xScale;
    }
    CGFloat newScale = startScale * pinch.scale;
    //    self.world.cameraZoomLevel = newScale;
    [self.world setScale:newScale];
}

#pragma mark - Explorable world delegate

- (BOOL)isWalkable:(CGPoint)coordinates {
    if (self.backgroundMap.mainLayer.layerInfo) {
        TMXLayerInfo *layerInfo = self.backgroundMap.mainLayer.layerInfo;
        
        NSInteger gid = [layerInfo tileGidAtCoord:coordinates];
        NSDictionary *props = [self.backgroundMap.tiledMap propertiesForGid:gid];
        
        if (props) {
            if ([props[@"Walkable"] isEqualToString:@"YES"]) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSUInteger)weightForTileAtPosition:(CGPoint)position {
    return 1;
}

#pragma mark - Physics Delegate
- (void)didBeginContact:(SKPhysicsContact *)contact {
    //TODO: handle collisions here
}

#pragma mark - Shared Assets

+ (void)loadSceneAssetsWithCompletionHandler:(TDAssetLoadCompletionHandler)handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Load the shared assets in the background.
        [self loadSceneAssets];
        
        if (!handler) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Call the completion handler back on the main queue.
            handler();
        });
    });
}

+ (void)loadSceneAssets {
    [[TDMapCache sharedCache] preloadMapNamed:kGameSceneMapName];
    
    //TODO: load monsters assets
}

+ (void)releaseSceneAssets {
    
}

@end
