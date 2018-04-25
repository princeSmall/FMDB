//
//  FMDBServer.h
//  FMDBDatabase
//
//  Created by 李敏 on 2018/4/20.
//  Copyright © 2018年 Tongle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMDBServer : NSObject

+ (FMDBServer *)sharedFMDBServer;
- (void)createFMDBTable:(NSString *)tableName;
- (void)insertData:(NSString *)tableName dataFromDictionary:(NSDictionary *)dic;
- (void)searchData:(NSString *)tableName;
- (void)searchData:(NSString *)tableName whereID:(NSInteger)ID;
- (void)delegateData:(NSString *)tableName;
- (void)delegateData:(NSString *)tableName whereID:(NSInteger)ID;
- (void)updateData:(NSString *)tableName setColumn:(NSString *)column forNew:(NSString *)n whereColumn:(NSString *)c;
@end
