//
//  TDCamera.h
//  CoopTD
//
//  Created by Remy Bardou on 10/21/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class TDUnit, TDSpawn, TDCamera;

@protocol TDCameraDelegate <NSObject>

- (CGSize) actualMapSizeForCamera:(TDCamera *)camera;
- (CGSize) mapSizeForCamera:(TDCamera *)camera;

@end

@interface TDCamera : NSObject

@property (nonatomic, weak) SKNode *world;
@property (nonatomic, weak) id<TDCameraDelegate> delegate;

+ (instancetype) sharedCamera;

#pragma mark - Point camera somewhere
- (CGPoint) cameraPosition;
- (void) pointCameraToPoint:(CGPoint)position;
- (void) pointCameraToSpawn:(TDSpawn *)spawn;
- (void) pointCameraToUnit:(TDUnit *)unit;
- (void) pointCameraToUnit:(TDUnit *)unit trackingEnabled:(BOOL)trackingEnabled;
- (void) pointCameraToBuilding:(id)building;
- (void) moveCameraBy:(CGPoint)tran;

#pragma mark - Tracking
- (void) updateCameraTracking;
- (void) enableTrackingForElement:(SKNode *)node withEdgeBounds:(CGFloat)edgeBounds;
- (void) disableTracking;
- (BOOL) trackingEnabled;

#pragma mark - Zoom on something
- (void) zoomOnNode:(SKNode *)node;
- (void) zoomOnNode:(SKNode *)node withSizeOnScreenAsPercentage:(CGFloat)sizeOnScreen;
- (void) setCameraToDefaultZoomLevel;
- (void) setCameraZoomLevel:(CGFloat)newZoomLevel;
- (CGFloat) cameraZoomLevel;

@end