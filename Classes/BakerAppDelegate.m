//
//  BakerAppDelegate.m
//  Baker
//
//  ==========================================================================================
//  
//  Copyright (c) 2010-2011, Davide Casali, Marco Colombo, Alessandro Morandi
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without modification, are 
//  permitted provided that the following conditions are met:
//  
//  Redistributions of source code must retain the above copyright notice, this list of 
//  conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of 
//  conditions and the following disclaimer in the documentation and/or other materials 
//  provided with the distribution.
//  Neither the name of the Baker Framework nor the names of its contributors may be used to 
//  endorse or promote products derived from this software without specific prior written 
//  permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  


#import "BakerAppDelegate.h"
#import "LibraryViewController.h"
#import "BakerViewController.h"
#import "Issue.h"
#import "Cover.h"
#import "Content.h"

@implementation BakerAppDelegate

@synthesize window;

@synthesize navigationController = _navigationController;

@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

#pragma mark -
#pragma mark Application lifecycle

// IOS 3 BUG
// IF "(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions"
// THEN "(BOOL) application:(UIApplication*)application handleOpenURL:(NSURL*)url" is never called
// check http://stackoverflow.com/questions/3612460/lauching-app-with-url-via-uiapplicationdelegates-handleopenurl-working-under-i for hints
//- (void)applicationDidFinishLaunching:(UIApplication *)application {    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    // Disable Shake to undo
	application.applicationSupportsShakeToEdit = NO;
    
    // Shelf View
    LibraryViewController * LVrootViewController = [[LibraryViewController alloc] initWithNibName:@"LibraryViewController" bundle:nil];  
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:LVrootViewController];  
    [_navigationController setNavigationBarHidden:YES];
    [_navigationController setToolbarHidden:YES];
    
    // Can Release this as it's being retained in the _navigationController
    [LVrootViewController release];
    
    
    self.window.rootViewController = _navigationController;
    [self.window makeKeyAndVisible];
	
	NSString *reqSysVer = @"3.2";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedDescending && [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] != nil) {
		NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
		[self application:application handleOpenURL:url];
	}
	
	return YES;
}


- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {
	
	NSString *URLString = [url absoluteString];
	NSLog(@"handleOpenURL -> %@", URLString);
	
	// STOP IF: url || URLString is nil
	if (!url || !URLString)
		return NO;
	
	// STOP IF: not my scheme
	if (![[url scheme] isEqualToString:@"book"])
		return NO;
	
	NSLog(@"HPub scheme found! -> %@", [url scheme]);
	
	NSArray *URLSections = [URLString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
	NSString *URLDownload = [@"http:" stringByAppendingString:[URLSections objectAtIndex:1]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"downloadNotification" object:URLDownload];
	
	return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	
	[self saveLastPageReference];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}
- (void)applicationWillTerminate:(UIApplication *)application {
	/*
	 Sent when the main button is pressed in iOS < 4
	 */
	
	[self saveLastPageReference];
    
    [self saveContext];
}

- (void)saveLastPageReference {
    
    //@nin9creative - need to figure out how to reimplement saving pages with multiple issues?
	
	//NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
	
	// Save last page viewed reference
	//if (rootViewController.currentPageNumber > 0) {
	//	NSString *lastPageViewed = [NSString stringWithFormat:@"%d", rootViewController.currentPageNumber];
	//	[userDefs setObject:lastPageViewed forKey:@"lastPageViewed"];
	//	NSLog(@"Saved last page viewed: %@", lastPageViewed);
	//}
	
	// Save last scroll index reference
	//if (rootViewController.currPage != nil) {
	//	NSString *lastScrollIndex = [rootViewController.currPage stringByEvaluatingJavaScriptFromString:@"window.scrollY;"];
	//	[userDefs setObject:lastScrollIndex forKey:@"lastScrollIndex"];	
	//	NSLog(@"Saved last scroll index: %@", lastScrollIndex);
	//}
}

#pragma mark -
#pragma mark Memory management
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}
- (void)dealloc {

	[window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_navigationController release];
    [super dealloc];
}

- (void)awakeFromNib
{

    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
     */
    NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
        // Handle the error.
        NSLog(@"Could not get a context!");
    }
    
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SitelessMagazine" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SitelessMagazine.sqlite"];
    
    NSLog(@"Store URL %@", storeURL);
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
