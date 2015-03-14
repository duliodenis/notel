//
//  NewNoteViewController.m
//  notel
//
//  Created by Dulio Denis on 3/14/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import "NewNoteViewController.h"
#import <CoreData/CoreData.h>

@interface NewNoteViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *noteBody;
@end

@implementation NewNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noteBody.delegate = self;
}


#pragma mark - UITextView Delegate Methods

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    NSLog(@"Inserting into CoreData");
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:self.noteBody.text forKey:@"body"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return YES;
}


@end
