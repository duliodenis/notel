//
//  ShareViewController.m
//  notel share
//
//  Created by Dulio Denis on 3/16/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import "ShareViewController.h"
#import <CoreData/CoreData.h>

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    
    // Initialize the store in order to save
    NSURL *baseURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.notelContainer"];
    NSURL *storeURL = [baseURL URLByAppendingPathComponent:@"notel.sqlite"];
    NSURL *modelURL = [baseURL URLByAppendingPathComponent:@"notel.momd"];

    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSPersistentStore *store = nil;
    NSError *error = [NSError new];
    store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                      configuration:nil
                                                URL:storeURL
                                            options:nil
                                              error:&error];
    
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
