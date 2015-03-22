//
//  TrainItem.h
//  Fitel
//
//  Created by James on 2/22/15.
//  Copyright (c) 2015 James. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YoutubeItem : NSObject

@property (nonatomic, copy) NSString *youtubeId;
@property (nonatomic, copy) NSString *updateDate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *youtubeDescription;
@property (nonatomic, copy) NSString *thumbSQ;
@property (nonatomic, copy) NSString *thumbHQ;
@property (nonatomic, copy) NSString *playerUrl;
@property (nonatomic, copy) NSString *Duration;

- (instancetype)initWithId:(NSString *)youtubeId title:(NSString *)title thumbHQ:(NSString *)thumbHQ playerUrl:(NSString *)playerUrl;

@end
