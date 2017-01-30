//
//  Client.m
//  AppClientes
//
//  Created by Joel Peláez Jorge on 29/01/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import "Client.h"
#import "NSString+EmailValidation.h"

@interface Client () {
    sqlite3 *conn;
}

// Internal data array, used for data maganement.
@property (readwrite, strong) NSMutableArray<NSDictionary *> *data;

@end

@implementation Client

/**
 Create a new instance for clientes table in database.
 
 @param conn Current Sqlite connection.
 @return A new Client instance.
 */
+ (instancetype)clientWithConnection:(sqlite3 *)conn {
    Client *client = [[self alloc] init];
    client->conn = conn;
    return client;
}

/**
 Fetch all clients from the table. No uses any filter.
 
 @returns A NSArray with NSDictionaries with the data.
 */
- (NSArray<NSDictionary *> *)fetchAllClients {
    // Prepare the query
    const char * select =   "SELECT cl.id, cl.nombre, cl.apellidos, cl.telefono, "
    "cl.correo_electronico, cl.categoria_id, ca.nombre FROM clientes cl "
    "INNER JOIN categorias ca ON cl.categoria_id = ca.id";
    
    // Create a NSMutableArray.
    NSMutableArray<NSDictionary *> *data = [NSMutableArray<NSDictionary *> array];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    // Fetch all data and insert it in a NSMutableArray
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:6];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)] forKey:@"cliente_id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] forKey:@"cliente_nombre"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)] forKey:@"cliente_apellidos"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)] forKey:@"cliente_telefono"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)] forKey:@"cliente_correo"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)] forKey:@"cliente_categoria_id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)] forKey:@"cliente_categoria"];
        [data addObject:[dict copy]];
    }
    
    sqlite3_finalize(stmt);
    
    // return a static copy (NSArray) of the mutable array.
    return [data copy];
}


/**
 Fetch one client using the unique identifier.
 
 @param idt Identifier of the client
 @return A NSDictionary contained the data.
 */
- (NSDictionary *)fetchClient:(int)idt {
    const char * select =   "SELECT cl.id, cl.nombre, cl.apellidos, cl.telefono, "
    "cl.correo_electronico, cl.categoria_id, ca.nombre FROM clientes cl "
    "INNER JOIN categorias ca ON cl.categoria_id = ca.id "
    "WHERE id = ?";
    
    NSMutableDictionary *dict = nil;
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

- (NSDictionary *)searchWithEmail:(NSString *)email {
    const char * select =   "SELECT cl.id, cl.nombre, cl.apellidos, cl.telefono, "
    "cl.correo_electronico, cl.categoria_id, ca.nombre FROM clientes cl "
    "INNER JOIN categorias ca ON cl.categoria_id = ca.id "
    "WHERE cl.correo_electronico LIKE ?";
    
    NSMutableDictionary *dict = nil;
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return nil;
    }
    
    result = sqlite3_bind_text(stmt, 1, email.UTF8String, -1, NULL);
    
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
    if (!dict)
        return nil;
    
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

- (BOOL)removeClientWithID:(int)idt {
    const char * select = "DELETE FROM clientes WHERE id = ?";
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

- (BOOL)insertClientWithFirstname:(NSString *)fname lastname:(NSString *)lname phone:(NSString *)phone email:(NSString *)email category:(int)catid {
    const char *sql =   "INSERT INTO clientes (nombre, apellidos, telefono, "
    "correo_electronico, categoria_id) VALUES (?, ?, ?, ?, ?)";
    
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, sql, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return NO;
    }
    
    result = sqlite3_bind_text(stmt, 1, fname.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    result = sqlite3_bind_text(stmt, 2, lname.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    result = sqlite3_bind_text(stmt, 3, phone.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    result = sqlite3_bind_text(stmt, 4, email.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    result = sqlite3_bind_int(stmt, 5, catid);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Error: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    sqlite3_finalize(stmt);
    return YES;
}

- (BOOL)updateClientWithID:(int)idt firstname:(NSString *)fname lastname:(NSString *)lname phone:(NSString *)phone email:(NSString *)email category:(int)catid {
    const char *sql =   "UPDATE clientes SET nombre = ?, apellidos = ?, telefono = ?, "
    "correo_electronico = ?, categoria_id = ? WHERE id = ?";
    
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, sql, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return NO;
    }
    result = sqlite3_bind_text(stmt, 1, fname.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    result = sqlite3_bind_text(stmt, 2, lname.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    result = sqlite3_bind_text(stmt, 3, phone.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    result = sqlite3_bind_text(stmt, 4, email.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    result = sqlite3_bind_int(stmt, 5, catid);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    result = sqlite3_bind_int(stmt, 6, idt);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Error: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return NO;
    }
    
    sqlite3_finalize(stmt);
    return YES;
}

@end
