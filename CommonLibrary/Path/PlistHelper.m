//
//  PlistHelper.m
//  Fitel
//
//  Created by Jim Huang on 2015/5/16.
//  Copyright (c) 2015年 James. All rights reserved.
//

#import "PlistHelper.h"

@implementation PlistHelper

+ (NSString *)domainPath
{
    //初始化路徑
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains
                          (NSDocumentDirectory,NSUserDomainMask, YES)
                          objectAtIndex:0];
    return rootPath;
}

+ (NSString *)plistPath:(NSString *)fileName
{
    NSString *domainPath = [self domainPath];
    NSString *plistPathWithExtension = [NSString stringWithFormat:@"%@.plist", fileName];
    
    NSString *plistPath = [domainPath stringByAppendingPathComponent:plistPathWithExtension];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        NSString *projectPlistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
        
        NSMutableDictionary *plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:projectPlistPath];
        //將 Dictionary 儲存至指定的檔案
        [plistDictionary writeToFile:plistPath atomically:YES];
    }
    
    return plistPath;
}

+ (void)writePlistWithFilename:(NSString *)fileName
                           Key:(NSString *)key
                         Value:(NSString *)value
{
    NSString *plistPath = [self plistPath:fileName];
    
    //建立一個 Dictionary
    NSMutableDictionary *plistDictionary;
    
    //將取得的 plist 內容載入至剛才建立的 Dictionary 中
    plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    //接荖我們來試著修改其內容
    [plistDictionary setObject:[NSString stringWithFormat:@"%@", value] forKey:key];
    
    //將 Dictionary 儲存至指定的檔案
    [plistDictionary writeToFile:plistPath atomically:YES];
    
}

+ (NSString *)getPlistValueWithFilename:(NSString *)fileName
                              Key:(NSString *)key
{
    NSString *plistPath = [self plistPath:fileName];
    
    //建立一個 Dictionary
    NSMutableDictionary *plistDictionary;
    
    //將取得的 plist 內容載入至剛才建立的 Dictionary 中
    plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    return [plistDictionary objectForKey:key];
    
}

@end
