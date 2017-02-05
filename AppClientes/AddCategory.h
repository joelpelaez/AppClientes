//
//  AddCategory.h
//  SqliteTest
//
//  Created by Joel Peláez Jorge on 24/01/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Category.h"

@interface AddCategory : NSWindowController

- (instancetype)initWithCategory:(Category *)cat;

@end
