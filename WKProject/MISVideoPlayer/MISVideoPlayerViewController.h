
/***********************************************************
 //  MISVideoPlayerViewController.h
 //  Mao Kebing
 //  Created by Edu on 13-7-25.
 //  Copyright (c) 2013 Eduapp. All rights reserved.
 ***********************************************************/

#import <UIKit/UIKit.h>

@interface MISVideoPlayerViewController : UIViewController

/**
 *  指定video 本地URL 或 网络URL
 */
@property (nonatomic, copy) NSURL* videoURL;


/**
 *  视频的首张图片 作为占位等侍图
 */
@property (nonatomic, copy) UIImage* placeholder;


/**
 *  视频的首张图片URL 作为占位等侍图
 */
@property (nonatomic, copy) NSURL* placeholderURL;

/**
 *  锁定横屏显示
 */
@property (nonatomic) BOOL lockHorizontal;


/**
 *  用于预览
 */
@property (nonatomic) BOOL useForPreview;

/**
 *  删除项目的回调-用于预览时
 */
@property (nonatomic, copy)void(^deleteBlock)(void);

/**
 *  调用样例：
 *
 *  MISVideoPlayerViewController* controller =  [[MISVideoPlayerViewController alloc] init];
 *	controller.videoURLString = @"https://git.oschina.net/maokebing/ipa/raw/master/demo.mp4";
 *	controller.placeholder = [UIImage imageNamed:@"1.jpg"]; //指定第一帧图，或别的默认图
 *	[self presentViewController:controller animated:NO completion:nil];  //不要加动画
 *
 */

@end
