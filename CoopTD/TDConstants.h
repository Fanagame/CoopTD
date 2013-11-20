//
//  TDConstants.h
//  CoopTD
//
//  Created by Remy Bardou on 11/3/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

static const uint32_t kPhysicsCategory_UnitType_Ground  = 0x1 << 0; // 1
static const uint32_t kPhysicsCategory_UnitType_Air     = 0x1 << 1; // 2
static const uint32_t kPhysicsCategory_World            = 0x1 << 2; // 4
static const uint32_t kPhysicsCategory_Unit             = 0x1 << 3; // 8
static const uint32_t kPhysicsCategory_Building         = 0x1 << 4; // 16
static const uint32_t kPhysicsCategory_BuildingRange    = 0x1 << 5; // 32
static const uint32_t kPhysicsCategory_Bullet           = 0x1 << 6; // 64
static const uint32_t kPhysicsCategory_UltimateGoal     = 0x1 << 7; // 128

static const uint32_t kTDBulletEffect_Freeze            = 0x1 << 0; // 1
static const uint32_t kTDBulletEffect_Fire              = 0x1 << 1; // 2
static const uint32_t kTDBulletEffect_Poison            = 0x1 << 2; // 4


//#define kTDPath_PRINT_CACHE_CONTENT
//#define kTDGameScene_DISABLE_WALKABLE_CHECK
//#define kTDGameScene_DISABLE_CONSTRUCTABLE_CHECK
#define kTDGameScene_ENABLE_QUICK_TD_BUILD
#define kTDGameScene_SHOW_GRID
//#define kTDBuilding_SHOW_RANGE_BY_DEFAULT
//#define kTDBuilding_SHOW_PHYSICS_BODY
//#define kTDBuilding_DISABLE_SHOOTING
#define kTDBuildingAI_ALWAYS_SHOOT_THE_NEW_GUY
//#define kTDBeamBullet_SHOW_PHYSICS_BODY
#define kTDUnit_ALWAYS_SHOW_HEALTH
//#define kTDBuilding_ALWAYS_SHOW_HEALTH
//#define kTDGameScene_SKIP_MAP_SELECTION
