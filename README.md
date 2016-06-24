# FMDB
//
//  SHDataBaseHandle.m
//  SmartHome
//
//  Created by tongle on 16/5/6.
//  Copyright © 2016年 sansi. All rights reserved.
//

#import "SHDataBaseHandle.h"

static SHDataBaseHandle *dataBaseHandle = nil;


@implementation SHDataBaseHandle

+ (SHDataBaseHandle *)shareDataBaseHandle {
    
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        
        dataBaseHandle = [[SHDataBaseHandle alloc] init];
    
    });
    return dataBaseHandle;

}

#//打开数据库
- (void)openSqlite {
    
    NSString *sqlitePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/SmartHome.db"];
    self.dataBase        = [FMDatabase databaseWithPath:sqlitePath];
    
    NSLog(@"数据库路径:%@",sqlitePath);
}

#//关闭数据库
- (void)closeSqlite {
    [self.dataBase close];
}

#//创建数据库表,表名为 %@
- (void)createSqliteTableWithTableName:(NSString *)tableName {
    
    if (!_dataBase) {
        [self openSqlite];
    }
    if ([_dataBase open]) {
        
        if ([tableName isEqualToString:@"router"]) {
            
            BOOL creatSql = [_dataBase executeUpdate:@"CREATE TABLE router(id Integer PRIMARY KEY AUTOINCREMENT, device_id NTEXT, name NTEXT, ip TEXT, software_ver TEXT, hardware_ver TEXT)"];
            
            if (creatSql) {
                NSLog(@"router表创建成功");
            }else{
                NSLog(@"router表创建失败或者已经存在");
            }
            
        }else if ([tableName isEqualToString:@"room"]) {
            
            BOOL creatSql = [_dataBase executeUpdate:@"CREATE TABLE room(id Integer PRIMARY KEY AUTOINCREMENT, name NTEXT, picture TEXT, selected_icon TEXT, unselected_icon TEXT)"];
            
            if (creatSql) {
                NSLog(@"room表创建成功");
            }else{
                NSLog(@"room表创建失败或者已经存在");
            }
            
        }else if ([tableName isEqualToString:@"group_table"]) {
            
            BOOL creatSql = [_dataBase executeUpdate:@"CREATE TABLE group_table(id INTEGER PRIMARY KEY AUTOINCREMENT, name NTEXT, device_type INTEGER, selected_icon TEXT, unselected_icon TEXT, room_id INTEGER, CONSTRAINT fk_group_table_room FOREIGN KEY (room_id) REFERENCES room(id))"];
            
            if (creatSql) {
                NSLog(@"group_table表创建成功");
            }else{
                NSLog(@"group_table表创建失败或者已经存在");
            }
        }else if ([tableName isEqualToString:@"lamp"]) {
            
            BOOL creatSql = [_dataBase executeUpdate:@"CREATE TABLE lamp(id Integer PRIMARY KEY AUTOINCREMENT, device_type INTEGER, mac TEXT, name NTEXT, room_id INTEGER, router_id INTEGER, group_id INTEGER, lamp_scene_id INTEGER, CONSTRAINT fk_lamp_room FOREIGN KEY (room_id) REFERENCES room(id), CONSTRAINT fk_lamp_router FOREIGN KEY (router_id) REFERENCES router(id), CONSTRAINT fk_lamp_group_table FOREIGN KEY (group_id) REFERENCES group_table(id), CONSTRAINT fk_lamp_lamp_scene FOREIGN KEY (lamp_scene_id) REFERENCES lamp_scene(id))"];
            
            if (creatSql) {
                NSLog(@"lamp表创建成功");
            }else{
                NSLog(@"lamp表创建失败或者已经存在");
            }

        }else if ([tableName isEqualToString:@"sensor"]) {
            
            BOOL creatSql = [_dataBase executeUpdate:@"CREATE TABLE sensor(id Integer PRIMARY KEY AUTOINCREMENT, type_number NTEXT, mac TEXT, name NTEXT, value REAL, room_id INTEGER, router_id INTEGER, CONSTRAINT fk_sensor_room FOREIGN KEY (room_id) REFERENCES room(id), CONSTRAINT fk_sensor_router FOREIGN KEY (router_id) REFERENCES router(id))"];
            
            if (creatSql) {
                NSLog(@"sensor表创建成功");
            }else{
                NSLog(@"sensor表创建失败或者已经存在");
            }
            
        }else if ([tableName isEqualToString:@"picture"]) {
            
            BOOL creatSql = [_dataBase executeUpdate:@"CREATE TABLE picture(id Integer PRIMARY KEY AUTOINCREMENT, picture_name NTEXT)"];
            
            if (creatSql) {
                NSLog(@"picture表创建成功");
            }else{
                NSLog(@"picture表创建失败或者已经存在");
            }
        }else if ([tableName isEqualToString:@"lamp_scene"]) {
            
            BOOL creatSql = [_dataBase executeUpdate:@"CREATE TABLE lamp_scene(id Integer PRIMARY KEY AUTOINCREMENT, name NTEXT, date_time TEXT, brightness_array BLOB, cct_array BLOB, rgbhex_array BLOB, selected_icon TEXT, unselected_icon TEXT, big_icon TEXT, is_selected INTEGER, is_on INTEGER, lamp_id_array BLOB)"];
            
            if (creatSql) {
                NSLog(@"lamp_scene表创建成功");
            }else{
                NSLog(@"lamp_scene表创建失败或者已经存在");
            }
            
        }
    }
}


