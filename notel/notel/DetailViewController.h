//
//  DetailViewController.h
//  notel
//
//  Created by Dulio Denis on 3/13/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

