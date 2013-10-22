//
//  TDCamera.m
//  CoopTD
//
//  Created by Remy Bardou on 10/21/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDCamera.h"
#import "TDUnit.h"
#import "TDSpawn.h"

@interface TDCamera ()

@property (nonatomic, weak) SKNode *trackedElement;

@end

@implementation TDCamera

CGFloat const kCameraZoomLevel_Max = 5.0f;
CGFloat const kCameraZoomLevel_Min = 0.05f;

static TDCamera *_sharedCamera;
+ (instancetype) sharedCamera {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCamera = [[TDCamera alloc] init];
    });
    return _sharedCamera;
}

//TODO: cache the value for best performance?
- (CGFloat) bestScaleForDevice {
    CGSize winSize = self.world.scene.size;
    CGSize actualMapSize = [self.delegate actualMapSizeForCamera:self];
    
    CGFloat bestXScale = winSize.width / actualMapSize.width;
    CGFloat bestYScale = winSize.height / actualMapSize.height;
    
    return MAX(bestXScale, bestYScale);
}

- (CGPoint) boundedLayerPosition:(CGPoint)newPos {
    return newPos;
    
    CGSize winSize = self.world.scene.size;
    CGSize mapSize = self.world.calculateAccumulatedFrame.size;
    
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -mapSize.width + winSize.width);
    retval.y = MIN(retval.y, 0);
    retval.y = MAX(retval.y, -mapSize.height + winSize.height);
    
    return retval;
}

- (CGPoint) cameraPosition {
    return self.world.position;
}

- (void) moveCameraBy:(CGPoint)trans {
    [self disableTracking];
    
    trans = CGPointMake(self.world.position.x + trans.x, self.world.position.y - trans.y);
    self.world.position = [self boundedLayerPosition:trans];
}

- (void) pointCameraToPoint:(CGPoint)position {
    // center the world on that position
    CGPoint cameraPositionInScene = [self.world.scene convertPoint:position fromNode:self.world];
    position = CGPointMake(self.world.position.x - cameraPositionInScene.x, self.world.position.y - cameraPositionInScene.y);
    
    // apply the change while ensuring the position doesnt cause the game to go out of bounds
    self.world.position = [self boundedLayerPosition:position];
}

- (void) pointCameraToSpawn:(TDSpawn *)spawn {
    [self disableTracking];
    
    [self pointCameraToPoint:spawn.position];
}

- (void) pointCameraToUnit:(TDUnit *)unit {
    [self pointCameraToUnit:unit trackingEnabled:NO];
}

- (void) pointCameraToUnit:(TDUnit *)unit trackingEnabled:(BOOL)trackingEnabled {
    [self zoomOnObjectWithRect:unit.frame withDesiredSpaceOccupation:0.2]; // 20%
    [self pointCameraToPoint:unit.position];
    
    if (trackingEnabled) {
        [self enableTrackingForElement:unit];
    } else {
        [self disableTracking];
    }
}

- (void) pointCameraToBuilding:(id)building {
    [self disableTracking];
}

- (void) updateCameraTracking {
    if (self.trackingEnabled) {
        [self pointCameraToPoint:self.trackedElement.position];
    }
}

- (void) enableTrackingForElement:(SKNode *)node {
    self.trackedElement = node;
}

- (void) disableTracking {
    self.trackedElement = nil;
}

- (BOOL) trackingEnabled {
    if (self.trackedElement && self.trackedElement.parent && !self.trackedElement.hidden) {
        return YES;
    }
    return NO;
}

//TODO: fix and try to keep it centered on the right location when zooming!
- (void) zoomOnObjectWithRect:(CGRect)objectRect withDesiredSpaceOccupation:(CGFloat)spaceOccupationDesired {
    CGSize winSize = self.world.scene.size;
    
    // we want the object to occupy 20% of the screen
    // 0.2 = desiredSize / winSize
    
    CGFloat desiredWidth = winSize.width * spaceOccupationDesired;
    CGFloat desiredHeight = winSize.height * spaceOccupationDesired;
    
    CGFloat bestXScale = winSize.width / desiredWidth;
    CGFloat bestYScale = winSize.height / desiredHeight;
    
    CGFloat newScale = MIN(bestXScale, bestYScale);
    
    //
    // We now have our optimal scale to zoom on that object
    // Let's zoom on it
    //
    
    [self setCameraZoomLevel:newScale];
    
//    CGRect r = self.world.calculateAccumulatedFrame;
//    self.world.position = CGPointMake(0, 0);
    //    [self pointCameraToPoint:objectRect.origin];
}

- (void) setCameraToDefaultZoomLevel {
    CGFloat newScale = [self bestScaleForDevice];
    [self setCameraZoomLevel:newScale];
}

- (void) setCameraZoomLevel:(CGFloat)newDesiredScale {
    [self.world setScale:MIN(kCameraZoomLevel_Max, MAX(newDesiredScale, self.bestScaleForDevice))];
}

- (CGFloat) cameraZoomLevel {
    return self.world.xScale;
}


@end