#pragma mark===操作数据库表

#//插入一条数据
- (void)insertModel:(id)model forTableName:(NSString *)tableName {
    //安全判断:如果model为空,返回
    if (!model) {
        NSLog(@"传入的model为空！");
        return;
    }
    //FIXME: 打开数据库
    if (!_dataBase) {
        [self openSqlite];
    }
    
    if ([_dataBase open]) {
        if ([tableName isEqualToString:@"router"]) {
            
            SHRouterDBModel * newmodel = (SHRouterDBModel *)model;
            NSString *insertRouter     = [NSString stringWithFormat:@"insert into router(id, device_id, name, ip, software_ver, hardware_ver) values(?,?,?,?,?,?)"];
            BOOL insertSql             = [_dataBase executeUpdate:insertRouter,newmodel.ID, newmodel.device_id,newmodel.name, newmodel.ip, newmodel.software_ver, newmodel.hardware_ver];
            if (insertSql) {
                NSLog(@"router表插入成功");
            }else{
                NSLog(@"router表插入失败,信息：%@", [_dataBase lastError]);
            }
            
        }else if ([tableName isEqualToString:@"room"]) {
            
            SHRoomDBModel * newmodel = (SHRoomDBModel *)model;
            NSString *insertRoom     = [NSString stringWithFormat:@"insert into room(id, name, picture, selected_icon, unselected_icon) values(?,?,?,?,?)"];
            
            BOOL insertSql           = [_dataBase executeUpdate:insertRoom,newmodel.ID,newmodel.name, newmodel.picture, newmodel.selected_icon, newmodel.unselected_icon];
            if (insertSql) {
                NSLog(@"room表插入成功");
            }else{
                NSLog(@"room表插入失败");
            }
            
        }else if ([tableName isEqualToString:@"lamp"]) {
            
            SHLampDBModel * newmodel = (SHLampDBModel *)model;
            NSString *insertLamp     = [NSString stringWithFormat:@"insert into lamp(id, device_type, mac, name, room_id, router_id, group_id, lamp_scene_id) values(?,?,?,?,?,?,?,?)"];
            
            BOOL insertSql           = [_dataBase executeUpdate:insertLamp,newmodel.ID, [NSNumber numberWithInteger:newmodel.device_type],newmodel.mac, newmodel.name, [NSNumber numberWithInteger:newmodel.room_id], [NSNumber numberWithInteger:newmodel.router_id], [NSNumber numberWithInteger:newmodel.group_id], [NSNumber numberWithInteger:newmodel.lamp_scene_id]];
            if (insertSql) {
                NSLog(@"lamp表插入成功");
            }else{
                NSLog(@"lamp表插入失败");
            }
            
        }else if ([tableName isEqualToString:@"sensor"]) {
            
            SHSensorDBModel * newmodel = (SHSensorDBModel *)model;
            NSString *insertSensor     = [NSString stringWithFormat:@"insert into sensor(id, type_number, mac, name, value, room_id, router_id) values(?,?,?,?,?,?,?)"];
            
            BOOL insertSql             = [_dataBase executeUpdate:insertSensor,newmodel.ID, newmodel.type_number,newmodel.mac, newmodel.name, [NSNumber numberWithFloat:newmodel.value], [NSNumber numberWithInteger:newmodel.room_id], [NSNumber numberWithInteger:newmodel.router_id]];
            if (insertSql) {
                NSLog(@"sensor表插入成功");
            }else{
                NSLog(@"sensor表插入失败");
            }
        }else if ([tableName isEqualToString:@"picture"]) {
            
            SHPictureDBModel * newmodel = (SHPictureDBModel *)model;
            NSString *insertSensor     = [NSString stringWithFormat:@"insert into picture(id, picture_name) values(?,?)"];
            
            BOOL insertSql             = [_dataBase executeUpdate:insertSensor,newmodel.ID, newmodel.pictureName];
            if (insertSql) {
                NSLog(@"picture表插入成功");
            }else{
                NSLog(@"picture表插入失败");
            }
        }else if ([tableName isEqualToString:@"group_table"]) {
            
            SHGroupDBModel * newmodel = (SHGroupDBModel *)model;
            NSString *insertGroup     = [NSString stringWithFormat:@"insert into group_table(id, name, device_type, selected_icon, unselected_icon, room_id) values(?,?,?,?,?,?)"];
            
            BOOL insertSql           = [_dataBase executeUpdate:insertGroup, newmodel.ID, newmodel.name, [NSNumber numberWithInteger:newmodel.device_type], newmodel.selected_icon, newmodel.unselected_icon, [NSNumber numberWithInteger:newmodel.room_id]];
            if (insertSql) {
                NSLog(@"group_table表插入成功");
            }else{
                NSLog(@"group_table表插入失败");
            }
        }else if ([tableName isEqualToString:@"lamp_scene"]) {
            
            SHLampSceneDBModel * newmodel = (SHLampSceneDBModel *)model;
            NSString *insertScene         = [NSString stringWithFormat:@"insert into lamp_scene(id, name, date_time, brightness_array, cct_array, rgbhex_array, selected_icon, unselected_icon, big_icon, is_selected, is_on, lamp_id_array) values(?,?,?,?,?,?,?,?,?,?,?,?)"];
            
            NSData *brightnessArrayData = [NSKeyedArchiver archivedDataWithRootObject:newmodel.brightness_array];
            NSData *cctArrayData        = [NSKeyedArchiver archivedDataWithRootObject:newmodel.cct_array];
            NSData *rgbhexArrayData     = [NSKeyedArchiver archivedDataWithRootObject:newmodel.rgbhex_array];
            NSData *lampidArrayData     = [NSKeyedArchiver archivedDataWithRootObject:newmodel.lamp_id_array];
            
            BOOL insertSql                = [_dataBase executeUpdate:insertScene, newmodel.ID, newmodel.name, newmodel.date_time, brightnessArrayData, cctArrayData, rgbhexArrayData, newmodel.selected_icon, newmodel.unselected_icon, newmodel.big_icon, [NSNumber numberWithBool:newmodel.is_selected], [NSNumber numberWithBool:newmodel.is_on], lampidArrayData];
            if (insertSql) {
                NSLog(@"lamp_scene表插入成功");
            }else{
                NSLog(@"lamp_scene表插入失败");
            }
        }

    }
}

