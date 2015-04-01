//
//  NewNoteViewController.m
//  notel
//
//  Created by Dulio Denis on 3/14/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import "NewNoteViewController.h"
#import <CoreData/CoreData.h>
#import "CoreDataStack.h"

@interface NewNoteViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet UITextView *noteBody;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@end

@implementation NewNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noteBody.delegate = self;
}


#pragma mark - UITextView Delegate Methods

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    CoreDataStack *cds = [CoreDataStack defaultStack];
    NSEntityDescription *entity = [[cds.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                                      inManagedObjectContext:cds.managedObjectContext];
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:self.noteTitle.text forKey:@"title"];
    [newManagedObject setValue:self.noteBody.text forKey:@"body"];
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"]; // puts in the creation date for sorting by date
    
    // Save the context.
    NSError *error = nil;
    
    if (![cds.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    [cds refreshFetchedResultsController];
    return YES;
}

// hide the placeholder when the user begins
- (void)textViewDidChange:(UITextView *)textView {
    if      (textView.text.length!=0) [UIView animateWithDuration:0.2 animations:^{ self.placeholderLabel.alpha = 0; }];
    else if (textView.text.length==0) [UIView animateWithDuration:0.2 animations:^{ self.placeholderLabel.alpha = 1; }];
}

@end
