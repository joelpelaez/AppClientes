//
//  AddClient.m
//  SqliteTest
//
//  Created by Joel Peláez Jorge on 24/01/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import "AddClient.h"
#import "AppDelegate.h"
#import "NSString+EmailValidation.h"

@interface AddClient () {
    sqlite3 *conn;
    NSMutableArray<NSMutableDictionary *> * data;
}

@property (weak) IBOutlet NSTextField *nombre;
@property (weak) IBOutlet NSTextField *apellidos;
@property (weak) IBOutlet NSTextField *telefono;
@property (weak) IBOutlet NSTextField *correo;
@property (weak) IBOutlet NSComboBox *categoria;

@end

@implementation AddClient

- (instancetype)init {
    self = [super init];
    [self loadCategories];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)loadCategories {
    AppDelegate *app = (AppDelegate *)[NSApplication sharedApplication].delegate;
    conn = [app sqlite3_conn];
    
    const char * select =   "SELECT id, nombre FROM categorias";
    data = [NSMutableArray<NSMutableDictionary *> array];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return;
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:6];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)] forKey:@"id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] forKey:@"nombre"];
        [data addObject:dict];
    }
    
    sqlite3_finalize(stmt);
}

- (IBAction)cancel:(id)sender {
    [self.window.sheetParent endSheet:self.window];
}

- (IBAction)addNewClient:(id)sender {
    const char *sql =   "INSERT INTO clientes (nombre, apellidos, telefono, "
                        "correo_electronico, categoria_id) VALUES (?, ?, ?, ?, ?)";
    
    AppDelegate *app = (AppDelegate *)[NSApplication sharedApplication].delegate;
    NSInteger pos = self.categoria.indexOfSelectedItem;
    conn = [app sqlite3_conn];
    
    // First check valid data
    if (![self.correo.stringValue isValidEmail]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Correo inválido"];
        [alert setInformativeText:@"Debe ingresar un correo con formato válido"];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];
        return;
    }
    
    // Check if email not exists in database
    
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, sql, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        goto end_without_stmt;
    }
    
    result = sqlite3_bind_text(stmt, 1, self.nombre.stringValue.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        goto end;
    }
    
    result = sqlite3_bind_text(stmt, 2, self.apellidos.stringValue.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        goto end;
    }
    
    result = sqlite3_bind_text(stmt, 3, self.telefono.stringValue.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        goto end;
    }
    
    result = sqlite3_bind_text(stmt, 4, self.correo.stringValue.UTF8String, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        goto end;
    }
    
    result = sqlite3_bind_int(stmt, 5, [data[pos][@"id"] intValue]);
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        goto end;
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Error: %s", sqlite3_errmsg(conn));
        goto end;
    }
    
end:
    sqlite3_finalize(stmt);
    
end_without_stmt:
    [self.window.sheetParent endSheet:self.window];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
    return data.count;
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    return data[index][@"nombre"];
}


@end
