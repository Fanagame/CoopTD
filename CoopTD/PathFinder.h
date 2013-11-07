//
//  PathFinder.h
//  PathFinder
//
//  Created by Rémy Bardou on 16/10/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ExplorableWorldDelegate <NSObject>

- (BOOL) isWalkable:(CGPoint)position;
- (NSUInteger) weightForTileAtPosition:(CGPoint)position;

@end

@interface PathNode : NSObject<NSCopying>

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, strong) PathNode *parent;

@property (nonatomic, assign) NSUInteger gScore; // sum of all the costs it took to get there
@property (nonatomic, assign) NSUInteger hScore; // heuristic, estimate of what it will take to get there
@property (nonatomic, assign, readonly) NSInteger overallScore; // sum of g + h

- (id)initWithPosition:(CGPoint)position;

@end

@interface PathFinder : NSObject

+ (instancetype) sharedInstance;

- (void)pathInExplorableWorld:(id<ExplorableWorldDelegate>)world fromA:(CGPoint)pointA toB:(CGPoint)pointB usingDiagonal:(BOOL)useDiagonal onSuccess:(void (^)(NSArray *path))onSuccess;
- (NSArray *)pathInExplorableWorld:(id<ExplorableWorldDelegate>)world fromA:(CGPoint)pointA toB:(CGPoint)pointB usingDiagonal:(BOOL)usingDiagonal;

@end
