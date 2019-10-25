//
//  MISVideoCache.m
//  MyCamera
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 mao. All rights reserved.
//

#import "MISVideoCache.h"
#import <CommonCrypto/CommonCrypto.h>

@interface MISVideoCache()
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@property (nonatomic, strong) NSFileManager *fileManager;

@end


@implementation MISVideoCache

/**
 *  唯一入口 共享的缓存（仅 disk）
 *
 *  @return single instace
 */
+ (MISVideoCache *)sharedCache {
	static id instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [self new];
	});
	return instance;
}

- (instancetype)init {
	if ((self = [super init])) {
		//默认目录
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		_diskCachePath  = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Cache"];
	}
	
	return self;
}

/**
 *  缓存视频数据
 *
 *  @param locaction 视频文件地址
 *  @param key  健
 */
- (void)moveVideoFileAtURL:(NSURL *)locaction
					forKey:(NSString *)key {
	if (!locaction) {
		return;
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:_diskCachePath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	
	//移动文件
	[[NSFileManager defaultManager] moveItemAtURL:locaction toURL:[self cacheFileURLForKey:key] error:nil];
}

/**
 *  视频文件是否已经缓存了
 *
 *  @param key 关健字 urlString
 */
- (BOOL)videoExistsForKey:(NSString *)key {
	NSString* path = [self cacheFilePathForKey:key];
	
	//使用默认 filemanage 去检查同步
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

/**
 *  视频文件Path
 *
 *  @param key 关健字 urlString
 *
 *  @return NSString
 */
- (NSString *)cacheFilePathForKey:(NSString *)key {
	NSString *filename = [self cachedFileNameForKey:key];
	filename = [filename stringByAppendingFormat:@".mp4"];
	return [self.diskCachePath stringByAppendingPathComponent:filename];
}

/**
 *  视频文件URL
 *
 *  @param key 关健字 urlString
 *
 *  @return NSString
 */
- (NSURL *)cacheFileURLForKey:(NSString *)key {
	return [NSURL fileURLWithPath:[self cacheFilePathForKey:key]];
}

/**
 *  清指定的缓存
 *
 *  @param key 健
 */
- (void)clearCacheForKey:(NSString *)key {
	NSString* path = [self cacheFilePathForKey:key];
	
	//写入文件
	if ([_fileManager fileExistsAtPath:path]) {
		[_fileManager removeItemAtPath:path error:nil];
	}
}

/**
 *  生成文件名
 *
 *  @param key 关健字 urlString
 *
 *  @return fileName
 */
- (NSString *)cachedFileNameForKey:(NSString *)key {
	const char *str = [key UTF8String];
	if (str == NULL) {
		str = "";
	}
	unsigned char r[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, (CC_LONG)strlen(str), r);
	NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
						  r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
	
	return filename;
}


@end
