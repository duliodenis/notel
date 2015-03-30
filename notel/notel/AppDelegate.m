//
//  AppDelegate.m
//  notel
//
//  Created by Dulio Denis on 3/13/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "MasterViewController.h"
#import "CoreDataStack.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[CrashlyticsKit]];
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    CoreDataStack *cds = [CoreDataStack defaultStack];
    [cds saveContext];
}

@end
