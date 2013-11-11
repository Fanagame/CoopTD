//
//  TDGridNode.m
//  CoopTD
//
//  Created by Rémy Bardou on 28/10/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDGridNode.h"

@implementation TDGridNode

- (id) init {
	self = [super init];
	
	if (self) {
		self.name = @"grid";
	}
	
	return self;
}

- (void) buildGridWithTileSize:(CGSize)tileSize {
	// Parent size
	CGSize size = self.parent.calculateAccumulatedFrame.size;
	
	CGFloat tileWidth = tileSize.width;
	CGFloat tileHeight = tileSize.height;
	
	NSInteger maxX = ceil(size.width / tileWidth);
	NSInteger maxY = ceil(size.height / tileHeight);
	
	for (NSInteger x = 0; x < maxX; x++) {
		// init shape node
		SKShapeNode *n = [[SKShapeNode alloc] init];
		n.lineWidth = 0.1;
		n.fillColor = [SKColor clearColor];
		n.strokeColor = [SKColor blackColor];
		n.glowWidth = 0.0;
		
		// build path
		CGMutablePathRef myPath = CGPathCreateMutable();
		CGPathMoveToPoint(myPath, NULL, x * tileWidth, 0);
		CGPathAddLineToPoint(myPath, NULL, x * tileWidth, size.height);
		n.path = myPath;
		CGPathRelease(myPath);
		
		// add as subnode
		[self addChild:n];
	}
	
	for (NSInteger y = 0; y < maxY; y++) {
		// init shape node
		SKShapeNode *n = [[SKShapeNode alloc] init];
		n.lineWidth = 0.1;
		n.fillColor = [SKColor clearColor];
		n.strokeColor = [SKColor blackColor];
		n.glowWidth = 0.0;
		
		// build path
		CGMutablePathRef myPath = CGPathCreateMutable();
		CGPathMoveToPoint(myPath, NULL, 0, y * tileHeight);
		CGPathAddLineToPoint(myPath, NULL, size.width, y * tileHeight);
		n.path = myPath;
		CGPathRelease(myPath);
		
		// add as subnode
		[self addChild:n];
	}
}

- (void) show {
	for (SKNode *node in self.children) {
		node.hidden = NO;
	}
}

- (void) hide {
	for (SKNode *node in self.children) {
		node.hidden = YES;
	}
}

@end
