//
//  TDMap.h
//  CoopTD
//
//  Created by Remy Bardou on 10/18/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PathFinder.h"

@class JSTileMap;

@interface TDMap : NSObject<ExplorableWorldDelegate>

@property (nonatomic, strong, readonly) NSString *mapName;
@property (nonatomic, strong) JSTileMap *tileMap;

- (id) initMapNamed:(NSString *)mapName;

@end
