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
    Category *category;
}

@property (weak) IBOutlet NSTextField *nombre;

@end

@implementation AddCategory

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
}

/**
 Initialize a new window controller for add a category using
 a existent Category class.

 @param cat Category object.
 @return A new AddCategory instance.
 */
- (instancetype)initWithCategory:(Category *)cat {
    self = [super init];
    self->category = cat;
    return self;
}

- (IBAction)cancel:(id)sender {
    [self.window.sheetParent endSheet:self.window];
}

- (IBAction)addCategory:(id)sender {
    
    // Nombre must exist.
    if (self.nombre.stringValue.length == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Nombre inválido"];
        [alert setInformativeText:@"Debe ingresar un nombre"];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];
        return;
    }
    
    BOOL result = [category insertCategoryWithName:self.nombre.stringValue];
    
    if (!result) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No se pudo insertar la categoria"];
        [alert setInformativeText:@"Contacte con su administrador"];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSAlertStyleCritical];
        [alert runModal];
    }
    
    [self.window.sheetParent endSheet:self.window];
}


@end
