//
//  ViewController.m
//  YRFileWatchDogDemo
//
//  Created by 王晓宇 on 14/12/17.
//  Copyright (c) 2014年 YueRuo. All rights reserved.
//

#import "ViewController.h"
#import "YRFileWatchDog.h"

@interface ViewController (){
    NSString *_testFilePath;
}
@property (strong,nonatomic) YRFileWatchDog *fileWatchDog;

@property (weak, nonatomic) IBOutlet UILabel *fileStatusLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _testFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"testFile"];
    
    
    __weak typeof(self) weakSelf = self;
    
    _fileWatchDog = [[YRFileWatchDog alloc]init];
    [_fileWatchDog setCheckTimeInterval:1];//设置1秒间隔
    [_fileWatchDog setFilePath:_testFilePath];
    [_fileWatchDog setFileWatchStartBlock:^(BOOL success) {
        NSLog(@"-->>start success=%d",success?1:0);
        if (success) {
            weakSelf.fileStatusLabel.text = @"开始监视文件状态";
        }else{
            weakSelf.fileStatusLabel.text = @"监视文件状态失败";
        }
    }];
    [_fileWatchDog setFileChangeBlock:^(NSString *filePath, YRFileChangeType changeType) {
        NSLog(@"-->>filePath=%@",filePath);
        switch (changeType) {
            case YRFileChangeTypeCreated:
                NSLog(@"文件被创建了");
                weakSelf.fileStatusLabel.text = @"发现文件被创建了";
                break;
            case YRFileChangeTypeModified:
                NSLog(@"--文件被修改了");
                weakSelf.fileStatusLabel.text = @"发现文件被修改了";
                break;
            case YRFileChangeTypeDeleted:
                NSLog(@"----文件被删除了");
                weakSelf.fileStatusLabel.text = @"发现文件被删除了";
                break;
            default:
                break;
        }
    }];
    [_fileWatchDog start];
}
- (IBAction)createFileEvent:(id)sender {
    NSData *data = [NSData data];
    [[NSFileManager defaultManager]createFileAtPath:_testFilePath contents:data attributes:nil];
}
- (IBAction)modifyFileEvent:(id)sender {
    NSData *data = [@"test " dataUsingEncoding:NSUTF8StringEncoding];

    NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:_testFilePath];
    if(outFile == nil){
        NSLog(@"文件不存在");
    }
    [outFile seekToEndOfFile];
    [outFile writeData:data];
    //关闭读写文件
    [outFile closeFile];
}
- (IBAction)deleteFileEvent:(id)sender {
    [[NSFileManager defaultManager]removeItemAtPath:_testFilePath error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
