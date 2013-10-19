//
//  TDAssetManager.h
//  CoopTD
//
//  Created by Remy Bardou on 10/18/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDAssetManager : NSObject {
    NSString *_baseFolder;
    NSString *_mapFolder;
    NSString *_imagesFolder;
}

+ (instancetype) defaultManager;

- (NSData *) dataWithContentOfMapFile:(NSString *)fileName;
- (NSString *) stringWithContentOfMapFile:(NSString *)fileName;

@end
