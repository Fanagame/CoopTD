//
//  TDEnums.h
//  CoopTD
//
//  Created by Remy Bardou on 11/11/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

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

typedef enum : uint8_t {
    TDHudButtonShape_Circle,
    TDHudButtonShape_Rectangle
} TDHudButtonShape;

typedef enum : uint8_t {
    TDHudButtonColor_Red,
    TDHudButtonColor_Orange,
    TDHudButtonColor_Green,
    TDHudButtonColor_Yellow,
    TDHudButtonColor_Blue
} TDHudButtonColor;

typedef enum : uint8_t {
    TDBulletType_Projectile,
    TDBulletType_Beam
} TDBulletType;

typedef enum : uint8_t {
    TDUnitPathFindingStatus_Standy,
    TDUnitPathFindingStatus_CalculatingPath,
    TDUnitPathFindingStatus_Moving
} TDUnitPathFindingStatus;

typedef enum : uint8_t {
    TDUnitType_Ground,
    TDUnitType_Air
} TDUnitType;