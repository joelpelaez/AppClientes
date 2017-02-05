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
#import "Client.h"

@interface AddClient () {
    sqlite3 *conn;
    NSMutableArray<NSMutableDictionary *> * data;
    Client *clients;
}

@property (weak) IBOutlet NSTextField *nombre;
@property (weak) IBOutlet NSTextField *apellidos;
@property (weak) IBOutlet NSTextField *telefono;
@property (weak) IBOutlet NSTextField *correo;
@property (weak) IBOutlet NSComboBox *categoria;

@end

@implementation AddClient

/**
 Create a new window controller for add a new client using
 a existent Client connection

 @param cl Client object
 @return A new instance of AddClien
 */
- (instancetype _Nonnull)initWithClient:(Client * _Nonnull)cl {
    self = [super init];
    [self loadCategories];
    clients = cl;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

/**
 Reload all data necessary for add new clients.
 */
- (void)reload {
    [self loadCategories];
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
    
    NSInteger pos = self.categoria.indexOfSelectedItem;
    
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
    
    if (exists) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Correo en uso"];
        [alert setInformativeText:@"Debe ingresar un correo diferente"];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];
        return;
    }
    
    
    // Realize insert
    BOOL result = [clients insertClientWithFirstname:self.nombre.stringValue lastname:self.apellidos.stringValue phone:self.telefono.stringValue email:self.correo.stringValue category:[data[pos][@"id"] intValue]];
    
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
