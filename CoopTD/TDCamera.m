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

#pragma mark - Helpers
- (CGFloat) bestScaleForDevice;
- (CGPoint) boundedLayerPosition:(CGPoint)newPos;

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


/// @description ensures that the new position won't make go out of bounds (mapSize wise)
- (CGPoint) boundedLayerPosition:(CGPoint)newPos {
    CGSize winSize = self.world.scene.size;
    CGSize mapSize = self.world.calculateAccumulatedFrame.size;
    
    CGPoint retval = newPos;
    
    // let's offset all positions, base on the anchorPoint
    retval.x += winSize.width * self.world.scene.anchorPoint.x;
    retval.y += winSize.height * self.world.scene.anchorPoint.y;
    
    // Now, let's check if we're out of bounds with the smaller values
    retval.x = MIN(retval.x, 0);
    retval.y = MIN(retval.y, 0);
    
    // Let's do the same check with the bigger values
    retval.x = MAX(retval.x, -mapSize.width + winSize.width);
    retval.y = MAX(retval.y, -mapSize.height + winSize.height);
    
    // Finally, restore the offset on those values (cause we're dealing with .position, not .frame.origin)
    retval.x -= winSize.width * self.world.scene.anchorPoint.x;
    retval.y -= winSize.height * self.world.scene.anchorPoint.y;
    
    return retval;
}

#pragma mark - Handle camera position, move it around

//TODO: do we really need this exposed?
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
    [self zoomOnNode:unit withSizeOnScreenAsPercentage:0.3];
    
    if (trackingEnabled) {
        [self enableTrackingForElement:unit];
    } else {
        [self disableTracking];
    }
}

- (void) pointCameraToBuilding:(id)building {
    [self disableTracking];
}

#pragma mark - Node tracking management

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

#pragma mark - Zoom management

- (void) zoomOnNode:(SKNode *)node {
    [self zoomOnNode:node withSizeOnScreenAsPercentage:0.5];
}

- (void) zoomOnNode:(SKNode *)node withSizeOnScreenAsPercentage:(CGFloat)sizeOnScreen {
    CGSize winSize = self.world.scene.size;
    
    CGFloat desiredWidth = winSize.width * sizeOnScreen;
    CGFloat desiredHeight = winSize.height * sizeOnScreen;
    
    CGFloat bestXScale = desiredWidth / node.calculateAccumulatedFrame.size.width;
    CGFloat bestYScale = desiredHeight / node.calculateAccumulatedFrame.size.height;
    
    CGFloat newScale = MIN(bestXScale, bestYScale);
    
    //
    // We now have our optimal scale to zoom on that object
    // Let's zoom on it
    //
    
    [self setCameraZoomLevel:newScale];
    [self pointCameraToPoint:node.position];
}

- (void) setCameraToDefaultZoomLevel {
    CGFloat newScale = [self bestScaleForDevice];
    [self setCameraZoomLevel:newScale];
}

//TODO: let's try to stay centered on the same point
- (void) setCameraZoomLevel:(CGFloat)newDesiredScale {
    CGPoint currentCenterPoint = CGPointMake(0, 0);
    NSLog(@"Current center: %f %f", currentCenterPoint.x, currentCenterPoint.y);
    [self.world setScale:MIN(kCameraZoomLevel_Max, MAX(newDesiredScale, self.bestScaleForDevice))];
}

- (CGFloat) cameraZoomLevel {
    return self.world.xScale;
}


@end
