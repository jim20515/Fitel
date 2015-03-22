//
//  TrainItem.m
//  Fitel
//
//  Created by James on 2/22/15.
//  Copyright (c) 2015 James. All rights reserved.
//

#import "YoutubeItem.h"


@implementation YoutubeItem

- (instancetype)initWithId:(NSString *)youtubeId title:(NSString *)title thumbHQ:(NSString *)thumbHQ playerUrl:(NSString *)playerUrl
{
    if (self = [self init])
    {
        self.youtubeId = youtubeId;
        self.title = title;
        self.thumbHQ = thumbHQ;
        self.playerUrl = playerUrl;
    }
    return self;
}

@end
