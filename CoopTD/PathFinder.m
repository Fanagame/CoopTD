//
//  PathFinder.m
//  PathFinder
//
//  Created by Rémy Bardou on 16/10/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "PathFinder.h"

@interface PathNode() {
	NSInteger _overallScore;
}

@end

@implementation PathNode

- (id)initWithPosition:(CGPoint)position {
	self = [super init];
	
	if (self) {
		self.position = position;
		_overallScore = -1;
	}
	
	return self;
}

- (NSInteger)overallScore {
	if (_overallScore < 0) {
		_overallScore = self.gScore + self.hScore;
	}

	return _overallScore;
}

- (id)copyWithZone:(NSZone *)zone {
    PathNode *n = [self.class allocWithZone:zone];
    
    if (n) {
        n.position = self.position;
        n.gScore = self.gScore;
        n.hScore = self.hScore;
        n.parent = self.parent;
    }
    
    return n;
}

- (BOOL) isEqual:(id)object {
    if ([object isKindOfClass:self.class]) {
        if (CGPointEqualToPoint(self.position, [object position])) {
            return YES;
        }
    }
    return NO;
}

@end

@implementation PathFinder

+ (instancetype) sharedInstance {
	static PathFinder *instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[PathFinder alloc] init];
	});
	
	return instance;
}

#pragma mark - Public API -

- (void)pathInExplorableWorld:(id<ExplorableWorldDelegate>)world fromA:(CGPoint)pointA toB:(CGPoint)pointB usingDiagonal:(BOOL)useDiagonal andExploringObject:(id<ExploringObjectDelegate>)exploringObject onSuccess:(void (^)(NSArray *))onSuccess {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray *path = [self pathInExplorableWorld:world fromA:pointA toB:pointB usingDiagonal:useDiagonal andExploringObject:exploringObject];
        onSuccess(path);
    });
}

- (void)pathInExplorableWorld:(id<ExplorableWorldDelegate>)world fromA:(CGPoint)pointA toB:(CGPoint)pointB usingDiagonal:(BOOL)useDiagonal onSuccess:(void (^)(NSArray *path))onSuccess {
    [self pathInExplorableWorld:world fromA:pointA toB:pointB usingDiagonal:useDiagonal andExploringObject:nil onSuccess:onSuccess];
}

- (NSArray *)pathInExplorableWorld:(id<ExplorableWorldDelegate>)world fromA:(CGPoint)pointA toB:(CGPoint)pointB usingDiagonal:(BOOL)useDiagonal andExploringObject:(id<ExploringObjectDelegate>)exploringObject {
	
	NSArray *path = nil;
	
	NSMutableSet *openedSet = [[NSMutableSet alloc] init]; // unexplored nodes that we know of
	NSMutableSet *closedSet = [[NSMutableSet alloc] init]; // nodes that were already explored and evaluated
	
	/*
	 * 1. Find node closest to your position and declare it start node and put it on
	 *	  the open list.
	 */
	PathNode *startNode = [[PathNode alloc] initWithPosition:pointA];
	startNode.hScore = [self heuristicForPosition:pointA goingToB:pointB inWorld:world forExploringObject:exploringObject];
	[openedSet addObject:startNode];
	
	
	/*
	 * 2. While there are nodes in the open list:
	 */
	PathNode *currentNode = nil;
	while (openedSet.count > 0) {
		/*
		 * 3. Pick the node from the open list having the smallest F score. Put it on
		 *    the closed list (you don't want to consider it again).
		 */
		currentNode = [self nodeWithSmallestFScoreInSet:openedSet];
		
		if (CGPointEqualToPoint(currentNode.position, pointB)) {
			path = [self reversePathFromNode:currentNode];
			break; // return the path
		}
		
		[openedSet removeObject:currentNode];
		[closedSet addObject:currentNode];
		
		/*
		 * 4. For each neighbor (adjacent cell) which isn't in the closed list or the opened list:
		 */
		for (PathNode *neighbor in [self neighborsForNode:currentNode inExplorableWorld:world usingDiagonal:useDiagonal forExploringObject:exploringObject]) {
			if (![self isNode:neighbor inSet:closedSet] && ![self isNode:neighbor inSet:openedSet]) {
				/*
				 * 5. Set its parent to current node. Will helps us find the way back
				 */
				neighbor.parent = currentNode;
				
				/*
				 * 6. Calculate G score (distance from starting node to this neighbor) and
				 * add it to the open list
				 */
				neighbor.gScore = neighbor.parent.gScore + 1;
				neighbor.hScore = [self heuristicForPosition:neighbor.position goingToB:pointB inWorld:world forExploringObject:exploringObject];
                
				[openedSet addObject:neighbor];
			}
		}
        
        // next open node
	}
	
	// We got ourselves a path!
	return path;
}

#pragma mark - Private API -

#pragma mark Path and node management

- (BOOL) isNode:(PathNode *)node inSet:(NSSet *)set {
	BOOL found = NO;
	
	for (PathNode *n in set) {
		if (CGPointEqualToPoint(n.position, node.position)) {
			found = YES;
			break;
		}
	}
	
	return found;
}

