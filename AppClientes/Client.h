//
//  Client.h
//  AppClientes
//
//  Created by Joel Peláez Jorge on 29/01/17.
//  Copyright © 2017 Joel Peláez Jorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>

@interface Client : NSObject

+ (instancetype)clientWithConnection:(sqlite3 *)conn;

- (NSArray<NSDictionary *> *)fetchAllClients;
- (NSArray<NSDictionary *> *)searchClients:(NSString *)lastname;
- (NSDictionary *)fetchClient:(int)idt;
- (NSDictionary *)searchWithEmail:(NSString *)email;

- (BOOL)removeClientWithID:(int)idt;
- (BOOL)updateClientWithID:(int)idt firstname:(NSString *)fname lastname:(NSString *)lname phone:(NSString *)phone email:(NSString *)email category:(int)catid;
- (BOOL)insertClientWithFirstname:(NSString *)fname lastname:(NSString *)lname phone:(NSString *)phone email:(NSString *)email category:(int)catid;

@end
