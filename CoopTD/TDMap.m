//
//  TDMap.m
//  CoopTD
//
//  Created by Remy Bardou on 10/18/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDMap.h"
#import "JSTileMap.h"

@interface TDMap()

@property (nonatomic, strong, readwrite) NSString *mapName;

@end

@implementation TDMap

- (id) initMapNamed:(NSString *)mapName {
    self = [super init];
    
    if (self) {
        self.mapName = mapName;
        
        [self loadMap];
    }
    
    return self;
}

- (void) loadMap {
    if (self.mapName.length > 0) {
        self.tileMap = [JSTileMap mapNamed:self.mapName];
    }
}

#pragma mark - Explorable World Delegate

- (BOOL)isWalkable:(CGPoint)position {
    return YES;
}

- (NSUInteger)weightForTileAtPosition:(CGPoint)position {
    return 1;
}

@end