#//条件删除数据

- (void)deleteWhereSQLstring:(NSString *)string forTableName:(NSString *)tableName {
    
    if (!_dataBase) {
        [self openSqlite];
    }
    if ([_dataBase open]) {
        
        NSMutableString *deleteSql = [NSMutableString stringWithFormat:@"delete from %@ ", tableName];
        if (string.length > 0) {
            [deleteSql appendString:string];
        }else {
            NSLog(@"ERROR: WhereSQLstring");
        }
        
        BOOL deleteModel = [_dataBase executeUpdate:deleteSql];
        
        if (deleteModel) {
            NSLog(@"%@表删除%@成功", tableName, string);
        }else{
            NSLog(@"%@表删除%@失败", tableName, string);
        }
    }
}

#//删除所有数据

- (void)deleteForTableName:(NSString *)tableName {
    
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@",tableName];
    BOOL deleteModel = [_dataBase executeUpdate:deleteSql];

    if (deleteModel) {
        NSLog(@"%@表所有数据删除成功",tableName);
    }else{
        NSLog(@"%@表所有数据删除失败",tableName);
    }
}

#//条件修改数据
//update 'studentInfo' set ‘name’ = ‘WH’ where sid = 1;

- (void)updateTableSetSQLstring:(NSString *)string forTableName:(NSString *)tableName {
    
    NSString *updateSql = [NSString stringWithFormat:@"update %@ %@;", tableName, string];
    //[updateSql stringByAppendingString:string];
    BOOL updateModel    = [_dataBase executeUpdate:updateSql];
    
    if (updateModel) {
        NSLog(@"修改表%@成功", tableName);
    }else {
        NSLog(@"修改表%@出错，%@", tableName, [_dataBase lastError]);
    }
}

