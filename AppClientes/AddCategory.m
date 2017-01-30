//
//  AddCategory.m
//  SqliteTest
//
//  Created by Joel Peláez Jorge on 24/01/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import "AddCategory.h"
#include <sqlite3.h>
#import "AppDelegate.h"

@interface AddCategory () {
    sqlite3 *conn;
}

@property (weak) IBOutlet NSTextField *nombre;

@end

@implementation AddCategory

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
}

- (IBAction)cancel:(id)sender {
    [self.window.sheetParent endSheet:self.window];
}

- (IBAction)addCategory:(id)sender {
    const char *sql =   "INSERT INTO categorias (nombre) VALUES (?)";
    
    
    AppDelegate *app = (AppDelegate *)[NSApplication sharedApplication].delegate;
    conn = [app sqlite3_conn];
    
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
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Error: %s", sqlite3_errmsg(conn));
        goto end;
    }
end:
    sqlite3_finalize(stmt);
end_without_stmt:
    [self.window.sheetParent endSheet:self.window];
}


@end
