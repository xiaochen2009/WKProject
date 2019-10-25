//
//  MISVideoDownloader.h
//  MyCamera
//
//  Created by Mao on 5/9/16.
//  Copyright © 2016 mao. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  下载进度回调
 *
 *  @param receivedSize 已收size
 *  @param expectedSize 指定size
 */
typedef void(^MISVideoDownloaderProgressBlock)(int64_t receivedSize, int64_t expectedSize);

/**
 *  下载完成回调
 *
 *  @param data     文件
 *  @param error    错误
 *  @param finished 完成标记
 */
typedef void(^MISVideoDownloaderCompletedBlock)(NSURL *location, NSError *error);


@interface MISVideoDownloader : NSObject

/**
 *  唯一入口
 *
 *  @return 单例
 */
+ (MISVideoDownloader *)sharedDownloader;


/**
 *  创建下载operation
 *
 *  @param url            传入URL
 *  @param progressBlock  进度回调
 *  @param completedBlock 完成回调
 *
 */
- (void )downloadVideoWithURL:(NSURL *)url
					 progress:(MISVideoDownloaderProgressBlock)progressBlock
					completed:(MISVideoDownloaderCompletedBlock)completedBlock;


/**
 *  取消 task
 *
 *  @param url 传入URL
 */
- (void)cancelTaskForURL:(NSURL *)url;


@end
