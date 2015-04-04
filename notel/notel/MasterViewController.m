//
//  MasterViewController.m
//  notel
//
//  Created by Dulio Denis on 3/13/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NewNoteViewController.h"
#import "NotesTableViewCell.h"
#import "CoreDataStack.h"

@interface MasterViewController () <NSFetchedResultsControllerDelegate>
@end

@implementation MasterViewController


- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(insertNewNote:)];
    self.navigationItem.rightBarButtonItem = addButton;
}


- (void)mergeHelper:(NSNotification*)saveNotification
{
    CoreDataStack *cds = [CoreDataStack defaultStack];
    // Fault in all updated objects
    NSArray* updates = [[saveNotification.userInfo objectForKey:@"updated"] allObjects];
    for (NSInteger i = [updates count]-1; i >= 0; i--)
    {
        [[cds.managedObjectContext objectWithID:[[updates objectAtIndex:i] objectID]] willAccessValueForKey:nil];
    }
    
    // Merge
    [cds.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    CoreDataStack *cds = [CoreDataStack defaultStack];
    cds.delegate = self;
    cds.fetchedResultsController = nil;
    [self.tableView reloadData];
}


- (void)insertNewNote:(id)sender {
    NewNoteViewController *destinationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewNoteViewController"];
    [self.navigationController pushViewController:destinationVC animated:YES];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CoreDataStack *cds = [CoreDataStack defaultStack];
        NSManagedObject *object = [[cds fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    CoreDataStack *cds = [CoreDataStack defaultStack];
    return [[cds.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CoreDataStack *cds = [CoreDataStack defaultStack];
    id <NSFetchedResultsSectionInfo> sectionInfo = [cds.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


- (NotesTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CoreDataStack *cds = [CoreDataStack defaultStack];
        [[cds managedObjectContext] deleteObject:[cds.fetchedResultsController objectAtIndexPath:indexPath]];
        [cds saveContext];
    }
}


- (void)configureCell:(NotesTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    CoreDataStack *cds = [CoreDataStack defaultStack];
    NSManagedObject *object = [cds.fetchedResultsController objectAtIndexPath:indexPath];
    cell.title.text = [[object valueForKey:@"title"] description];
    cell.body.text = [[object valueForKey:@"body"] description];
}


#pragma mark - Fetched Results Controller Delegate Methods


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            // [self configureCell:(NotesTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

@end
