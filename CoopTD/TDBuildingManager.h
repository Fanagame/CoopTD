//
//  TDBuildingManager.h
//  CoopTD
//
//  Created by Rémy Bardou on 12/11/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDNewGameScene, TDBaseBuilding;

@interface TDBuildingManager : NSObject

@property (nonatomic, weak) TDNewGameScene *gameScene;

+ (instancetype) sharedManager;

- (BOOL) addBuilding:(TDBaseBuilding *)building;
- (BOOL) addBuilding:(TDBaseBuilding *)building atPosition:(CGPoint)position;
- (BOOL) addBuilding:(TDBaseBuilding *)building atTileCoordinates:(CGPoint)tileCoordinates;

@end
