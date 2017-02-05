//
//  Category.m
//  AppClientes
//
//  Created by Joel Peláez Jorge on 04/02/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import "Category.h"

@interface Category () {
    sqlite3 *conn;
}

@end

@implementation Category

+ (instancetype)categoryWithConnection:(sqlite3 *)conn {
    Category *category = [[self alloc] init];
    category->conn = conn;
    return category;
}

- (NSArray<NSDictionary *> *)fetchAllCategories {
    const char * select =   "SELECT id, nombre FROM categorias";
    NSMutableArray<NSDictionary *> *data = [NSMutableArray<NSDictionary *> array];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)] forKey:@"id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] forKey:@"nombre"];
        [data addObject:[dict copy]];
    }
    
    sqlite3_finalize(stmt);
    return [data copy];
}

- (NSDictionary *)fetchCategory:(int)idt {
    const char * select =   "SELECT id, nombre FROM categorias WHERE id = ?";
    NSDictionary *data = nil;
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    result = sqlite3_bind_int(stmt, 1, idt);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error binding value: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)] forKey:@"id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] forKey:@"nombre"];
        data = [dict copy];
    }
    
    sqlite3_finalize(stmt);
    return data;
}

- (NSArray<NSDictionary *> *)searchCategory:(NSString *)name {
    const char * select =   "SELECT id, nombre FROM categorias WHERE nombre LIKE ?";
    NSMutableArray<NSDictionary *> *data = [NSMutableArray<NSDictionary *> array];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    result = sqlite3_bind_text(stmt, 1, name.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error binding value: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)] forKey:@"id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] forKey:@"nombre"];
        [data addObject:[dict copy]];
    }
    
    sqlite3_finalize(stmt);
    return [data copy];
}

- (BOOL)removeCategoryWithID:(int)idt {
    const char * select = "DELETE FROM categorias WHERE id = ?";
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return NO;
    }
    
    result = sqlite3_bind_int(stmt, 1, idt);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error deleting the data: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    sqlite3_finalize(stmt);
    return YES;
}

- (BOOL)updateCategoryWithID:(int)idt name:(NSString *)name {
    const char *update = "UPDATE categorias SET nombre = ? WHERE id = ?";
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, update, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error preparing the query: %s", sqlite3_errmsg(conn));
        return NO;
    }
    
    result = sqlite3_bind_text(stmt, 1, name.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error binding value: %s", sqlite3_errmsg(conn));
        return NO;
    }
    
    result = sqlite3_bind_int(stmt, 2, idt);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error binding value: %s", sqlite3_errmsg(conn));
        return NO;
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Error executing query: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    sqlite3_finalize(stmt);
    return YES;
}

- (BOOL)insertCategoryWithName:(NSString *)name {
    const char *insert = "INSERT INTO categorias (nombre) VALUES (?)";
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, insert, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error preparing query: %s", sqlite3_errmsg(conn));
        return NO;
    }
    
    result = sqlite3_bind_text(stmt, 1, name.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error binding value: %s", sqlite3_errmsg(conn));
        return NO;
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Error executing query: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    sqlite3_finalize(stmt);
    return YES;
}

@end
