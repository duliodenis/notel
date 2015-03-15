//
//  DetailViewController.h
//  notel
//
//  Created by Dulio Denis on 3/13/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DetailViewController : UIViewController

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) id detailItem;

- (void)setContext:(NSManagedObjectContext *)context;

@end

