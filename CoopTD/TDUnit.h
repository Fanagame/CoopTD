//
//  TDUnit.h
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

typedef enum TDUnitStatus : NSUInteger {
    TDUnitStatus_Standy,
    TDUnitStatus_CalculatingPath,
    TDUnitStatus_Moving
} TDUnitStatus;

@interface TDUnit : NSObject

@property (nonatomic, strong) SKSpriteNode *spriteNode;

@property (nonatomic, assign) NSInteger unitID;
@property (nonatomic, strong) NSString *displayName;

@property (nonatomic, assign) NSInteger health;
@property (nonatomic, assign) NSInteger maxHealth;

@property (nonatomic, assign) TDUnitStatus status;
@property (nonatomic, strong, readonly) NSArray *path;

- (void) followArrayPath:(NSArray *)path withCompletionHandler:(void (^)())onComplete;
- (void) followArrayPath:(NSArray *)path;

@end