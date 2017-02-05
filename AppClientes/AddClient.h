//
//  AddClient.h
//  SqliteTest
//
//  Created by Joel Peláez Jorge on 24/01/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Client.h"

@interface AddClient : NSWindowController <NSComboBoxDataSource>

- (instancetype _Nonnull)initWithClient:(Client * _Nonnull)cl;
- (void)reload;
@end
