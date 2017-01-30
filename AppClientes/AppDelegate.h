//
//  AppDelegate.h
//  SqliteTest
//
//  Created by Joel Peláez Jorge on 23/01/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <sqlite3.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource> {
    sqlite3 *conn;
}

- (sqlite3 *)sqlite3_conn;

@end

