//
//  Student.h
//  FMDBDatabase
//
//  Created by 李敏 on 2018/4/25.
//  Copyright © 2018年 Tongle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject
@property (nonatomic , strong)NSString * name;
@property (nonatomic , strong)NSString * address;
@property (nonatomic , assign)NSInteger age;
@property (nonatomic , assign)NSInteger sex;

@end
