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
#import "TDPathFinder.h"
#import "TDGridNode.h"
#import "TDBaseBuilding.h"
#import "TDHudNode.h"
#import "TDPlayer.h"
#import "TDConstants.h"

@interface TDNewGameScene () {
    CGSize _cachedMapSizeForCamera;
    CGSize _cachedActualMapSize;
}

@end

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
        [[TDPlayer localPlayer] setRemainingLives:200];
        
        
        // Initialize the world + hud
        [self buildWorld];
		[self buildGrid];
//        [self buildHUD];
        
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

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNode:(SKNode *)node atWorldLayer:(TDWorldLayer)layer {
    SKNode *layerNode = self.layers[layer];
    [layerNode addChild:node];
}

- (void)didMoveToView:(SKView *)view {
    [self buildHUD];
    
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

    self.world.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.world.calculateAccumulatedFrame];
    self.world.physicsBody.categoryBitMask = kPhysicsCategory_World;
    self.world.physicsBody.collisionBitMask = 0; // collide with nothing
    self.world.physicsBody.contactTestBitMask = kPhysicsCategory_Bullet; // maybe we should add the units, but it adds to the cpu load
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
        
        TDBaseBuilding *b = [[TDBaseBuilding alloc] init];
        //    b.anchorPoint = CGPointMake(0, 0);
        b.position = position;
        [self addNode:b atWorldLayer:TDWorldLayerBuilding];
        [self.buildings addObject:b];
        
        [[TDPlayer localPlayer] subtractSoftCurrency:b.softCurrencyPrice];
        
//        // is the building part of any cached path?
        for (TDPath *path in [[TDPathFinder sharedPathCache] cachedPaths]) {
            if ([path containsCoordinates:tileCoordinates]) {
                [path invalidate]; // then invalidate it!
            }
        }
    }
}

#pragma mark - Create grid

- (void) buildGrid {
#ifdef kTDGameScene_SHOW_GRID
	[self.grid buildGridWithTileSize:self.backgroundMap.tiledMap.tileSize];
#endif
}

#pragma mark - HUD and Scores

- (void) buildHUD {
    _hud = [[TDHudNode alloc] init];
    [self addChild:_hud];
    [_hud didMoveToScene];
}

#pragma mark - TDCameraDelegate

- (CGSize) actualMapSizeForCamera:(TDCamera *)camera {
    if (CGSizeEqualToSize(_cachedActualMapSize, CGSizeZero)) {
        _cachedActualMapSize = CGSizeMake(self.backgroundMap.tiledMap.mapSize.width * self.backgroundMap.tiledMap.tileSize.width, self.backgroundMap.tiledMap.mapSize.height * self.backgroundMap.tiledMap.tileSize.height);
    }
    
    return _cachedActualMapSize;
}

- (CGSize) mapSizeForCamera:(TDCamera *)camera {
    if (CGSizeEqualToSize(_cachedMapSizeForCamera, CGSizeZero)) {
        _cachedMapSizeForCamera = self.backgroundMap.tiledMap.calculateAccumulatedFrame.size;
    }
    return _cachedMapSizeForCamera;
}

#pragma mark - Position conversion

- (TDMapObject *) mapObjectAtPositionInMap:(CGPoint)position {
    position = [self convertPoint:position fromNode:self.world];
    
    __block TDMapObject *object = nil;
    
    [self.physicsWorld enumerateBodiesAtPoint:position usingBlock:^(SKPhysicsBody *body, BOOL *stop) {
        if (body.categoryBitMask != kPhysicsCategory_BuildingRange && body.categoryBitMask != kPhysicsCategory_Bullet) {
            if ([body.node isKindOfClass:[TDMapObject class]]) {
                object = (TDMapObject *)body.node;
            } else if ([body.node.parent isKindOfClass:[TDMapObject class]]) {
                object = (TDMapObject *)body.node.parent;
            }
        }
    }];
    
    return object;
}

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
    }
    
    for (TDUltimateGoal *goal in self.goalPoints) {
        [goal updateWithTimeSinceLastUpdate:timeSinceLast];
    }
    
    for (TDBaseBuilding *building in self.buildings) {
        [building updateWithTimeSinceLastUpdate:timeSinceLast];
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

        TDMapObject *tappedItem = [self mapObjectAtPositionInMap:position];
        
        if ([tappedItem isKindOfClass:[TDBaseBuilding class]]) {
            // Show popup?
            NSLog(@"you tapped on a building");
        } else if ([tappedItem isKindOfClass:[TDUnit class]]) {
            // Tell towers to attack this unit?
            NSLog(@"You tapped on unit #%ld", (long)((TDUnit *)tappedItem).uniqueID);
        } else if (!tappedItem) { // if we just tapped on the world
            // Offer to place a building here!
            CGPoint coord = [self tileCoordinatesForPositionInMap:position];
            [self addBuildingAtTileCoordinates:coord];
        }
    }
}