#//修改数据库表
//update %@ set %@ = ? where %@ = ?;

- (void)updateForTableName:(NSString *)tableName SetNewColumn:(NSString *)newColumn EqualToNewValue:(id)newValue WhereColumn:(NSString *)column EqualToValue:(id)value {
    
    if ([newValue isKindOfClass:[NSArray class]] || [newValue isKindOfClass:[NSMutableArray class]]) {
        newValue = [NSKeyedArchiver archivedDataWithRootObject:newValue];
    }

    NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?;", tableName,newColumn, column];

    BOOL updateModel    = [_dataBase executeUpdate:updateSql, newValue, value];
    
    if (updateModel) {
        NSLog(@"修改表%@成功", tableName);
    }
    
    else {
       NSLog(@"修改表%@出错，%@", tableName, [_dataBase lastError]);
    }
}


#//条件查询表中数据
- (NSMutableArray *)selectWhereSQLstring:(NSString *)string forTableName:(NSString *)tableName {
    
    NSMutableArray *modelArray = [NSMutableArray array];
    
    if ([_dataBase open]) {
        //FIXME: 空格
        NSMutableString *selectSql    = [NSMutableString stringWithFormat:@"select * from %@ ", tableName];
        [selectSql appendString:string];
        NSLog(@"------%@",selectSql);
        
        FMResultSet *resultSet = [_dataBase executeQuery:selectSql];
        
        if ([tableName isEqualToString:@"router"]) {
            while ([resultSet next]) {
                
                SHRouterDBModel *routerModel = [[SHRouterDBModel alloc] init];
                routerModel.ID               = [resultSet intForColumn:@"id"];
                routerModel.device_id        = [resultSet stringForColumn:@"device_id"];
                routerModel.name             = [resultSet stringForColumn:@"name"];
                routerModel.ip               = [resultSet stringForColumn:@"ip"];
                routerModel.software_ver     = [resultSet stringForColumn:@"software_ver"];
                routerModel.hardware_ver     = [resultSet stringForColumn:@"hardware_ver"];
                [modelArray addObject:routerModel];
            }
          
    
        }
        
        else if ([tableName isEqualToString:@"room"]) {
        
            while ([resultSet next]) {
                
                SHRoomDBModel *roomModel  = [[SHRoomDBModel alloc] init];
                roomModel.ID              = [resultSet intForColumn:@"id"];
                roomModel.name            = [resultSet stringForColumn:@"name"];
                roomModel.picture         = [resultSet stringForColumn:@"picture"];
                roomModel.selected_icon   = [resultSet stringForColumn:@"selected_icon"];
                roomModel.unselected_icon = [resultSet stringForColumn:@"unselected_icon"];
                [modelArray addObject:roomModel];
            }
        }
        
        else if ([tableName isEqualToString:@"lamp"]) {
        
            while ([resultSet next]) {
                
                SHLampDBModel *lampModel = [[SHLampDBModel alloc] init];
                lampModel.ID             = [resultSet intForColumn:@"id"];
                lampModel.device_type    = [resultSet intForColumn:@"device_type"];
                lampModel.mac            = [resultSet stringForColumn:@"mac"];
                lampModel.name           = [resultSet stringForColumn:@"name"];
                lampModel.room_id        = [resultSet intForColumn:@"room_id"];
                lampModel.router_id      = [resultSet intForColumn:@"router_id"];
                lampModel.group_id       = [resultSet intForColumn:@"group_id"];
                lampModel.lamp_scene_id  = [resultSet intForColumn:@"lamp_scene_id"];
                [modelArray addObject:lampModel];
            }
        }
        
        else if ([tableName isEqualToString:@"sensor"]) {
        
            while ([resultSet next]) {
                
                SHSensorDBModel *sensorModel = [[SHSensorDBModel alloc] init];
                sensorModel.ID               = [resultSet intForColumn:@"id"];
                sensorModel.type_number      = [resultSet stringForColumn:@"type_number"];
                sensorModel.mac              = [resultSet stringForColumn:@"mac"];
                sensorModel.name             = [resultSet stringForColumn:@"name"];
                sensorModel.value            = [resultSet doubleForColumn:@"value"];
                sensorModel.room_id          = [resultSet intForColumn:@"room_id"];
                sensorModel.router_id        = [resultSet intForColumn:@"router_id"];
                [modelArray addObject:sensorModel];
            }
        }
        
        else if ([tableName isEqualToString:@"picture"]) {
        
            while ([resultSet next]) {
                
                SHPictureDBModel *sensorModel = [[SHPictureDBModel alloc] init];
                sensorModel.ID               = [resultSet intForColumn:@"id"];
                sensorModel.pictureName      = [resultSet stringForColumn:@"picture_name"];
                [modelArray addObject:sensorModel];
            }
        }
        
        else if ([tableName isEqualToString:@"group_table"]) {
        
            while ([resultSet next]) {
                
                SHGroupDBModel *groupModel = [[SHGroupDBModel alloc] init];
                groupModel.ID              = [resultSet intForColumn:@"id"];
                groupModel.name            = [resultSet stringForColumn:@"name"];
                groupModel.device_type     = [resultSet intForColumn:@"device_type"];
                groupModel.selected_icon   = [resultSet stringForColumn:@"selected_icon"];
                groupModel.unselected_icon = [resultSet stringForColumn:@"unselected_icon"];
                groupModel.room_id         = [resultSet intForColumn:@"room_id"];

                [modelArray addObject:groupModel];
            }
        }
        
        else if ([tableName isEqualToString:@"lamp_scene"]) {
           
            while ([resultSet next]) {
                
                SHLampSceneDBModel *sceneModel = [[SHLampSceneDBModel alloc] init];
                sceneModel.ID                  = [resultSet intForColumn:@"id"];
                sceneModel.name                = [resultSet stringForColumn:@"name"];
                sceneModel.date_time           = [resultSet stringForColumn:@"date_time"];
                NSData *brightnessArrayData    = [resultSet dataForColumn:@"brightness_array"];
                sceneModel.brightness_array    = [NSKeyedUnarchiver unarchiveObjectWithData:brightnessArrayData];
                NSData *cctArrayData           = [resultSet dataForColumn:@"cct_array"];
                sceneModel.cct_array          = [NSKeyedUnarchiver unarchiveObjectWithData:cctArrayData];
                sceneModel.rgbhex_array        = [NSKeyedUnarchiver unarchiveObjectWithData:[resultSet dataForColumn:@"rgbhex_array"]];
                sceneModel.selected_icon       = [resultSet stringForColumn:@"selected_icon"];
                sceneModel.unselected_icon     = [resultSet stringForColumn:@"unselected_icon"];
                sceneModel.big_icon            = [resultSet stringForColumn:@"big_icon"];
                sceneModel.is_selected         = [resultSet boolForColumn:@"is_selected"];
                sceneModel.is_on               = [resultSet boolForColumn:@"is_on"];
                NSData *lampidArrayData        = [resultSet dataForColumn:@"lamp_id_array"];
                sceneModel.lamp_id_array       = [NSKeyedUnarchiver unarchiveObjectWithData:lampidArrayData];
                [modelArray addObject:sceneModel];
            }
        }
    }
   
    NSLog(@"查询%@表成功，%ld条数据", tableName, modelArray.count);
   
    return modelArray;
}


#//查询表中所有数据
- (NSMutableArray *)selectAllForTableName:(NSString *)tableName {
    
    NSMutableArray *arrays = [self selectWhereSQLstring:@"" forTableName:tableName];
   
    //[self closeSqlite];
   
    return arrays;
}

@end

