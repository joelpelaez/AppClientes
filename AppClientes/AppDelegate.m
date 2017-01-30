//
//  AppDelegate.m
//  SqliteTest
//
//  Created by Joel Peláez Jorge on 23/01/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import "AppDelegate.h"
#import "NSFileManager+AppSupport.h"
#import "Client.h"
#import "AddClient.h"
#import "AddCategory.h"
#import "EditClient.h"

@interface AppDelegate () {
    int numrows;
    NSMutableArray<NSMutableDictionary *> *data;
    NSMutableArray<NSMutableDictionary *> *catData;
    Client *clients;
    AddClient *addClient;
    EditClient *editClient;
    AddCategory *addCategory;
}

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSWindow *catWindow;
@property (weak) IBOutlet NSTableView *catTableView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSTextField *catTextField;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSString *dir = [[NSFileManager defaultManager] applicationSupportDirectory];
    NSString *db = [dir stringByAppendingPathComponent:@"clients.db"];
    
    int result = sqlite3_open_v2(db.UTF8String, &conn, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error opening database: %s", sqlite3_errmsg(conn));
    }
    
    clients = [Client clientWithConnection:conn];
    [self createDatabase];
    [self mainQuery];
    [self.tableView setDataSource:self];
    [self.catTableView setDataSource:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    sqlite3_close_v2(conn);
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

#pragma mark - NSTableViewDataSource

/**
 * Return data for the tableView, this data source is attached to two NSTableViews.
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.tableView)
        return data.count;
    else
        return catData.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.tableView)
        return data[row][tableColumn.identifier];
    else
        return catData[row][tableColumn.identifier];
}

#pragma mark Eventos

- (IBAction)showCategories:(id)sender {
    [self categoryMainQuery];
    [self.catTableView reloadData];
    [self.catWindow makeKeyAndOrderFront:self];
}

- (IBAction)showClients:(id)sender {
    [self mainQuery];
    [self.tableView reloadData];
    [self.window makeKeyAndOrderFront:self];
}

- (IBAction)searchClient:(id)sender {
    const char *p = self.textField.stringValue.UTF8String;
    [self searchQuery:p];
    [self.tableView reloadData];
}

- (IBAction)searchCategory:(id)sender {
    const char *p = self.textField.stringValue.UTF8String;
    [self categorySearchQuery:p];
    [self.catTableView reloadData];
}

- (IBAction)allClients:(id)sender {
    [self mainQuery];
    [self.tableView reloadData];
}

- (IBAction)allCategories:(id)sender {
    [self categoryMainQuery];
    [self.catTableView reloadData];
}

- (IBAction)deleteClient:(id)sender {
    NSInteger row = self.tableView.selectedRow;
    if (row == -1)
        return;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Eliminar"];
    [alert addButtonWithTitle:@"Cancelar"];
    [alert setMessageText:@"¿Desea eliminar al cliente?"];
    [alert setInformativeText:@"Los cambios no pueden deshacerse"];
    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        [self deleteRow:[data[row][@"cliente_id"] intValue]];
        [self mainQuery];
        [self.tableView reloadData];
    }
}

- (IBAction)deleteCategory:(id)sender {
    NSInteger row = self.catTableView.selectedRow;
    if (row == -1)
        return;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Eliminar"];
    [alert addButtonWithTitle:@"Cancelar"];
    [alert setMessageText:@"¿Desea eliminar la categoria?"];
    [alert setInformativeText:@"Los cambios no pueden deshacerse"];
    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        [self deleteRow:[catData[row][@"ID"] intValue]];
        [self categoryMainQuery];
        [self.catTableView reloadData];
    }
}

- (IBAction)addClient:(id)sender {
    if (!addClient)
        addClient = [[AddClient alloc] init];
    
    // If the window is a active sheet, make it front.
    if (addClient.window.isVisible) {
        [addClient.window makeKeyAndOrderFront:self];
        return;
    }
    
    if ([[NSBundle mainBundle] loadNibNamed:@"AddClient" owner:addClient topLevelObjects:nil] != YES) {
        NSLog(@"Error loading");
    }
    
    NSWindow *currentWindow = [[NSApplication sharedApplication] keyWindow];
    [currentWindow beginSheet:addClient.window completionHandler:^(NSModalResponse returnCode) {
        if (self.window.isVisible) {
            [self mainQuery];
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)addCategory:(id)sender {
    if (!addCategory)
        addCategory = [[AddCategory alloc] init];
    
    if (addCategory.window.isVisible) {
        [addCategory.window makeKeyAndOrderFront:self];
        return;
    }
    
    if ([[NSBundle mainBundle] loadNibNamed:@"AddCategory" owner:addCategory topLevelObjects:nil] != YES) {
        NSLog(@"Error loading nib");
    }
    
    NSWindow *currentWindow = [[NSApplication sharedApplication] keyWindow];
    [currentWindow beginSheet:addCategory.window completionHandler:^(NSModalResponse returnCode) {
        if (self.catWindow.isVisible) {
            [self categoryMainQuery];
            [self.catTableView reloadData];
        }
    }];
}

- (IBAction)editClient:(id)sender {
    NSInteger row = self.tableView.selectedRow;
    if (row == -1)
        return;
    int idt = [data[row][@"ID"] intValue];
    if (!editClient)
        editClient = [[EditClient alloc] initWithID:idt];
    if ([[NSBundle mainBundle] loadNibNamed:@"EditClient" owner:editClient topLevelObjects:nil] != YES) {
        NSLog(@"Error loading nib");
    }
    [self.window beginSheet:editClient.window completionHandler:^(NSModalResponse returnCode) {
        if (self.window.isVisible) {
            [self mainQuery];
            [self.tableView reloadData];
        }
    }];
    editClient.nombre.stringValue = data[row][@"cliente_nombre"];
    editClient.apellidos.stringValue = data[row][@"cliente_apellidos"];
    editClient.telefono.stringValue = data[row][@"cliente_telefono"];
    editClient.correo.stringValue = data[row][@"cliente_correo"];
    [editClient setCategoriaID:[data[row][@"cliente_categoria_id"] intValue]];
}

#pragma mark Manejo de la base de datos

- (sqlite3 *)sqlite3_conn {
    return conn;
}

- (void)createDatabase {
    const char * tablas =   "PRAGMA foreign_keys=ON;"
                            "CREATE TABLE IF NOT EXISTS categorias ("
                            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                            "nombre VARCHAR(40) NOT NULL UNIQUE);"
                            "CREATE TABLE IF NOT EXISTS clientes ("
                            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                            "nombre VARCHAR(40) NOT NULL, "
                            "apellidos VARCHAR(40) NOT NULL, "
                            "telefono VARCHAR(12) NOT NULL, "
                            "correo_electronico VARCHAR(30) NOT NULL UNIQUE, "
                            "categoria_id INTEGER NOT NULL, "
                            "FOREIGN KEY (categoria_id) REFERENCES categorias (id) ON DELETE NO ACTION ON UPDATE NO ACTION);"
                            "INSERT INTO categorias (id, nombre) SELECT 1, 'General' WHERE NOT EXISTS "
                            "(SELECT 1 FROM categorias WHERE id = 1)";
    char *err;
    
    int result = sqlite3_exec(conn, tablas, NULL, NULL, &err);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error preparing database: %s", err);
    }
    
}

#pragma mark Manejo de clientes

- (void)mainQuery {
    data = [clients fetchAllClients];
}

- (void)searchQuery:(const char *)search {
    const char * select =   "SELECT cl.id, cl.nombre, cl.apellidos, cl.telefono, "
                            "cl.correo_electronico, cl.categoria_id, ca.nombre FROM clientes cl "
                            "INNER JOIN categorias ca ON cl.categoria_id = ca.id "
                            "WHERE apellidos LIKE ?";
    data = [NSMutableArray<NSMutableDictionary *> array];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);

    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return;
    }
    
    result = sqlite3_bind_text(stmt, 1, search, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return;
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
        [data addObject:dict];
    }
    
    sqlite3_finalize(stmt);
}

- (void)deleteRow:(int)idt {
    const char * select =   "DELETE FROM clientes WHERE id = ?";
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return;
    }
    
    result = sqlite3_bind_int(stmt, 1, idt);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error deleting the data: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return;
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return;
    }
    
    sqlite3_finalize(stmt);
}


#pragma mark Manejo de categorias

- (void)categoryMainQuery {
    const char * select =   "SELECT c.id, c.nombre FROM categorias c";
    catData = [NSMutableArray<NSMutableDictionary *> array];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return;
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:6];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)] forKey:@"categoria_id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] forKey:@"categoria_nombre"];
        [catData addObject:dict];
    }
    
    sqlite3_finalize(stmt);
}

- (void)categorySearchQuery:(const char *)search {
    const char * select =   "SELECT c.id, c.nombre FROM categorias c WHERE c.nombre LIKE ?";
    catData = [NSMutableArray<NSMutableDictionary *> array];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return;
    }
    
    result = sqlite3_bind_text(stmt, 1, search, -1, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return;
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:6];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)] forKey:@"categoria_id"];
        [dict setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] forKey:@"categoria_nombre"];
        [catData addObject:dict];
    }
    
    sqlite3_finalize(stmt);
}

- (void)categoryDeleteRow:(int)idt {
    const char * select =   "DELETE FROM categorias WHERE id = ?";
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(conn, select, -1, &stmt, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        return;
    }
    
    result = sqlite3_bind_int(stmt, 1, idt);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error deleting the data: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return;
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Error quering the table: %s", sqlite3_errmsg(conn));
        sqlite3_finalize(stmt);
        return;
    }
    
    sqlite3_finalize(stmt);
}



@end
