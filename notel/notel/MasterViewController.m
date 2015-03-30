//
//  MasterViewController.m
//  notel
//
//  Created by Dulio Denis on 3/13/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NewNoteViewController.h"
#import "NotesTableViewCell.h"
#import "CoreDataStack.h"

@interface MasterViewController ()

@end

@implementation MasterViewController


- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewNote:)];
    self.navigationItem.rightBarButtonItem = addButton;
}


- (void)insertNewNote:(id)sender {
    NewNoteViewController *destinationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewNoteViewController"];
    CoreDataStack *cds = [CoreDataStack defaultStack];
    destinationVC.fetchedResultsController = cds.fetchedResultsController;
    destinationVC.managedObjectContext = cds.managedObjectContext;
    [self.navigationController pushViewController:destinationVC animated:YES];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CoreDataStack *cds = [CoreDataStack defaultStack];
        NSManagedObject *object = [[cds fetchedResultsController] objectAtIndexPath:indexPath];
        NSManagedObjectContext *context = [cds.fetchedResultsController managedObjectContext];
        [[segue destinationViewController] setContext:context];
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


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CoreDataStack *cds = [CoreDataStack defaultStack];
        NSManagedObjectContext *context = [cds.fetchedResultsController managedObjectContext];
        [context deleteObject:[cds.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (void)configureCell:(NotesTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    CoreDataStack *cds = [CoreDataStack defaultStack];
    NSManagedObject *object = [cds.fetchedResultsController objectAtIndexPath:indexPath];
    cell.title.text = [[object valueForKey:@"title"] description];
    cell.body.text = [[object valueForKey:@"body"] description];
}


#pragma mark - Fetched results controller

- (NSFetchRequest *)noteListFetchRequest {
    CoreDataStack *cds = [CoreDataStack defaultStack];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:cds.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    return fetchRequest;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
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
            return;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(NotesTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

@end
