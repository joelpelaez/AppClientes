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
#import "Category.h"
#import "AddClient.h"
#import "AddCategory.h"
#import "EditClient.h"
#import "EditCategory.h"

@interface AppDelegate () {
    int numrows;
    NSArray<NSDictionary *> *data;
    NSArray<NSDictionary *> *catData;
    Client *clients;
    Category *categories;
    AddClient *addClient;
    EditClient *editClient;
    AddCategory *addCategory;
    EditCategory *editCategory;
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
    categories = [Category categoryWithConnection:conn];
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
    [self searchQuery:self.textField.stringValue];
    [self.tableView reloadData];
}

- (IBAction)searchCategory:(id)sender {
    [self categorySearchQuery:self.catTextField.stringValue];
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
        [self categoryDeleteRow:[catData[row][@"id"] intValue]];
        [self categoryMainQuery];
        [self.catTableView reloadData];
    }
}

- (IBAction)addClient:(id)sender {
    if (!addClient) {
        addClient = [[AddClient alloc] initWithClient:clients];
        
        if ([[NSBundle mainBundle] loadNibNamed:@"AddClient" owner:addClient topLevelObjects:nil] != YES) {
            NSLog(@"Error loading");
        }
    } else
        [addClient reload];
    
    // If the window is a active sheet, make it front.
    if (addClient.window.isVisible) {
        [addClient.window makeKeyAndOrderFront:self];
        return;
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
    if (!addCategory) {
        addCategory = [[AddCategory alloc] initWithCategory:categories];
        
        if ([[NSBundle mainBundle] loadNibNamed:@"AddCategory" owner:addCategory topLevelObjects:nil] != YES) {
            NSLog(@"Error loading nib");
        }
    }
    
    if (addCategory.window.isVisible) {
        [addCategory.window makeKeyAndOrderFront:self];
        return;
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
    
    int idt = [data[row][@"cliente_id"] intValue];
    
    if (!editClient) {
        editClient = [[EditClient alloc] initWithID:idt andClientClass:clients];
        
        if ([[NSBundle mainBundle] loadNibNamed:@"EditClient" owner:editClient topLevelObjects:nil] != YES) {
            NSLog(@"Error loading nib");
        }
    } else {
        [editClient changeID:idt];
        [editClient reload];
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

- (IBAction)editCategory:(id)sender {
    // Get the row number and fetch category id.
    NSInteger row = self.catTableView.selectedRow;
    
    if (row == -1)
        return;
    
    int idt = [catData[row][@"id"] intValue];
    
    if (!editCategory) {
        editCategory = [[EditCategory alloc] initWithCategory:categories andID:idt];
        
        if ([[NSBundle mainBundle] loadNibNamed:@"EditCategory" owner:editCategory topLevelObjects:nil] != YES) {
            NSLog(@"Error loading nib");
        }
    } else
        [editCategory changeID:idt];
    
    
    [self.catWindow beginSheet:editCategory.window completionHandler:^(NSModalResponse returnCode) {
        // Update category table
        if (self.catWindow.isVisible) {
            [self categoryMainQuery];
            [self.catTableView reloadData];
        }
        // Update clients table if is visible
        if (self.window.isVisible) {
            [self mainQuery];
            [self.tableView reloadData];
        }
    }];
    editCategory.nombre.stringValue = catData[row][@"nombre"];
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

- (void)searchQuery:(NSString *)search {
    data = [clients searchClients:search];
}

- (void)deleteRow:(int)idt {
    [clients removeClientWithID:idt];
}


#pragma mark Manejo de categorias

- (void)categoryMainQuery {
    catData = [categories fetchAllCategories];
}

- (void)categorySearchQuery:(NSString *)search {
    catData = [categories searchCategory:search];
}

- (void)categoryDeleteRow:(int)idt {
    BOOL result = [categories removeCategoryWithID:idt];
    
    if (!result) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No se puede eliminar la categoría"];
        [alert setInformativeText:@"Se encuentra en uso"];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
}



@end
