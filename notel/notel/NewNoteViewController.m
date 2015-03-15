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
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:self.noteBody.text forKey:@"body"];
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"]; // puts in the creation date for sorting by date
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    return YES;
}


@end
