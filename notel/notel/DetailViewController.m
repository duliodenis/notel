//
//  DetailViewController.m
//  notel
//
//  Created by Dulio Denis on 3/13/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet UITextView *noteBody;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.noteTitle.text = [self.detailItem valueForKey:@"title"];
        self.noteBody.text = [[self.detailItem valueForKey:@"body"] description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noteBody.delegate = self;
    [self configureView];
}


#pragma mark - UITextView Delegate Methods

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    [self.detailItem setValue:self.noteTitle.text forKey:@"title"];
    [self.detailItem setValue:self.noteBody.text forKey:@"body"];
    [self.detailItem setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return YES;
}


#pragma mark - Method to support Segue

- (void)setContext:(NSManagedObjectContext *)context {
    _context = context;
}


#pragma mark - Note Sharing

- (IBAction)share:(id)sender {
    BOOL shareable = NO;
    
    NSMutableArray *itemsToShare = [NSMutableArray array];
    if (self.noteTitle.text.length > 0) { [itemsToShare addObject:self.noteTitle.text]; shareable=YES; }
    if (self.noteBody.text.length > 0)  { [itemsToShare addObject:self.noteBody.text]; shareable=YES; }
    
    if (shareable) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

@end
