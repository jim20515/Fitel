//
//  MainViewController.m
//  Fitel
//
//  Created by James on 2/17/15.
//  Copyright (c) 2015 James. All rights reserved.
//

#import "MainViewController.h"


@interface ProgressView : UIView
{
    UIProgressView *_progressView;
    UILabel        *_progress;
}

- (void)setProgress:(CGFloat)progress;

@end


@implementation ProgressView

static int _scrollViewHight = 130;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 200, 30)])
    {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(kDefaultMargin, kDefaultMargin, 200 - 2*kDefaultMargin, kDefaultMargin)];
        _progressView.progressTintColor = kGreenColor;
        _progressView.trackTintColor = kWhiteColor;
        [self addSubview:_progressView];
        
        _progress = [[UILabel alloc] init];
        _progress.textColor = kWhiteColor;
        _progress.font = [UIFont systemFontOfSize:13];
        _progress.textAlignment = NSTextAlignmentCenter;
        _progress.frame = CGRectMake(kDefaultMargin, _progressView.frame.origin.y + _progress.frame.size.height + 2*kDefaultMargin, 200 - kDefaultMargin * 2, 18);
        //        _progress.backgroundColor = kRedColor;
        _progress.text = @"0/100";
        [self addSubview:_progress];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progressView.progress = progress;
    _progress.text = [NSString stringWithFormat:@"%d/100", (int)(100 * progress)];
}

@end


@implementation TrainCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addOwnViews];
        [self configOwnViews];
        self.backgroundColor = [UIColor flatWhiteColor];
    }
    return self;
}

- (void)addOwnViews
{
    _imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_imageView];
    
    _title = [[UILabel alloc] init];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.textColor = kBlackColor;
    _title.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_title];
}

- (void)configTrain:(TrainKeyValue *)item
{
    self.item = item;
    _title.text = item.key;
    _imageView.image = item.image;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self relayoutFrameOfSubViews];
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.contentView.bounds;
    [_imageView sizeWith:CGSizeMake(rect.size.width, rect.size.width)];
    
    [_title sizeWith:CGSizeMake(rect.size.width, rect.size.height - rect.size.width)];
    [_title layoutBelow:_imageView];
}



@end


@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    self.youtubeItems = [self getYoutubeArray];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    
}

- (NSString *)cellIdentifier
{
    return @"MainViewController_TrainCollectionViewCell";
}

//- (void)addHeaderView
//{
//    self.headerView = [[HeadRefreshView alloc] init];
//}


- (void)addRefreshScrollView
{
    CGRect rect = self.view.bounds;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(kDefaultMargin, kDefaultMargin, kDefaultMargin, kDefaultMargin);
    layout.minimumInteritemSpacing = kDefaultMargin;
    layout.minimumLineSpacing = kDefaultMargin;
    CGFloat width = (rect.size.width - 2*layout.minimumInteritemSpacing - (layout.sectionInset.left + layout.sectionInset.right))/3;
    layout.itemSize = CGSizeMake(width , width + 30);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(190, 300, rect.size.width, rect.size.height) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = kClearColor;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TrainCollectionViewCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    _collectionView.frame = self.view.bounds;
    _collectionView.autoresizesSubviews = YES;
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.refreshScrollView = _collectionView;
}

- (void)reload
{
    [_collectionView reloadData];
    [self refreshCompleted];
}

//- (void)layoutOnIPhone
//{
//    _collectionView.frame = self.view.bounds;
//}

- (void)request:(BOOL)cache
{
    NSURL *url = [NSURL URLWithString:kAppTrainURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    if (cache)
    {
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    
    [request setValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    __weak typeof(self) ws = self;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *urlResponce, NSData *data, NSError *error)
     {
         
         [[HUDHelper sharedInstance] stopLoading];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         
         if (error != nil)
         {
             [[HUDHelper sharedInstance] tipMessage:kNetwork_Error_Str];
         }
         else
         {
             NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             DebugLog(@"=========================>>>>>>>>\nresponseString is :\n %@" , responseString);
             // TODO : 正则表解析XML返回的结果
             // 改下面这句
             NSDictionary *dic = [responseString objectFromJSONString];
             NSArray *trains = [dic objectForKey:@"list"];
             NSMutableArray *array = [NSObject loadItem:[TrainItem class] fromArrayDictionary:trains];
             
             NSMutableArray *realArray = [NSMutableArray array];
             
             
             for (NSInteger i = 3; i <= 10; i++)
             {
                 NSMutableArray *value = [NSMutableArray array];
                 for (NSInteger j = 0; j<array.count; j++)
                 {
                     TrainItem *item = [array objectAtIndex:j];
                     if ([item.type integerValue] == i)
                     {
                         [value addObject:item];
                     }
                 }
                 
                 TrainKeyValue *tkv = [[TrainKeyValue alloc] initWithType:i value:value];
                 [realArray addObject:tkv];
             }
             
             ws.trainItems = realArray;
             [ws reload];
         }
     }];
}

- (void)onRefresh
{
    [self request:NO];
}

- (void)configOwnViews
{
    [self request:NO];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 2)
    {
        return 2;
    }
    else
    {
        return 3;
    }
}


