//
//  EditClient.h
//  SqliteTest
//
//  Created by Joel Peláez Jorge on 25/01/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Client.h"

@interface EditClient : NSWindowController <NSComboBoxDataSource>

@property (weak) IBOutlet NSTextField *nombre;
@property (weak) IBOutlet NSTextField *apellidos;
@property (weak) IBOutlet NSTextField *telefono;
@property (weak) IBOutlet NSTextField *correo;
@property (weak) IBOutlet NSComboBox *categoria;

- (instancetype)initWithID:(int)idClient andClientClass:(Client *)cl;
- (void)setCategoriaID:(int)idCategoria;
- (void)changeID:(int)idt;
- (void)reload;

@end
