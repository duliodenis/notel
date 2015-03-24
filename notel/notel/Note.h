//
//  Note.h
//  notel
//
//  Created by Dulio Denis on 3/24/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * title;

@end
