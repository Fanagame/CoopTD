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
        
        
        // Initialize the camera
        [[TDCamera sharedCamera] setWorld:_world];
        [[TDCamera sharedCamera] setDelegate:self];
        
        // Center the camera on the hero spawn point.
        [[TDCamera sharedCamera] pointCameraToSpawn:self.defaultSpawnPoint];
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

#pragma mark - TDCameraDelegate

- (CGSize) actualMapSizeForCamera:(TDCamera *)camera {
    return CGSizeMake(self.backgroundMap.tiledMap.mapSize.width * self.backgroundMap.tiledMap.tileSize.width, self.backgroundMap.tiledMap.mapSize.height * self.backgroundMap.tiledMap.tileSize.height);
}

- (CGSize) mapSizeForCamera:(TDCamera *)camera {
    return self.backgroundMap.tiledMap.calculateAccumulatedFrame.size;
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
        
        if (!self.targetUnit) {
            self.targetUnit = [spawnPoint.units objectAtIndex:0];
        }
    }
}

- (void)didSimulatePhysics {
    return;
    // Move the world relative to the target unit position.
    if (self.targetUnit) {
        [[TDCamera sharedCamera] pointCameraToPoint:self.targetUnit.position];
        return;
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
        
        [[TDCamera sharedCamera] pointCameraToPoint:worldPos];
    }
}

#pragma mark - Event Handling - iOS

- (void) handlePan:(UIPanGestureRecognizer *)pan {
    // get the translation info
    CGPoint trans = [pan translationInView:pan.view];
    
    // move the camera
    [[TDCamera sharedCamera] moveCameraBy:trans];
    
    // "reset" the translation
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void) handlePinch:(UIPinchGestureRecognizer *)pinch {
    TDCamera *camera = [TDCamera sharedCamera];
    
    static CGFloat startScale = 1;
    if (pinch.state == UIGestureRecognizerStateBegan)
    {
        startScale = camera.cameraZoomLevel;
    }
    CGFloat newScale = startScale * pinch.scale;
    [camera setCameraZoomLevel:newScale];
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
