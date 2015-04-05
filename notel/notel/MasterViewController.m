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
#import "Note.h"
#import "CoreDataStack.h"

@interface MasterViewController () <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating>
@property (nonatomic) UISearchController *searchController;
@property (nonatomic) NSArray *filteredList;
@end

@implementation MasterViewController


#pragma mark - View Lifecycle Methods

- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Navigation Bar Button Items
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(insertNewNote:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // Search Controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    // Add the SearchBar to the Table View Header & Allow to cover controller's view
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    // Then set the contentOffset property to hide the header row for a user pull down reveal
    [self.tableView setContentOffset:CGPointMake(0,44) animated:YES];
}


- (void)mergeHelper:(NSNotification*)saveNotification
{
    CoreDataStack *cds = [CoreDataStack defaultStack];
    // Fault in all updated objects
    NSArray* updates = [[saveNotification.userInfo objectForKey:@"updated"] allObjects];
    for (NSInteger i = [updates count]-1; i >= 0; i--) {
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


#pragma mark - Table View Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.searchController.active) {
        return 1;
    }
    CoreDataStack *cds = [CoreDataStack defaultStack];
    return [[cds.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return [self.filteredList count];
    }
    CoreDataStack *cds = [CoreDataStack defaultStack];
    id <NSFetchedResultsSectionInfo> sectionInfo = [cds.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


- (NotesTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Note *note = nil;
    
    if (self.searchController.active) {
        note = [self.filteredList objectAtIndex:indexPath.row];
    } else {
        CoreDataStack *cds = [CoreDataStack defaultStack];
        note = [cds.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    cell.title.text = note.title;
    cell.body.text = note.body;
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


#pragma mark - UISearchBar Delegate Method

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}


#pragma mark - UISearchResultsUpdating Delegate Methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}


#pragma mark - Search Support Methods

- (void)searchForText:(NSString *)searchText {
    CoreDataStack *cds = [CoreDataStack defaultStack];
    if (cds.managedObjectContext) {
        if (searchText.length == 0) { // Show All if No Search - initial condition
            self.filteredList = [cds.fetchedResultsController fetchedObjects];
        } else {
            NSString *predicateFormat = @"%K BEGINSWITH[cd] %@";
            NSString *searchAttribute = @"title";
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
            [cds.searchFetchRequest setPredicate:predicate];
            
            NSError *error = nil;
            self.filteredList = [cds.managedObjectContext executeFetchRequest:cds.searchFetchRequest error:&error];
        }
    }
}

@end