- (NSInteger)trainItemIndexOf:(NSIndexPath *)path
{
    NSInteger index = 0;
    
    for (NSInteger i = 1; i<= path.section; i++)
    {
        index += [self collectionView:_collectionView numberOfItemsInSection:i-1];
    }
    
    return index + path.row;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TrainCollectionViewCell *cell = (TrainCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[self cellIdentifier] forIndexPath:indexPath];
    NSInteger index = [self trainItemIndexOf:indexPath];
    
    
    TrainKeyValue *item = [self.trainItems objectAtIndex:index];
    [cell configTrain:item];
    
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    if(section == 0)
        return CGSizeMake(self.view.bounds.size.width, _scrollViewHight);
    
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGSize scrollViewScreenSize = CGSizeMake(screenSize.width, _scrollViewHight);
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewScreenSize.width, scrollViewScreenSize.height)];
        scrollView.contentSize = CGSizeMake((scrollViewScreenSize.width / 3) * self.youtubeItems.count, scrollViewScreenSize.height);
        scrollView.backgroundColor = [UIColor whiteColor];
        int i=0;
        int viewWidth = (scrollViewScreenSize.width / 3);
        
        for(YoutubeItem *item in self.youtubeItems)
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * viewWidth, 0, viewWidth, scrollViewScreenSize.height)];
            
            UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 80)];
            imageButton.tag = i;
            [imageButton addTarget:self action:@selector(youtubeClick:) forControlEvents:UIControlEventTouchUpInside];
            
            dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            //this will start the image loading in bg
            dispatch_async(concurrentQueue, ^{
                NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:item.thumbHQ]];
                
                //this will set the image when loading is finished
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imageButton setBackgroundImage:[UIImage imageWithData:image] forState:UIControlStateNormal];
                });
            });
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, imageButton.bounds.size.height + 5, imageButton.bounds.size.width, 40)];
            [title setFont:[UIFont systemFontOfSize:12]];
            title.text = item.title;
            
            title.lineBreakMode = UILineBreakModeWordWrap;
            title.numberOfLines = 0;
            
            [view addSubview:imageButton];
            [view addSubview:title];
            
            [scrollView addSubview:view];
            i++;
        }

        [headerView addSubview:scrollView];
        
        UILabel *underline = [[UILabel alloc] initWithFrame:CGRectMake(0, scrollView.bounds.size.height, self.view.bounds.size.width, 1)];
        [underline setBackgroundColor:[UIColor lightGrayColor]];
        [headerView addSubview:underline];
        
        return headerView;
    }
    
    return headerView;
}

- (void)onDownloadChanged:(NSNotification *)notify
{
    
    TrainKeyValue *item = (TrainKeyValue *)notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (item == self.selectKV)
        {
            if ([item canPlay])
            {
                [self.progressHUD hide:YES];
//                [[HUDHelper sharedInstance] stopLoading];
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                
                TrainViewController *vc = [[TrainViewController alloc] init];
                vc.trainKeyValue = item;
                [[AppDelegate sharedAppDelegate] pushViewController:vc];
            }
        }
    });
}

