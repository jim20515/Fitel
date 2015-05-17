//
//  PlistHelper.h
//  Fitel
//
//  Created by Jim Huang on 2015/5/16.
//  Copyright (c) 2015年 James. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistHelper : NSObject

+ (void)writePlistWithFilename:(NSString *)fileName
                           Key:(NSString *)key
                         Value:(NSString *)value;

+ (NSString *)getPlistValueWithFilename:(NSString *)fileName
                                    Key:(NSString *)key;

@end
