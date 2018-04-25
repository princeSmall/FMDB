//
//  ViewController.m
//  FMDBDatabase
//
//  Created by 李敏 on 2018/4/18.
//  Copyright © 2018年 Tongle. All rights reserved.
//

#import "ViewController.h"
#import "FMDBServer.h"

#define N  @"NewStudent"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    FMDBServer * fmdb = [FMDBServer sharedFMDBServer];
 
    [fmdb createFMDBTable:N];
    NSDictionary * dic = @{
                           @"name":@"小王",
                           @"age":@"12",
                           @"sex":@"1",
                           @"address":@"2222222"
                           };
    [fmdb insertData:N dataFromDictionary:dic];
    [fmdb searchData:N];
    [fmdb updateData:N setColumn:@"name" forNew:@"小子" whereColumn:@"2"];
    [fmdb delegateData:N whereID:1];
    [fmdb searchData:N whereID:2];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
