//
//  EditCategory.h
//  AppClientes
//
//  Created by Joel Peláez Jorge on 04/02/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Category.h"

@interface EditCategory : NSWindowController

@property (weak) IBOutlet NSTextField *nombre;

- (instancetype)initWithCategory:(Category *)cat andID:(int)id;
- (void)changeID:(int)idt;

@end
