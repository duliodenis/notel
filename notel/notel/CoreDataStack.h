//
//  CoreDataStack.h
//  notel
//
//  Created by Dulio Denis on 3/23/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataStack : NSObject <NSFetchedResultsControllerDelegate, NSFetchedResultsControllerDelegate>

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSFetchRequest *searchFetchRequest;
@property (nonatomic) id delegate;

+ (instancetype)defaultStack;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)refreshFetchedResultsController;
- (void)deleteCache;

@end
