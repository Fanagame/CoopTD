//
//  TDNewGameScene.h
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PathFinder.h"
#import "TDCamera.h"

#define kMinTimeInterval (1.0f / 60.0f)
#define kMinHeroToEdgeDistance 50

typedef enum : uint8_t {
	TDWorldLayerGround = 0,
	TDWorldLayerGrid,
    TDWorldLayerBuilding,
	TDWorldLayerBelowCharacter,
	TDWorldLayerCharacter,
	TDWorldLayerAboveCharacter,
	TDWorldLayerTop,
	kWorldLayerCount
} TDWorldLayer;

typedef enum : uint8_t {
    TDWorldModeDefault = 0,
    TDWorldModePlaceBuilding,
    TDWorldModeGameOver
} TDWorldMode;

/* Completion handler for callback after loading assets asynchronously. */
typedef void (^TDAssetLoadCompletionHandler)(void);

@class TDUnit, TDSpawn, TDUltimateGoal, TDTiledMap;
@class TDGridNode, TDHudNode;

@interface TDNewGameScene : SKScene<SKPhysicsContactDelegate, ExplorableWorldDelegate, TDCameraDelegate>

@property (nonatomic, weak)   UIViewController *parentViewController;
@property (nonatomic, strong) NSString *mapName;

@property (nonatomic, strong) SKNode *world;
@property (nonatomic, strong) NSMutableArray *layers;
@property (nonatomic, strong) TDTiledMap *backgroundMap;
@property (nonatomic, strong) TDHudNode *hud;
@property (nonatomic, strong) TDGridNode *grid;

@property (nonatomic, assign) CFTimeInterval lastUpdateTimeInterval;
@property (nonatomic, assign) TDWorldMode currentMode;

@property (nonatomic, strong) TDUltimateGoal *defaultGoalPoint;
@property (nonatomic, strong) TDSpawn *defaultSpawnPoint;
@property (nonatomic, weak) TDUnit *targetUnit;

@property (nonatomic, strong) NSMutableArray *spawnPoints;
@property (nonatomic, strong) NSMutableArray *goalPoints;
@property (nonatomic, strong) NSMutableArray *buildings;

+ (void)loadSceneAssetsForMapName:(NSString *)mapName withCompletionHandler:(TDAssetLoadCompletionHandler)callback;
+ (void)loadSceneAssetsForMapName:(NSString *)mapName;
+ (void)releaseSceneAssetsForMapName:(NSString *)mapName;

- (id) initWithSize:(CGSize)size andMapName:(NSString *)mapName;
- (void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLast;

/* All sprites in the scene should be added through this method to ensure they are placed in the correct world layer. */
- (void)addNode:(SKNode *)node atWorldLayer:(TDWorldLayer)layer;

- (CGPoint) tileCoordinatesForPositionInMap:(CGPoint)position;
- (CGPoint) tilePositionInMapForCoordinate:(CGPoint)position;
- (void) convertCoordinatesArrayToPositionsInMapArray:(NSArray *)coords;


@end