#pragma mark - Notifications handling

//TODO: handle player lives = 0 correctly
- (void) playerLivesReachedZero:(NSNotification *)notification {
    if (notification.object == [TDPlayer localPlayer]) {
        self.currentMode = TDWorldModeGameOver;
    }
}

#pragma mark - Explorable world delegate

- (BOOL)isConstructable:(CGPoint)coordinates {
    __block BOOL ok = YES;
    
#ifndef kTDGameScene_DISABLE_CONSTRUCTABLE_CHECK
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
    
//    if (ok) {
//        CGPoint position = [self tilePositionInMapForCoordinate:coordinates];
//        position = [self convertPoint:position fromNode:self.world];
//        CGSize size = CGSizeMake(self.backgroundMap.tiledMap.tileSize.width, self.backgroundMap.tiledMap.tileSize.height);
//        CGRect rect = CGRectMake(position.x, position.y, size.width, size.height);
//        [self.physicsWorld enumerateBodiesInRect:rect usingBlock:^(SKPhysicsBody *body, BOOL *stop) {
//            if (body.categoryBitMask == kPhysicsCategory_Building || body.categoryBitMask == kPhysicsCategory_Unit || body.categoryBitMask == kPhysicsCategory_UltimateGoal) {
//                ok = NO;
//                *stop = YES;
//            } else {
//                NSLog(@"%@", body.node.class);
//            }
//        }];
//    }
    // if it is, then do we already have a construction here?
    if (ok) {
        for (TDBaseBuilding *b in self.buildings) {
            CGPoint coord = [self tileCoordinatesForPositionInMap:b.position];
            
            if (CGPointEqualToPoint(coord, coordinates)) {
                ok = NO;
                break;
            }
        }
    }
    
    // or do we have an enemy/spawn there?
    if (ok) {
        for (TDSpawn *spawn in self.spawnPoints) {
            CGPoint coord = [self tileCoordinatesForPositionInMap:spawn.position];
            
            if (CGPointEqualToPoint(coord, coordinates)) {
                ok = NO;
                break;
            }
            
            for (TDUnit *unit in spawn.units) {
                coord = [self tileCoordinatesForPositionInMap:unit.position];
                
                if (CGPointEqualToPoint(coord, coordinates)) {
                    ok = NO;
                    break;
                }
            }
        }
    }
    
    // or is the goal point?
    if (ok) {
        for (TDUltimateGoal *goal in self.goalPoints) {
            CGPoint coord = [self tileCoordinatesForPositionInMap:goal.position];
            
            if (CGPointEqualToPoint(coord, coordinates)) {
                ok = NO;
                break;
            }
        }
    }
    
    //TODO: or would it block pathfinding? although, we could fix it by doing it some other way, like making the ennemies attack!
#endif
    
    return ok;
}

- (BOOL) hasBuildingAtCoordinates:(CGPoint)coordinates {
    BOOL hasBuilding = NO;
    
    for (TDBaseBuilding *building in self.buildings) {
        if (CGPointEqualToPoint(coordinates, [self tileCoordinatesForPositionInMap:building.position])) {
            hasBuilding = YES;
            break;
        }
    }
    
    return hasBuilding;
}

- (BOOL)isWalkable:(CGPoint)coordinates forExploringObject:(id<ExploringObjectDelegate>)exploringObject {
    BOOL walkable = YES;
    
    if (coordinates.x < 0 || coordinates.x > self.backgroundMap.tiledMap.mapSize.width - 1 || coordinates.y < 0 || coordinates.y > self.backgroundMap.tiledMap.mapSize.height - 1) {
        return NO;
    }
#ifndef kTDGameScene_DISABLE_WALKABLE_CHECK
    
    // Air types can "walk" anywhere on the map
    if ([exploringObject isKindOfClass:[TDUnit class]]) {
        TDUnit *unit = (TDUnit *)exploringObject;
        
        if (unit.type == TDUnitType_Air) {
            return YES;
        }
    }
    
    if (self.backgroundMap.mainLayer.layerInfo) {
        TMXLayerInfo *layerInfo = self.backgroundMap.mainLayer.layerInfo;
        
        NSInteger gid = [layerInfo tileGidAtCoord:coordinates];
        NSDictionary *props = [self.backgroundMap.tiledMap propertiesForGid:gid];
        
        if (props) {
            if ([props[@"Walkable"] isEqualToString:@"YES"]) {
                walkable = YES;
            } else if (props[@"Walkable"]) {
                walkable = NO;
            }
        }
    }
#endif
    
    if (walkable) {
        walkable = ![self hasBuildingAtCoordinates:coordinates];
    }
    
    return walkable;
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
