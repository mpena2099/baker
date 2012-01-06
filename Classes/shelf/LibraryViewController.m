//
//  LibraryViewController.m
//  SitelessMag
//
//  Created by Bart Termorshuizen on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LibraryViewController.h"
#include "IssueViewController.h"
#include "BakerAppDelegate.h"
#include "Issue.h"
#include "Cover.h"
#include "Content.h"

#import "JSON.h"


@implementation LibraryViewController

@synthesize managedObjectContext;
@synthesize issuesArray;
@synthesize numberOfIssuesShown;
@synthesize numberOfPagesShown;


//- (void)sync:(id) sender {
-(IBAction) sync:(id) sender
{
    NSLog(@"Sync button pushed");
    
    // Create a new NSBundle pointer
    NSBundle* mainBundle;
    
    // The Info.plist is considered the mainBundle.
    mainBundle = [NSBundle mainBundle]; 

    // get info from json rest service
    // Create the request.
    NSString * library_url = [NSString stringWithFormat:@"%@issueslist.json", [mainBundle objectForInfoDictionaryKey:@"IssueListURL"]];
    
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[[NSURL alloc] initWithString:library_url]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [[NSMutableData data] retain];
    } else {
        NSLog(@"LibraryViewController - refresh: connection failed");
    }
    return;
    
}

- (void) resolvedCover:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"coverResolved"]){
        NSLog (@"LibraryViewController: Received the coverResolved notification!");
        
        // propagate the change to the database
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    }
    
    
}

- (void) downloadedContent:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"contentDownloaded"]){
        NSLog (@"LibraryViewController: Received the contentDownloaded notification!");
        
        // propagate the change to the database
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    }
}


- (void) archivedContent:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"contentArchived"]){
        NSLog (@"LibraryViewController: Received the contentArchived notification!");
        
        // propagate the change to the database
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    }
}

