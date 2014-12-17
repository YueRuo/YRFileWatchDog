//
//  YRFileWatchDog.h
//  Mark
//
//  Created by 王晓宇 on 14/12/16.
//  Copyright (c) 2014年 王晓宇. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YRFileChangeType) {
    YRFileChangeTypeCreated,
    YRFileChangeTypeModified,
    YRFileChangeTypeDeleted,
};

/*!
 *	@brief	用于监视文件的变化，可监视文件的创建、删除、修改
 */
@interface YRFileWatchDog : NSObject


/*!
 *	@brief	检测的时间差,默认为1S
 */
@property (assign,nonatomic) NSTimeInterval checkTimeInterval;

/*!
 *	@brief	要监视的文件路径
 */
@property (strong,nonatomic) NSString *filePath;

@property (copy,nonatomic) void(^fileWatchStartBlock)(BOOL success);
@property (copy,nonatomic) void(^fileChangeBlock)(NSString *filePath,YRFileChangeType changeType);

-(void)setFileWatchStartBlock:(void (^)(BOOL success))fileWatchStartBlock;
-(void)setFileChangeBlock:(void (^)(NSString *filePath, YRFileChangeType changeType))fileChangeBlock;



/*!
 *	@brief	启动监视
 */
-(void)start;

-(void)stop;

@end
