//
//  ShareViewController.m
//  notel share
//
//  Created by Dulio Denis on 3/16/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import "ShareViewController.h"
#import <CoreData/CoreData.h>
#import "CoreDataStack.h"

@interface ShareViewController ()  <NSFetchedResultsControllerDelegate>
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@end


@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}


- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    CoreDataStack *cds = [CoreDataStack defaultStack];
    
    // need to set-up fetchedResultsController
    
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:cds.managedObjectContext];
    
    // Verify that we have a valid NSExtensionItem
    NSExtensionItem *imageItem = [self.extensionContext.inputItems firstObject];
    if(!imageItem){
        return;
    }
    
    // Verify that we have a valid NSItemProvider
    NSItemProvider *imageItemProvider = [[imageItem attachments] firstObject];
    if(!imageItemProvider){
        return;
    }
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:@"Shared Content" forKey:@"title"];
    [newManagedObject setValue:self.contentText forKey:@"body"];
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"]; // puts in the creation date for sorting by date
    
    // Save the context.
    NSError *error = nil;
    
    if (![cds.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:^(BOOL expired) {
        [cds deleteCache];
    }];
}


- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}


- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    CoreDataStack *cds = [CoreDataStack defaultStack];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:cds.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:cds.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

@end
