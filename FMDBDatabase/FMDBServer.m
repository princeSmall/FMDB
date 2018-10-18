//
//  FMDBServer.m
//  FMDBDatabase
//
//  Created by 李敏 on 2018/4/20.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "FMDBServer.h"
#import <FMDB/FMDB.h>
#import "Student.h"

#define TABLE  @"Student"
@interface FMDBServer()

//@property (nonatomic,strong)FMDatabase * database;
@property (nonatomic,strong)FMDatabaseQueue * queue;
@end

@implementation FMDBServer

#pragma mark - 单例
+ (FMDBServer *)sharedFMDBServer{
    static FMDBServer * server;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server = [[FMDBServer alloc]init];
    });
    return server;
}

#pragma mark - 建表

/**
 创建表

 @param tableName 要创建的表名字
 */
- (void)createFMDBTable:(NSString *)tableName{

    NSString *sqlitePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/SQLite.db"];
    self.queue = [FMDatabaseQueue databaseQueueWithPath:sqlitePath];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, age INTEGER,sex INTEGER, address VARCHAR);",tableName];
        [self fmdbExecute:sql FMDB:db];
    }];
    NSLog(@"数据库路径:%@",sqlitePath);

}

#pragma mark - 插入数据

/**
 插入数据

 @param tableName 要插入的表名字
 @param dic 将数据以字典的形式一个个插入
 */
- (void)insertData:(NSString *)tableName dataFromDictionary:(NSDictionary *)dic{

    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString * name = [dic objectForKey:@"name"];
        NSString * age = [dic objectForKey:@"age"];
        NSString * sex = [dic objectForKey:@"sex"];
        NSString * address = [dic objectForKey:@"address"];
        NSString * sql = [NSString stringWithFormat:@"INSERT INTO '%@' ('name', 'age', 'sex', 'address') VALUES ('%@', '%@', '%@','%@');",tableName,name,age,sex,address ];
        [self fmdbExecute:sql FMDB:db];
    }];
  
}
#pragma mark - 查询数据
/**
 查询表中所有数据

 @param tableName 要查询的表名字
 */
- (void)searchData:(NSString *)tableName{
    NSMutableArray * array = [NSMutableArray array];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableString * selectSql = [NSMutableString stringWithFormat:@"select * from %@ ", tableName];
        FMResultSet *s = [db executeQuery:selectSql];
        while  ([s next]) {
            Student * student = [[Student alloc]init];
            student.name = [s stringForColumn:@"name"];
            student.age = [s intForColumn:@"age"];
            student.address = [s stringForColumn:@"address"];
            student.sex = [s intForColumn:@"sex"];
            [array addObject:student];
        }
        NSLog(@"array --- %@",array);
    }];
   
}
/**
 条件查询

 @param tableName 要查询的表名字
 @param ID 根据唯一的主键ID
 */
- (void)searchData:(NSString *)tableName whereID:(NSInteger)ID{
    NSMutableArray * array = [NSMutableArray array];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableString * selectSql = [NSMutableString stringWithFormat:@"select * from %@ where id = %ld ", tableName,(long)ID];
        FMResultSet *s = [db executeQuery:selectSql];
        while  ([s next]) {
            Student * student = [[Student alloc]init];
            student.name = [s stringForColumn:@"name"];
            student.age = [s intForColumn:@"age"];
            student.address = [s stringForColumn:@"address"];
            student.sex = [s intForColumn:@"sex"];
            [array addObject:student];
        }
        NSLog(@"array --- %@",array);
    }];

}
#pragma mark - 删除数据
/**
 删除所有数据

 @param tableName 要删除的表名字
 */
- (void)delegateData:(NSString *)tableName{
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableString * deleteSql = [NSMutableString stringWithFormat:@"DELETE FROM %@ ",tableName];
        BOOL s = [db executeUpdate:deleteSql];
        if (s) {
            NSLog(@"删除成功");
        }else{
            NSLog(@"删除失败");
        }
    }];
    
}
/**
 条件删除

 @param tableName 要删除的表名字
 @param ID 根据唯一的主键ID
 */
- (void)delegateData:(NSString *)tableName whereID:(NSInteger)ID{
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableString * deleteSql = [NSMutableString stringWithFormat:@"DELETE FROM %@ where id = %ld ",tableName,ID];
        BOOL s = [db executeUpdate:deleteSql];
        if (s) {
            NSLog(@"删除成功");
        }else{
            NSLog(@"删除失败");
        }
    }];
}
#pragma mark - 更新数据

/**
 条件更新

 @param tableName 表名字
 @param column 要更改的属性名称，如name，age，sex...
 @param n 属性对应的新的名称，如name = Mary，age = 10，sex = 0...
 @param c 所根据的唯一主键，如ID...
 */
- (void)updateData:(NSString *)tableName setColumn:(NSString *)column forNew:(NSString *)n whereColumn:(NSString *)c{
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        [db beginTransaction];
        NSMutableString  * string = [NSMutableString stringWithFormat:@"UPDATE %@ SET %@ = ? where id = ?",tableName,column];
        BOOL s = [db executeUpdate:string,n,c];
        if (s) {
            NSLog(@"修改成功");
        }else{
            NSLog(@"修改失败");
        }
    }];
}

#pragma mark - 操作数据

/**
 操作结果判断

 @param sql 增删改查语句
 */
- (void)fmdbExecute:(NSString *)sql FMDB:(FMDatabase *)db{
//    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db executeUpdate:sql]) {
            NSLog(@"操作成功");
        }else{
            NSLog(@"操作失败 lastErrorMessage：%@，lastErrorCode：%d",db.lastErrorMessage,db.lastErrorCode);
        }
//    }];
}


@end