//-(void) layout: (IssueViewController *)ivc 
-(void) layout:(IssueViewController *)ivc setOrientation:(UIInterfaceOrientation) interfaceOrientation 
{
    
    if (interfaceOrientation != UIInterfaceOrientationLandscapeLeft &&
        interfaceOrientation != UIInterfaceOrientationLandscapeRight)
    {
        // determine position to place the ivc based on 4 views per page 
        numberOfIssuesShown ++; // note that this may be confusing - just avoiding '+1' everywhere in this method
        
        // position indicates position on a page
        NSInteger position = (numberOfIssuesShown)%4;
        if (position == 0) position = 4;
        
        NSInteger pageWidth = scrollView.frame.size.width;
        NSInteger pageHeight = scrollView.frame.size.height;
        NSLog(@"pageWidth=%d, pageHeight=%d", pageWidth, pageHeight);
        
        
        if (position == 1) // new page situation
        {
            // extend the scrollview's contentsize height with 1 page
            [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, pageHeight*(numberOfPagesShown+1))];
            numberOfPagesShown++;
        }
        
        // 4 ivc's on a page as follows - numbers below indicate the value of the position variable
        // 1    2
        // 3    4
        
        NSInteger row = 0;
        NSInteger col = 0;
        if (position > 2) row = 1;
        if (position == 2 || position == 4) col = 1;
        
        UIView * ivcView = [ivc view];
        
        CGRect frame = CGRectMake(col*pageWidth/2 + 20,
                                  row*pageHeight/2 + (numberOfPagesShown-1)*pageHeight + 20,
                                  ivcView.frame.size.width, 
                                  ivcView.frame.size.height
                                  );
        [ivcView setFrame:frame];   
        
    } else {
        
        // Show horizontally
        NSLog(@"HORIZONTAL!!!!!!!!");
        
        // determine position to place the ivc based on 6 views per page 
        numberOfIssuesShown ++; // note that this may be confusing - just avoiding '+1' everywhere in this method
        
        
        NSLog(@"numberOfIssuesShown=%d", numberOfIssuesShown);
        
        // position indicates position on a page
        NSInteger position = (numberOfIssuesShown)%6;
        if (position == 0) position = 6;
        
        
        NSLog(@"position=%d", position);
        
        
        NSInteger pageWidth = scrollView.frame.size.width;
        NSInteger pageHeight = scrollView.frame.size.height;
        
        
        if (position == 1) // new page situation
        {
            // extend the scrollview's contentsize height with 1 page
            [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, pageHeight*(numberOfPagesShown+1))];
            numberOfPagesShown++;
        }
        
        // 6 ivc's on a page as follows - numbers below indicate the value of the position variable
        // 1    2   3
        // 4    5   6
        
        NSInteger row = 0;
        NSInteger col = 0;
        //const NSInteger w = 320;
        const NSInteger h = 282;
        
        
        if (position > 3) row = 1;
        if (position == 2 || position == 5) col = 1;
        if (position == 3 || position == 6) col = 2;
        
        
        UIView * ivcView = [ivc view];
        
        
        NSLog(@"col0=%d, row0=%d", col, row);
        NSLog(@"pageWidth=%d, pageHeight=%d", pageWidth, pageHeight);
        
        
        // set col position
        switch (col) {
            case  1:
                col = pageWidth/2 - 140;
                break;
            case  2:
                col = pageWidth - 300;
                break;
        }
        
        // set row position
        switch (row) {
            case  1:
                row = pageHeight/2 - h/2 + 10;
                break;
        }
        
        
        CGRect frame = CGRectMake(col,
                                  row + ((numberOfPagesShown-1) * pageHeight),
                                  ivcView.frame.size.width, 
                                  ivcView.frame.size.height
                                  );
        
        NSLog(@"col=%d, row=%d", col, row + (numberOfPagesShown-1)*pageHeight + 20);
        
        [ivcView setFrame:frame];        
    }
    
    
    return;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // get and set the managedObjectContext  from the appdelegate object
        BakerAppDelegate *appDelegate = (BakerAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self setManagedObjectContext:[appDelegate managedObjectContext]];
        
        /*
        UIBarButtonItem* syncButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                     target:self 
                                                                                     action:@selector(sync:)] autorelease];
        
        
        NSArray *items = [NSArray arrayWithObjects: 
                          syncButton,
                          nil];
        [self setToolbarItems:items];
        */
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [issuesArray dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



- (void)updateShelf:(UIInterfaceOrientation)interfaceOrientation
{
    numberOfIssuesShown = 0;
    numberOfPagesShown = 0; 

    NSManagedObjectModel *model = [[managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSError *error = nil;

    NSFetchRequest *fetchRequest =
    [model fetchRequestFromTemplateWithName:@"AllIssues"
                      substitutionVariables:nil];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];

    NSArray *results =[[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];

    if (error){
        NSLog(@"Error fetching data from store: %@, %@", error, [error userInfo]);
    }
    if (results != nil ){
        // results contain result set - copy it to the issuesArray
        issuesArray = [[NSMutableArray alloc] initWithArray:results];
    }
    else {
        NSLog(@"Database is empty or an error occurred");
    }


    // iterate over the issues and create the issueview controllers and issues
    issueViewControllers = [[NSMutableArray alloc] initWithCapacity:[issuesArray count]];


    for (Issue *i in issuesArray)
    {
    
        // instantiate a issueviewcontroller object
        IssueViewController *ivc = [[IssueViewController alloc] initWithNibName:@"IssueViewController" bundle:[NSBundle mainBundle]];
    
        // register the issue as model instance at the issueviewcontroller
        [ivc setIssue:i];
    
        [issueViewControllers addObject:ivc];
    
        // layout the ivc and adapt the scroll view if necessary
        [self layout:ivc setOrientation:interfaceOrientation];
    
        [scrollView addSubview:[ivc view]];
    
        [ivc release];
    }

    // notification to save the changes to the managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resolvedCover:) name:@"coverResolved" object:nil ] ; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadedContent:) name:@"contentDownloaded" object:nil ] ;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(archivedContent:) name:@"contentArchived" object:nil ] ;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateShelf:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    for (IssueViewController *ivc in issueViewControllers) [ivc release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
    
    // Update the size/position of some objects
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        scrollView.frame = CGRectMake(0, 239, 1024, 785); 
        shelfToolBar.frame = CGRectMake(0, 0, 1024, 44);
        shelfTitle.frame = CGRectMake(360, 11, 266, 21);
    }
    else
    {
        scrollView.frame = CGRectMake(0, 239, 768, 785); 
        shelfToolBar.frame = CGRectMake(0, 0, 768, 44);
        shelfTitle.frame = CGRectMake(255, 11, 266, 21);
    }
    
    
    // Clear existing views from the content
    for (UIView *view in scrollView.subviews)
    {
        if (![view isKindOfClass:[UIImageView class]])
            [view removeFromSuperview];
    }
    
    // Update issues view
    [self updateShelf:toInterfaceOrientation];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
    return;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    // inform the user
    NSLog(@"Cover - Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    return;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
    
    // Create a dictionary from the JSON string
    NSDictionary *results = [jsonString JSONValue];
	
    // Build an array from the dictionary for easy access to each entry
    NSArray * json_issues = [[NSArray arrayWithArray: [results objectForKey:@"issues"]] retain];
	
    if ([json_issues count]==0) { 
        NSLog(@"Library is empty or could not be read");
    }
    
    BOOL found;
    NSInteger newissues = 0; 
    
    // set number
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    for (NSDictionary *json_issue in json_issues) {
        
        // Get mag, number,date, title, descr, issueurl, coverurl
        NSString *mag = [json_issue objectForKey:@"mag"];
        NSString *number = [json_issue objectForKey:@"number"];
        NSString *date = [json_issue objectForKey:@"date"];
        NSString *title = [json_issue objectForKey:@"title"];
        NSString *descr = [json_issue objectForKey:@"descr"];
        NSString *issueurl = [json_issue objectForKey:@"issueurl"];
        NSString *coverurl = [json_issue objectForKey:@"coverurl"];
        
        NSLog(@"%@ issue %@ with issueurl %@ and coverurl %@",mag, number,issueurl, coverurl);
        
        // check if issue object exists -> add to context if not. The check is based on mag and number
        found = NO;
        
        for (Issue *issue in issuesArray){
            if (!found && [[issue mag] isEqualToString:mag] && [[[issue number] stringValue] isEqualToString:number]){
                found = YES;
            }
        }
        
        if (!found){
                        
            newissues++;
            // we have not found the issue. Add the new issue in the context
            
            
            // Create and configure a new instance of the Issue entity.
            
            Issue *newIssue = (Issue *)[NSEntityDescription insertNewObjectForEntityForName:@"Issue" inManagedObjectContext:managedObjectContext];
            Cover *newCover = (Cover *)[NSEntityDescription insertNewObjectForEntityForName:@"Cover" inManagedObjectContext:managedObjectContext];
            Content *newContent = (Content *)[NSEntityDescription insertNewObjectForEntityForName:@"Content" inManagedObjectContext:managedObjectContext];
            
            // set magazine
            [newIssue setMag:mag];
            
            // set status to 1 (new issue)
            [newIssue setStatus:[NSNumber numberWithInt:1]];
            
            [newIssue setNumber: [f numberFromString:number]];
            
            // set date
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            [newIssue setDate:[dateFormatter dateFromString:date]];
            [dateFormatter dealloc];
            
            //set title, descr
            [newIssue setTitle:title];
            [newIssue setDescr:descr];
            
            // set coverurl
            [newCover setUrl:coverurl];
            
            // set contenturl
            [newContent setUrl:issueurl];
            
            // create relationships
            [newIssue setCover:newCover];
            [newIssue setContent:newContent];
            
            
            //update array that holds the issues
            [issuesArray insertObject:newIssue atIndex:0];
            
            // instantiate a issueviewcontroller object
            IssueViewController *ivc = [[IssueViewController alloc] initWithNibName:@"IssueViewController" bundle:[NSBundle mainBundle]];
            
            // register the issue as model instance at the issueviewcontroller
            [ivc setIssue:newIssue];
            
            [issueViewControllers addObject:ivc];
            
            // layout the ivc and adapt the scroll view if necessary
            [self layout:ivc setOrientation:1];
            
            [scrollView addSubview:[ivc view]];
            
            [ivc release];
        } 
    }
    
    //dealloc number formatter
    [f dealloc];
    
    // check if any covers have unresolved pics -> if so, (try to) resolve them
    for (Issue *issue in issuesArray){
        Cover *c =(Cover *)[issue cover];
        if ([[c path] isEqualToString:@""] || [c path] == nil) {
            [c resolve];
            // note that the update of the pics is asynchronous - we need to get notified in order to update the database (resolvedCover)
        }
    }
    
    NSError * error = nil;
    
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [connection release];
    [receivedData release];
    return;
}

@end
