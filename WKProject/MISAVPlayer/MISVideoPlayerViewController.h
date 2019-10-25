
/***********************************************************
 //  MISVideoPlayerViewController.h
 //  Mao Kebing
 //  Created by Edu on 13-7-25.
 //  Copyright (c) 2013 Eduapp. All rights reserved.
 ***********************************************************/

#import <UIKit/UIKit.h>

@interface MISVideoPlayerViewController : UIViewController

/**
 *  指定video 地址 本地 URL 或 网络 URL
 */
@property (nonatomic, copy) NSURL* videoURL;

/**
 *  锁定横屏显示
 */
@property (nonatomic) BOOL lockHorizontal;

@end
