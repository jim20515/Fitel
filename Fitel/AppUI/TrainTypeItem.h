//
//  TrainTypeItem.h
//  Fitel
//
//  Created by Jim Huang on 2015/5/16.
//  Copyright (c) 2015年 James. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TYPE_ITEM_FOLDER @"TypeItem"

@interface TrainTypeItem : NSObject

@property (nonatomic, copy) NSString *typeId;
@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *imageName;

- (NSString *)cacheImagePath;
- (BOOL)isDiffImage;

@end