- (void)onDownloadProgressChanged:(NSNotification *)notify
{
    TrainKeyValue *item = (TrainKeyValue *)notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (item == self.selectKV)
        {
            NSDictionary *ui = notify.userInfo;
            ProgressView *pv = (ProgressView *) self.progressHUD.customView;
            [pv setProgress:[(NSNumber *)(ui[@"DownloadProgress"]) floatValue]];
            
        }
    });
    
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [self trainItemIndexOf:indexPath];
    
    TrainKeyValue *item = [self.trainItems objectAtIndex:index];
    
    if ([item canPlay])
    {
        TrainViewController *vc = [[TrainViewController alloc] init];
        vc.trainKeyValue = item;
        [[AppDelegate sharedAppDelegate] pushViewController:vc];
    }
    else
    {
        self.selectKV = item;
//        [[HUDHelper sharedInstance] loading];
        [item startCache];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadChanged:) name:kTrainItemDownloadCompleted object:nil];
        
        
        self.progressHUD = [[MBProgressHUD alloc] initWithWindow:[AppDelegate sharedAppDelegate].window];
        [[AppDelegate sharedAppDelegate].window addSubview:self.progressHUD];
        
        // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
        // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
        self.progressHUD.customView = [[ProgressView alloc] init];
        
        // Set custom view mode
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        
        [self.progressHUD show:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadProgressChanged:) name:kTrainItemDownloadProgress object:nil];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSMutableArray *)getYoutubeArray
{
    NSMutableArray *youtubeInfo = [[NSMutableArray alloc] init];
    
    YoutubeItem *item = [[YoutubeItem alloc] initWithId:@"Lqx4sqAPrrs" title:@"運動前如何暖身" thumbHQ:@"http://img.youtube.com/vi/Lqx4sqAPrrs/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=Lqx4sqAPrrs"];
    
    YoutubeItem *item1 = [[YoutubeItem alloc] initWithId:@"@cd-Mgat05Gg" title:@"運動後如何收操伸展" thumbHQ:@"http://img.youtube.com/vi/cd-Mgat05Gg/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=cd-Mgat05Gg"];
    
    YoutubeItem *item2 = [[YoutubeItem alloc] initWithId:@"ooR1s0eVjZ0" title:@"TABATA四分鐘運動-進階版LV2" thumbHQ:@"http://img.youtube.com/vi/ooR1s0eVjZ0/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=ooR1s0eVjZ0"];
    
    YoutubeItem *item3 = [[YoutubeItem alloc] initWithId:@"NGjQ5FqdPbk" title:@"TABATA伏地挺身仰臥起坐MIX版 LV1" thumbHQ:@"http://img.youtube.com/vi/NGjQ5FqdPbk/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=NGjQ5FqdPbk"];
    
    YoutubeItem *item4 = [[YoutubeItem alloc] initWithId:@"2X3OQZte0wo" title:@"TABATA棒式核心運動進階版" thumbHQ:@"http://img.youtube.com/vi/2X3OQZte0wo/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=2X3OQZte0wo"];
    
    YoutubeItem *item5 = [[YoutubeItem alloc] initWithId:@"JOfNoK5yh6w" title:@"TABATA腹肌運動高階版" thumbHQ:@"http://img.youtube.com/vi/JOfNoK5yh6w/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=JOfNoK5yh6w"];
    
    YoutubeItem *item6 = [[YoutubeItem alloc] initWithId:@"5bDq0JPYe4U" title:@"鍛練超強核心，棒式、平板的三個進階動作" thumbHQ:@"http://img.youtube.com/vi/5bDq0JPYe4U/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=5bDq0JPYe4U"];
    
    YoutubeItem *item7 = [[YoutubeItem alloc] initWithId:@"Lqx4sqAPrrs" title:@"如何使用滾輪鍛練核心肌群" thumbHQ:@"http://img.youtube.com/vi/_mDqWuiEOy8/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=_mDqWuiEOy8"];
    
    YoutubeItem *item8 = [[YoutubeItem alloc] initWithId:@"Lqx4sqAPrrs" title:@"6個不同伏地挺身的變化式分享" thumbHQ:@"http://img.youtube.com/vi/E6fpOCdVmgw/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=E6fpOCdVmgw"];
    
    YoutubeItem *item9 = [[YoutubeItem alloc] initWithId:@"Lqx4sqAPrrs" title:@"臂熱健臂器做TABATA間歇訓練" thumbHQ:@"http://img.youtube.com/vi/yFA-GThdRU4/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=yFA-GThdRU4"];
    
    YoutubeItem *item10 = [[YoutubeItem alloc] initWithId:@"Qc7MjAGz534" title:@"練習正確深蹲姿勢，坐姿深蹲" thumbHQ:@"http://img.youtube.com/vi/Qc7MjAGz534/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=Qc7MjAGz534"];
    
    YoutubeItem *item11 = [[YoutubeItem alloc] initWithId:@"LvCO7TS0fBY" title:@"教你如何正確做波比跳 (Burpee)" thumbHQ:@"http://img.youtube.com/vi/LvCO7TS0fBY/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=LvCO7TS0fBY"];
    
    YoutubeItem *item12 = [[YoutubeItem alloc] initWithId:@"Ij0CMpuV374" title:@"TABATA四分鐘波比跳 (Burpee)" thumbHQ:@"http://img.youtube.com/vi/Ij0CMpuV374/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=Ij0CMpuV374"];
    
    YoutubeItem *item13 = [[YoutubeItem alloc] initWithId:@"foq_AWLeMZM" title:@"TABATA四分鐘深蹲運動(中階版)" thumbHQ:@"http://img.youtube.com/vi/foq_AWLeMZM/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=foq_AWLeMZM"];
    
    YoutubeItem *item14 = [[YoutubeItem alloc] initWithId:@"2K4HsFUZov4" title:@"TABATA四分鐘胸肌運動(基礎版)" thumbHQ:@"http://img.youtube.com/vi/2K4HsFUZov4/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=2K4HsFUZov4"];
    
    YoutubeItem *item15 = [[YoutubeItem alloc] initWithId:@"EkzDHg2IWjU" title:@"間歇運動騎飛輪車" thumbHQ:@"http://img.youtube.com/vi/EkzDHg2IWjU/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=EkzDHg2IWjU"];
    
    YoutubeItem *item16 = [[YoutubeItem alloc] initWithId:@"JigDTZw8KsM" title:@"Tabata 四分鐘間歇運動(溫和版)" thumbHQ:@"http://img.youtube.com/vi/JigDTZw8KsM/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=JigDTZw8KsM"];
    
    YoutubeItem *item17 = [[YoutubeItem alloc] initWithId:@"Uw7D3EVN1xM" title:@"TABATA 四分鐘間歇運動(中階版)" thumbHQ:@"http://img.youtube.com/vi/Uw7D3EVN1xM/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=Uw7D3EVN1xM"];
    
    YoutubeItem *item18 = [[YoutubeItem alloc] initWithId:@"DXvA7vdrQaA" title:@"Tabata 四分鐘高強度間歇運動(進階版)" thumbHQ:@"http://img.youtube.com/vi/DXvA7vdrQaA/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=DXvA7vdrQaA"];
    
    YoutubeItem *item19 = [[YoutubeItem alloc] initWithId:@"mGenx1BIwxo" title:@"TABATA四分鐘間歇運動(進階版)" thumbHQ:@"http://img.youtube.com/vi/mGenx1BIwxo/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=mGenx1BIwxo"];
    
    YoutubeItem *item20 = [[YoutubeItem alloc] initWithId:@"4-yrw3mExgM" title:@"TABATA四分鐘腹肌運動(中階版)" thumbHQ:@"http://img.youtube.com/vi/4-yrw3mExgM/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=4-yrw3mExgM"];
    
    YoutubeItem *item21 = [[YoutubeItem alloc] initWithId:@"LHizF916zjY" title:@"棒式 Plank 教學" thumbHQ:@"http://img.youtube.com/vi/LHizF916zjY/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=LHizF916zjY"];
    
    YoutubeItem *item22 = [[YoutubeItem alloc] initWithId:@"hqgygk_hYG8" title:@"教你如何正確做仰臥起坐 Crunch" thumbHQ:@"http://img.youtube.com/vi/hqgygk_hYG8/default.jpg" playerUrl:@"https://www.youtube.com/watch?v=hqgygk_hYG8"];
    
    [youtubeInfo addObject:item];
    [youtubeInfo addObject:item1];
    [youtubeInfo addObject:item2];
    [youtubeInfo addObject:item3];
    [youtubeInfo addObject:item4];
    [youtubeInfo addObject:item5];
    [youtubeInfo addObject:item6];
    [youtubeInfo addObject:item7];
    [youtubeInfo addObject:item8];
    [youtubeInfo addObject:item9];
    [youtubeInfo addObject:item10];
    [youtubeInfo addObject:item11];
    [youtubeInfo addObject:item12];
    [youtubeInfo addObject:item13];
    [youtubeInfo addObject:item14];
    [youtubeInfo addObject:item15];
    [youtubeInfo addObject:item16];
    [youtubeInfo addObject:item17];
    [youtubeInfo addObject:item18];
    [youtubeInfo addObject:item19];
    [youtubeInfo addObject:item20];
    [youtubeInfo addObject:item21];
    [youtubeInfo addObject:item22];
    
    return youtubeInfo;
    
}

- (void)youtubeClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSString *url = ((YoutubeItem *)[self.youtubeItems objectAtIndex:button.tag]).playerUrl;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
