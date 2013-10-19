//
//  TDAssetManager.m
//  CoopTD
//
//  Created by Remy Bardou on 10/18/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDAssetManager.h"

NSString * const kFolderType_Map = @"map";
NSString * const kFolderType_Images = @"img";

@interface TDAssetManager() {
    NSMutableDictionary *_folders;
}

@end

@implementation TDAssetManager

static TDAssetManager *_defaultManager = nil;

+ (instancetype) defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[TDAssetManager alloc] init];
    });
    
    return _defaultManager;
}

- (id) init {
    self = [super init];
    
    if (self) {
        _folders = [[NSMutableDictionary alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        if (paths.count > 0) {
            _baseFolder = paths[0];
            
            _mapFolder = [_baseFolder stringByAppendingPathComponent:@"maps"];
            _imagesFolder = [_baseFolder stringByAppendingPathComponent:@"images"];
            
            _folders[kFolderType_Map] = _mapFolder;
            _folders[kFolderType_Images] = _imagesFolder;
        }
    }
    
    return self;
}

- (NSData *) dataWithContentOfFile:(NSString *)fileName withType:(NSString *)fileType {
    NSData *content = nil;
    
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSString *fullpath = [_folders[fileType] stringByAppendingPathComponent:fileName];
    
    if ([mgr fileExistsAtPath:fullpath]) {
        content = [mgr contentsAtPath:fullpath];
    } else {
        // do something, download? report?
        NSLog(@"File at path %@ does not exist!", fullpath);
    }
    
    return content;
}

#pragma mark - Public API

- (NSData *) dataWithContentOfMapFile:(NSString *)fileName {
    if (![fileName hasSuffix:@".xml"] && ![fileName hasSuffix:@".json"] && ![fileName hasSuffix:@".tmx"])
        fileName = [fileName stringByAppendingPathExtension:@".json"];
    
    return [self dataWithContentOfFile:fileName withType:kFolderType_Map];
}

- (NSString *) stringWithContentOfMapFile:(NSString *)fileName {
    return [NSString stringWithUTF8String:[[self dataWithContentOfMapFile:fileName] bytes]];
}



@end
