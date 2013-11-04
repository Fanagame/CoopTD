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
#import "TDUltimateGoal.h"
#import "TDTiledMap.h"
#import "TDMapCache.h"
#import "SKButton.h"
#import "TDPathFinder.h"
#import "TDGridNode.h"
#import "TDBuilding.h"
#import "TDHudNode.h"
#import "TDPlayer.h"
#import "TDConstants.h"

@implementation TDNewGameScene

- (id) initWithSize:(CGSize)size andMapName:(NSString *)mapName {
    self = [super initWithSize:size];
    
    if (self) {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.mapName = mapName;
		
        // initialize the main layers
        _world = [[SKNode alloc] init];
        _world.name = @"world";
        _layers = [NSMutableArray arrayWithCapacity:kWorldLayerCount];
        for (int i = 0; i < kWorldLayerCount; i++) {
			SKNode *layer = nil;
			
			if (i == TDWorldLayerGrid) {
				_grid = [[TDGridNode alloc] init];
				layer = _grid;
			} else {
				layer = [[SKNode alloc] init];
			}
            layer.zPosition = i - kWorldLayerCount;
            [_world addChild:layer];
            [(NSMutableArray *)_layers addObject:layer];
        }
        
        [self addChild:_world];
        
        // Initialize player
        [[TDPlayer localPlayer] setSoftCurrency:2000];
        [[TDPlayer localPlayer] setDisplayName:@"Remy"];
        [[TDPlayer localPlayer] setRemainingLives:2];
        
        
        // Initialize the world + hud
        [self buildWorld];
		[self buildGrid];
        [self buildHUD];
        
        // Initialize the camera
        [[TDCamera sharedCamera] setWorld:_world];
        [[TDCamera sharedCamera] setDelegate:self];
        
        // Center the camera on the hero spawn point.
        [[TDCamera sharedCamera] setCameraToDefaultZoomLevel];
        [[TDCamera sharedCamera] pointCameraToSpawn:self.defaultSpawnPoint];
        
        // Register to important notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLivesReachedZero:) name:kLocalPlayerLivesReachedZeroNotificationName object:nil];
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
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapRecognizer];
}

#pragma mark - World building

- (void) buildWorld {
    // Configure physics for the world.
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f); // no gravity
    self.physicsWorld.contactDelegate = self;
    
    [self addBackgroundTiles];
    [self addSpawnPoints];
    [self addGoalPoints];
    [self addBuildings];
}

