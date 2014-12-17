//
//  YRFileWatchDog.m
//  Mark
//
//  Created by 王晓宇 on 14/12/16.
//  Copyright (c) 2014年 王晓宇. All rights reserved.
//

#import "YRFileWatchDog.h"

@interface YRFileWatchDog (){
    dispatch_source_t timer;
}
@property (assign,nonatomic) BOOL inProgress;
@property (strong,nonatomic) NSDate *lastMofiyDate;
@property (assign,nonatomic) YRFileChangeType fileChangeType;

@end

@implementation YRFileWatchDog

-(instancetype)init{
    if (self=[super init]) {
        _checkTimeInterval = 1;
    }
    return self;
}



-(void)start{
    if (!_filePath) {
        if (self.fileWatchStartBlock) {
            self.fileWatchStartBlock(false);
        }
        return;
    }
    NSError *error;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:&error];
    if (!error) {
        _lastMofiyDate = [attributes fileModificationDate];
    }else{
        _fileChangeType = YRFileChangeTypeDeleted;
    }
    
    if (self.fileWatchStartBlock) {
        self.fileWatchStartBlock(true);
    }
    _inProgress = true;
    
    //第一种 每一秒执行一次（重复性）
    double delayInSeconds = _checkTimeInterval;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(timer, ^{
        if (_inProgress) {
            [self check];
        }
    });
    dispatch_resume(timer);
}

-(void)stop{
    _inProgress = false;
    dispatch_source_cancel(timer);
}


-(void)check{
    BOOL findChange = false;
    BOOL fileExsit = [[NSFileManager defaultManager]fileExistsAtPath:_filePath];
    if (fileExsit) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil];
        NSDate *date = [attributes fileModificationDate];
        if (_fileChangeType==YRFileChangeTypeDeleted) {
            _fileChangeType = YRFileChangeTypeCreated;
            _lastMofiyDate = date;
            findChange = true;
        }else{
            if (date&&![_lastMofiyDate isEqualToDate:date]) {
                _lastMofiyDate = date;
                _fileChangeType = YRFileChangeTypeModified;
                findChange = true;
            }
        }
    }else{
        if (_fileChangeType!=YRFileChangeTypeDeleted) {
            _fileChangeType = YRFileChangeTypeDeleted;
            findChange = true;
        }
    }
    if (findChange&&self.fileChangeBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fileChangeBlock(_filePath,_fileChangeType);
        });
    }
}

@end
