//
//  EditClient.m
//  SqliteTest
//
//  Created by Joel Peláez Jorge on 25/01/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import "EditClient.h"
#import "AppDelegate.h"
#import "Client.h"
#import "NSString+EmailValidation.h"

#include <sqlite3.h>

@interface EditClient () {
    sqlite3 *conn;
    NSMutableArray<NSMutableDictionary *> * data;
    int idt;
    Client *clients;
}

@end

@implementation EditClient

/**
 Create a new window controller for editing a client using
 a existent Client class.

 @param idClient A existent client identifier.
 @param cl Client object.
 @return A new EditClient instance.
 */
- (instancetype)initWithID:(int)idClient andClientClass:(Client *)cl {
    self = [super init];
    [self loadCategories];
    self->idt = idClient;
    self->clients = cl;
    NSLog(@"%d", idt);
    return self;
}

/**
 Change the current user to edit. Used when the controller
 was created and it's reused.

 @param newID A existent client identifer.
 */
- (void)changeID:(int)newID {
    self->idt = newID;
}

/**
 Reload the data necessary for edit a client.
 */
- (void)reload {
    [self loadCategories];
}

/**
 Change the category of a client. This works in programming level
 for update the ComboBox.

 @param idCategoria A existent category identifer.
 */
- (void)setCategoriaID:(int)idCategoria {
    for (int i = 0; i < data.count; i++) {
        if ([data[i][@"id"] intValue] == idCategoria) {
            [self.categoria selectItemAtIndex:i];
            return;
        }
    }
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
    
    int pos = (int)self.categoria.indexOfSelectedItem;
    
    int catid = [data[pos][@"id"] intValue];
    
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
    NSDictionary *exists = [clients searchWithEmail:self.correo.stringValue];
    
    if (exists && [exists[@"cliente_id"] intValue] != idt) {
        NSLog(@"%@ with id: %d", exists, idt);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Correo en uso"];
        [alert setInformativeText:@"Debe ingresar un correo diferente"];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];
        return;
    }
    
    BOOL result = [clients updateClientWithID:idt firstname:self.nombre.stringValue lastname:self.apellidos.stringValue phone:self.telefono.stringValue email:self.correo.stringValue category:catid];
    
    if (!result) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No se pudo insertar al cliente"];
        [alert setInformativeText:@"Contacte con su administrador"];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSAlertStyleCritical];
        [alert runModal];
    }
    
    [self.window.sheetParent endSheet:self.window];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
    return data.count;
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    return data[index][@"nombre"];
}


@end