- (void)addBackgroundTiles {
    self.backgroundMap = [[TDMapCache sharedCache] cachedMapForMapName:self.mapName];
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

- (void) addBuildings {
    self.buildings = [[NSMutableArray alloc] init];
}

#pragma mark - Building helpers

//TODO: maybe we should handle that somewhere else
- (void) addBuildingAtTileCoordinates:(CGPoint)tileCoordinates {
    if ([self isConstructable:tileCoordinates]) {
        CGPoint position = [self tilePositionInMapForCoordinate:tileCoordinates];
        
        TDBuilding *b = [[TDBuilding alloc] init];
        //    b.anchorPoint = CGPointMake(0, 0);
        b.position = position;
        [self addNode:b atWorldLayer:TDWorldLayerBuilding];
        [self.buildings addObject:b];
        
        [[TDPlayer localPlayer] subtractSoftCurrency:b.softCurrencyPrice];
    }
}

#pragma mark - Create grid

- (void) buildGrid {
	[self.grid buildGrid];
}

#pragma mark - HUD and Scores

- (void) buildHUD {
    _hud = [[TDHudNode alloc] init];
    [self addChild:_hud];
    [_hud didMoveToScene];
}

#pragma mark - TDCameraDelegate

- (CGSize) actualMapSizeForCamera:(TDCamera *)camera {
    return CGSizeMake(self.backgroundMap.tiledMap.mapSize.width * self.backgroundMap.tiledMap.tileSize.width, self.backgroundMap.tiledMap.mapSize.height * self.backgroundMap.tiledMap.tileSize.height);
}

- (CGSize) mapSizeForCamera:(TDCamera *)camera {
    return self.backgroundMap.tiledMap.calculateAccumulatedFrame.size;
}

#pragma mark - Position conversion

- (CGPoint) tileCoordinatesForPositionInMap:(CGPoint)position {
    return [self.backgroundMap tileCoordinatesForPosition:position];
}

- (CGPoint) tilePositionInMapForCoordinate:(CGPoint)position {
    return [self.backgroundMap tilePositionForCoordinate:position];
}

- (CGPoint) convertPointFromViewToMapPosition:(CGPoint)point {
    point = [self convertPointFromView:point];
    point = [self convertPoint:point toNode:self.world];
    return point;
}

- (void) convertCoordinatesArrayToPositionsInMapArray:(NSArray *)coords {
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
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

- (void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLast {
    // Game logic
    for (TDSpawn *spawnPoint in self.spawnPoints) {
        [spawnPoint updateWithTimeSinceLastUpdate:timeSinceLast];
        
//#if DEBUG
//        if (!self.targetUnit && spawnPoint.units.count > 0) {
//            self.targetUnit = [spawnPoint.units objectAtIndex:0];
//        }
//#endif
    }
    
    for (TDUltimateGoal *goal in self.goalPoints) {
        [goal updateWithTimeSinceLastUpdate:timeSinceLast];
    }
}

- (void)didSimulatePhysics {
	[super didSimulatePhysics];
	
    [[TDCamera sharedCamera] updateCameraTracking];
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

- (void) handleTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint position = [tap locationInView:tap.view];
        position = [self convertPointFromViewToMapPosition:position];

        CGPoint coord = [self tileCoordinatesForPositionInMap:position];
        [self addBuildingAtTileCoordinates:coord];
    }
}

#pragma mark - Notifications handling

- (void) playerLivesReachedZero:(NSNotification *)notification {
    if (notification.object == [TDPlayer localPlayer]) {
        self.currentMode = TDWorldModeGameOver;
    }
}

#pragma mark - Explorable world delegate

- (BOOL)isConstructable:(CGPoint)coordinates {
    BOOL ok = YES;
    
    // Is the terrain constructable?
    if (self.backgroundMap.mainLayer.layerInfo) {
        TMXLayerInfo *layerInfo = self.backgroundMap.mainLayer.layerInfo;
        
        NSInteger gid = [layerInfo tileGidAtCoord:coordinates];
        NSDictionary *props = [self.backgroundMap.tiledMap propertiesForGid:gid];
        
        if (props) {
            if ([props[@"Constructable"] isEqualToString:@"YES"]) {
                ok = YES;
            } else if (props[@"Constructable"]) {
                ok = NO;
            }
        }
    }
    
    // if it is, then do we already have a construction here?
    if (ok) {
        for (TDBuilding *b in self.buildings) {
            CGPoint coord = [self tileCoordinatesForPositionInMap:b.position];
            
            if (CGPointEqualToPoint(coord, coordinates)) {
                ok = NO;
                break;
            }
        }
    }
    
    return ok;
}

- (BOOL)isWalkable:(CGPoint)coordinates {
    if (self.backgroundMap.mainLayer.layerInfo) {
        TMXLayerInfo *layerInfo = self.backgroundMap.mainLayer.layerInfo;
        
        NSInteger gid = [layerInfo tileGidAtCoord:coordinates];
        NSDictionary *props = [self.backgroundMap.tiledMap propertiesForGid:gid];
        
        if (props) {
            if ([props[@"Walkable"] isEqualToString:@"YES"]) {
                return YES;
            } else if (props[@"Walkable"]) {
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
    if ([contact.bodyA.node isKindOfClass:[TDMapObject class]]) {
        TDMapObject *objA = (TDMapObject *)contact.bodyA.node;
        [objA collidedWith:contact.bodyB contact:contact];
    }
    
    if ([contact.bodyB.node isKindOfClass:[TDMapObject class]]) {
        TDMapObject *objB = (TDMapObject *)contact.bodyB.node;
        [objB collidedWith:contact.bodyA contact:contact];
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    if ([contact.bodyA.node isKindOfClass:[TDMapObject class]]) {
        TDMapObject *objA = (TDMapObject *)contact.bodyA.node;
        [objA stoppedCollidingWith:contact.bodyB contact:contact];
    }
    
    if ([contact.bodyB.node isKindOfClass:[TDMapObject class]]) {
        TDMapObject *objB = (TDMapObject *)contact.bodyB.node;
        [objB stoppedCollidingWith:contact.bodyA contact:contact];
    }
}

#pragma mark - Shared Assets

+ (void)loadSceneAssetsForMapName:(NSString *)mapName withCompletionHandler:(TDAssetLoadCompletionHandler)handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Load the shared assets in the background.
        [self.class loadSceneAssetsForMapName:mapName];
        
        if (!handler) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Call the completion handler back on the main queue.
            handler();
        });
    });
}

+ (void)loadSceneAssetsForMapName:(NSString *)mapName {
    // Preload the map
    [[TDMapCache sharedCache] preloadMapNamed:mapName];
    
    //TODO: Pre-calculate the pathfinding from spawn point
    
    //TODO: load monsters assets
}

+ (void)releaseSceneAssetsForMapName:(NSString *)mapName {
	[[TDMapCache sharedCache] invalidateCacheForMapNamed:mapName];
}

@end
