//
//  Client.m
//  AppClientes
//
//  Created by Joel Peláez Jorge on 29/01/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import "Client.h"

@interface Client () {
    sqlite3 *conn;
}

@property (readwrite, strong) NSMutableArray<NSDictionary *> *data;

@end

@implementation Client

+ (instancetype)clientWithConnection:(sqlite3 *)conn {
    Client *client = [[self alloc] init];
    client->conn = conn;
    return client;
}

- (NSArray<NSDictionary *> *)fetchAllClients {
    const char * select =   "SELECT cl.id, cl.nombre, cl.apellidos, cl.telefono, "
    "cl.correo_electronico, cl.categoria_id, ca.nombre FROM clientes cl "
    "INNER JOIN categorias ca ON cl.categoria_id = ca.id";
    _data = [NSMutableArray<NSDictionary *> array];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:6];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)] forKey:@"cliente_id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] forKey:@"cliente_nombre"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)] forKey:@"cliente_apellidos"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)] forKey:@"cliente_telefono"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)] forKey:@"cliente_correo"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)] forKey:@"cliente_categoria_id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)] forKey:@"cliente_categoria"];
        [_data addObject:[dict copy]];
    }
    
    sqlite3_finalize(stmt);
    
    return [_data copy];
}

- (NSDictionary *)fetchClient:(int)idt {
    const char * select =   "SELECT cl.id, cl.nombre, cl.apellidos, cl.telefono, "
    "cl.correo_electronico, cl.categoria_id, ca.nombre FROM clientes cl "
    "INNER JOIN categorias ca ON cl.categoria_id = ca.id "
    "WHERE id = ?";
    
    NSMutableDictionary *dict = nil;
    _data = [NSMutableArray<NSDictionary *> array];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    result = sqlite3_bind_int(stmt, 1, idt);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        dict = [NSMutableDictionary dictionaryWithCapacity:6];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)] forKey:@"cliente_id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] forKey:@"cliente_nombre"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)] forKey:@"cliente_apellidos"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)] forKey:@"cliente_telefono"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)] forKey:@"cliente_correo"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)] forKey:@"cliente_categoria_id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)] forKey:@"cliente_categoria"];
    }
    
    sqlite3_finalize(stmt);
    
    return [dict copy];
}

- (NSArray<NSDictionary *> *)searchClients:(NSString *)lastname {
    const char * select =   "SELECT cl.id, cl.nombre, cl.apellidos, cl.telefono, "
    "cl.correo_electronico, cl.categoria_id, ca.nombre FROM clientes cl "
    "INNER JOIN categorias ca ON cl.categoria_id = ca.id "
    "WHERE cl.apellidos LIKE ?";
    _data = [NSMutableArray<NSDictionary *> array];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    result = sqlite3_bind_text(stmt, 1, lastname.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:6];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)] forKey:@"cliente_id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] forKey:@"cliente_nombre"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)] forKey:@"cliente_apellidos"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)] forKey:@"cliente_telefono"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)] forKey:@"cliente_correo"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)] forKey:@"cliente_categoria_id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)] forKey:@"cliente_categoria"];
        [_data addObject:[dict copy]];
    }
    
    sqlite3_finalize(stmt);
    
    return [_data copy];

}
@end
