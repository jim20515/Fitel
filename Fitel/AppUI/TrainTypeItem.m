//
//  TrainTypeItem.m
//  Fitel
//
//  Created by Jim Huang on 2015/5/16.
//  Copyright (c) 2015年 James. All rights reserved.
//

#import "TrainTypeItem.h"

@implementation TrainTypeItem

- (NSString *)imageDir
{
    NSString *cachePath = [PathUtility getCachePath];
    
    [PathUtility createDirectoryAtCache:TYPE_ITEM_FOLDER];
    
    NSString *videoPath = [NSString stringWithFormat:@"%@/%@/", cachePath, TYPE_ITEM_FOLDER];
    return videoPath;
}

- (NSString *)cacheImagePath
{
    NSString *videoPath = [self imageDir];
    NSString *fileName = self.imageName;
    NSString *path = [NSString stringWithFormat:@"%@%@", videoPath, fileName];
    return path;
}

- (BOOL)isDiffImage
{
    if (![PathUtility isExistFile:[self cacheImagePath]])
        return YES;
    
    return NO;
}


@end
