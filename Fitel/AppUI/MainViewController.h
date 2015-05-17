//
//  MainViewController.h
//  Fitel
//
//  Created by James on 2/17/15.
//  Copyright (c) 2015 James. All rights reserved.
//

#import "ScrollRefreshViewController.h"
#import "YoutubeItem.h"
#import "TrainTypeItem.h"

#define FITEL_PREFERENCE_PLIST @"Fitel"

@interface TrainCollectionViewCell : UICollectionViewCell
{
@protected
    UIImageView *_imageView;
    UILabel *_title;
}

@property (nonatomic, weak) TrainTypeItem *item;

- (void)configTrain:(TrainTypeItem *)item;

@end

@interface MainViewController : ScrollRefreshViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
}

@property (nonatomic, strong) NSMutableArray *trainItems;
@property (nonatomic, strong) NSMutableArray *trainTypeItems;
@property (nonatomic, strong) NSMutableArray *youtubeItems;
@property (nonatomic, strong) UIButton *testButton;

@property (nonatomic, strong) TrainKeyValue *selectKV;

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end
