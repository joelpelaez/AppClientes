//
//  Category.h
//  AppClientes
//
//  Created by Joel Peláez Jorge on 04/02/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>

@interface Category : NSObject

+ (instancetype)categoryWithConnection:(sqlite3 *)conn;

- (NSArray<NSDictionary *> *)fetchAllCategories;
- (NSArray<NSDictionary *> *)searchCategory:(NSString *)name;
- (NSDictionary *)fetchCategory:(int)idt;

- (BOOL)removeCategoryWithID:(int)idt;
- (BOOL)updateCategoryWithID:(int)idt name:(NSString *)name;
- (BOOL)insertCategoryWithName:(NSString *)name;

@end
