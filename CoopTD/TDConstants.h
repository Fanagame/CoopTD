//
//  TDConstants.h
//  CoopTD
//
//  Created by Remy Bardou on 11/3/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

static const uint32_t kPhysicsCategory_World            = 0x1 << 0;
static const uint32_t kPhysicsCategory_Unit             = 0x1 << 1;
static const uint32_t kPhysicsCategory_Building         = 0x1 << 2;
static const uint32_t kPhysicsCategory_BuildingRange    = 0x1 << 3;
static const uint32_t kPhysicsCategory_Bullet           = 0x1 << 4;
static const uint32_t kPhysicsCategory_UltimateGoal     = 0x1 << 5;

//#define kTDPath_PRINT_CACHE_CONTENT
//#define kTDGameScene_DISABLE_WALKABLE_CHECK
//#define kTDGameScene_DISABLE_CONSTRUCTABLE_CHECK
//#define kTDGameScene_SHOW_GRID
//#define kTDBuilding_SHOW_RANGE_BY_DEFAULT
//#define kTDBuilding_SHOW_PHYSICS_BODY
//#define kTDBuilding_DISABLE_SHOOTING
//#define kTDBuildingAI_ALWAYS_SHOOT_THE_NEW_GUY
//#define kTDBeamBullet_SHOW_PHYSICS_BODY