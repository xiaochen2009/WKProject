//
//  MISVideoCache.h
//  MyCamera
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 mao. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  查找视频地址
 *
 *  @param videoURL 返回文件 URL
 */
typedef void(^MISVideoQueryCompletedBlock)(NSURL *videoURL);

@interface MISVideoCache : NSObject

/**
 *  唯一入口 共享的缓存（仅 disk）
 *
 *  @return single instace
 */
+ (MISVideoCache *)sharedCache;


/**
 *  缓存目录 默认（Documents/Cache）
 */
@property (nonatomic, copy) NSString* diskCachePath;


/**
 *  缓存视频数据
 *
 *  @param locaction 视频文件地址
 *  @param key  健
 */
- (void)moveVideoFileAtURL:(NSURL *)locaction
					forKey:(NSString *)key;


/**
 *  视频文件URL
 *
 *  @param key 关健字 urlString
 *
 *  @return NSString
 */
- (NSURL *)cacheFileURLForKey:(NSString *)key;

/**
 *  视频文件是否已经缓存了
 *
 *  @param key  健
 */
- (BOOL)videoExistsForKey:(NSString *)key;


/**
 *  清指定的缓存
 *
 *  @param key 健
 */
- (void)clearCacheForKey:(NSString *)key;


@end