- (NSArray *) reversePathFromNode:(PathNode *)node {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	PathNode *curNode = node;
	
	while (curNode.parent) {
		[array insertObject:curNode atIndex:0];
		curNode = curNode.parent;
	}
	
	return array;
}

- (NSSet *) neighborsForNode:(PathNode *)rootNode inExplorableWorld:(id<ExplorableWorldDelegate>)world usingDiagonal:(BOOL)usingDiagonal forExploringObject:(id<ExploringObjectDelegate>)exploringObject {
	NSMutableSet *neighbors = [[NSMutableSet alloc] init];
	
    BOOL useSimpleWalkingMethod = YES;
    if ([world respondsToSelector:@selector(isWalkable:forExploringObject:)]) {
        useSimpleWalkingMethod = NO;
    }
    
    if ([world respondsToSelector:@selector(isWalkable:)] || [world respondsToSelector:@selector(isWalkable:forExploringObject:)]) {

        CGPoint position = CGPointZero;
        
        if (usingDiagonal) {
            position = CGPointMake(rootNode.position.x - 1, rootNode.position.y - 1);
            if ((useSimpleWalkingMethod && [world isWalkable:position]) || (!useSimpleWalkingMethod && [world isWalkable:position forExploringObject:exploringObject]))
                [neighbors addObject:[[PathNode alloc] initWithPosition:position]];
        }
        
        position = CGPointMake(rootNode.position.x, rootNode.position.y - 1);
        if ((useSimpleWalkingMethod && [world isWalkable:position]) || (!useSimpleWalkingMethod && [world isWalkable:position forExploringObject:exploringObject]))
            [neighbors addObject:[[PathNode alloc] initWithPosition:position]];
        
        if (usingDiagonal) {
            position = CGPointMake(rootNode.position.x + 1, rootNode.position.y - 1);
            if ((useSimpleWalkingMethod && [world isWalkable:position]) || (!useSimpleWalkingMethod && [world isWalkable:position forExploringObject:exploringObject]))
                [neighbors addObject:[[PathNode alloc] initWithPosition:position]];
        }
        
        position = CGPointMake(rootNode.position.x - 1, rootNode.position.y);
        if ((useSimpleWalkingMethod && [world isWalkable:position]) || (!useSimpleWalkingMethod && [world isWalkable:position forExploringObject:exploringObject]))
            [neighbors addObject:[[PathNode alloc] initWithPosition:position]];
        
        position = CGPointMake(rootNode.position.x + 1, rootNode.position.y);
        if ((useSimpleWalkingMethod && [world isWalkable:position]) || (!useSimpleWalkingMethod && [world isWalkable:position forExploringObject:exploringObject]))
            [neighbors addObject:[[PathNode alloc] initWithPosition:position]];
        
		if (usingDiagonal) {
			position = CGPointMake(rootNode.position.x + 1, rootNode.position.y + 1);
			if ((useSimpleWalkingMethod && [world isWalkable:position]) || [world isWalkable:position forExploringObject:exploringObject])
				[neighbors addObject:[[PathNode alloc] initWithPosition:position]];
        }
		
        position = CGPointMake(rootNode.position.x, rootNode.position.y + 1);
        if ((useSimpleWalkingMethod && [world isWalkable:position]) || (!useSimpleWalkingMethod && [world isWalkable:position forExploringObject:exploringObject]))
            [neighbors addObject:[[PathNode alloc] initWithPosition:position]];
        
		if (usingDiagonal) {
			position = CGPointMake(rootNode.position.x - 1, rootNode.position.y + 1);
			if ((useSimpleWalkingMethod && [world isWalkable:position]) || (!useSimpleWalkingMethod && [world isWalkable:position forExploringObject:exploringObject]))
				[neighbors addObject:[[PathNode alloc] initWithPosition:position]];
		}
    }
	
	return neighbors;
}

#pragma mark Score evaluation

- (PathNode *) nodeWithSmallestFScoreInSet:(NSSet *)set {
	PathNode *candidate = nil;
	
	for (PathNode *node in set) {
		if (!candidate || node.overallScore < candidate.overallScore) {
			candidate = node;
		}
	}
	
	return candidate;
}

- (NSInteger) heuristicForPosition:(CGPoint)pointA goingToB:(CGPoint)pointB inWorld:(id<ExplorableWorldDelegate>)world forExploringObject:(id<ExploringObjectDelegate>)exploringObject {
	NSInteger score = [self manhattanDistanceBetweenA:pointA andB:pointB];
	
    if ([world respondsToSelector:@selector(weightForTileAtPosition:forExploringObject:)]) {
        score += [world weightForTileAtPosition:pointA forExploringObject:exploringObject];
    } else if ([world respondsToSelector:@selector(weightForTileAtPosition:)]) {
		score += [world weightForTileAtPosition:pointA];
	}
	
	return score;
}

- (NSInteger) manhattanDistanceBetweenA:(CGPoint)pointA andB:(CGPoint)pointB {
	return abs(pointB.x - pointA.x) + abs(pointB.y - pointB.y);
}

@end
