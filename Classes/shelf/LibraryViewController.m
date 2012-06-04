//
//  LibraryViewController.m
//
//  Created by Bart Termorshuizen on 6/17/11.
//  Modified/Adapted for BakerShelf by Andrew Krowczyk @nin9creative on 2/18/2012
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

#import  "LibraryViewController.h"
#include "IssueViewController.h"
#include "BakerAppDelegate.h"
#include "SubscriptionsViewController.h"

#import "JSON.h"


@implementation LibraryViewController


@synthesize numberOfIssuesShown;
@synthesize numberOfPagesShown;


//Sync button
-(IBAction) sync:(id) sender
{
    [self loadIssues];
}

//Subscribe button
-(IBAction) subscribe:(id) sender
{
    if (!popover) {
        SubscriptionsViewController* svc = [[SubscriptionsViewController alloc] init];
        [svc setDelegate:self];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:svc];  
        popover = [[UIPopoverController alloc] initWithContentViewController:navController];
        [popover setDelegate:self];
        [popover setPopoverContentSize:svc.view.frame.size];
        UIBarButtonItem* b = (UIBarButtonItem*)[[shelfToolBar items] objectAtIndex:0];
        [popover presentPopoverFromBarButtonItem:b permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark ModalViewControllerDelegate 
- (void) modalViewControllerIsDone{   
    if (popover)
    { 
        //SubscriptionsViewController* svc = (SubscriptionsViewController*)[(UINavigationController*)[popover contentViewController] topViewController];
        [popover dismissPopoverAnimated:YES];
        popover = nil;
        // a subscription may be bought, so we need to update the list
    }
}
- (void) modalViewControllerCanceled{
    if (popover)
    { 
        //SubscriptionsViewController* svc = (SubscriptionsViewController*)[(UINavigationController*)[popover contentViewController] topViewController];
        [popover dismissPopoverAnimated:YES];
        popover = nil;
    }    
}

#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    if (popover){
        popover = nil;
    }
}
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return YES;
}

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
        
        // Scrollview background repeat
        //[scrollView setBackgroundColor:[UIColor colorWithPatternImage: [UIImage imageNamed:@"bg.png"]]];
        
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
        const NSInteger h = 304;
        
        
        if (position > 3) row = 1;
        if (position == 2 || position == 5) col = 1;
        if (position == 3 || position == 6) col = 2;
        
        
        UIView * ivcView = [ivc view];
        
        
        NSLog(@"col0=%d, row0=%d", col, row);
        NSLog(@"pageWidth=%d, pageHeight=%d", pageWidth, pageHeight);
        
        
        // set col position
        switch (col) {
            case  1:
                //col = pageWidth/2 - 140;
                col = pageWidth/2 - 165;
                break;
            case  2:
                //col = pageWidth - 300;
                col = pageWidth - 330;
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
        publisher = [[Publisher alloc] init];
        downloadingAssets = 0;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)updateShelf:(UIInterfaceOrientation)interfaceOrientation
{
    numberOfIssuesShown = 0;
    numberOfPagesShown = 0; 
    
    
    // iterate over the issues and create the issueview controllers and issues
    issueViewControllers = [[NSMutableArray alloc] initWithCapacity:[publisher numberOfIssues]];
    int i = 0;
    while (i < [publisher numberOfIssues]){
        // instantiate a issueviewcontroller object
        IssueViewController *ivc = [[IssueViewController alloc] initWithNibName:@"IssueViewController" bundle:[NSBundle mainBundle]];
        // register the publisher and index of issue
        [ivc setPublisher: publisher];
        [ivc setIndex: i];
        
        [issueViewControllers addObject:ivc];
        
        // layout the ivc and adapt the scroll view if necessary
        [self layout:ivc setOrientation:interfaceOrientation];
        
        [scrollView addSubview:[ivc view]];
        
        [ivc release];
        i++;
    }
}


#pragma mark - View lifecycle
- (void) loadBanners
{
    // Determine JSON path and file name
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0],@"banners.json"];  
    NSString *filePath2 = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0],@"banners.json.temp"];
    
    // Download and save file
    NSURL *url = [NSURL URLWithString:@"http://www.yag.com.br/canamix/banners.json"];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    [urlData writeToFile:filePath2 atomically:YES];
    
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    
    // See if that is a local json file
    if ([filemgr fileExistsAtPath:filePath ] == YES) {
        NSLog (@"File exists");
        
        // Compare local and remote files
        if ([filemgr contentsEqualAtPath:filePath andPath:filePath2] == NO) {
            NSLog (@"File contents do not match");
            
            // Remove old file
            if ([filemgr removeItemAtPath:filePath error: NULL]  == YES)
                NSLog (@"Remove successful");
            else
                NSLog (@"Remove failed");
            
            // Rename file as local file
            [filemgr copyItemAtPath:filePath2 toPath:filePath error: NULL];
            
        } else {
            NSLog (@"File contents match");
        }
        
    } else {
        NSLog (@"File not found");
        
        // Rename file as local file
        [filemgr copyItemAtPath:filePath2 toPath:filePath error: NULL];
    }
    
    // See local JSON file
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    
    // Transform o JSON in NSDictionary
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error: &error];
    
    // Create array and initializes it
    NSMutableArray *banners;
    banners = [[NSMutableArray alloc] init];
    
    // Ckeck JSON file and get data
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", error);
    } else {
        for (NSDictionary *item in jsonArray) {
            
            NSLog(@"Name: %@", [item objectForKey:@"name"]);
            NSLog(@"Site: %@", [item objectForKey:@"siteurl"]);
            NSLog(@"File: %@", [item objectForKey:@"fileurl"]);
            
            // Download and save images
            NSString *imageName = [[[item objectForKey:@"fileurl"] componentsSeparatedByString: @"/"] lastObject];
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], imageName];  
            NSURL *url2 = [NSURL URLWithString:[item objectForKey:@"fileurl"]];
            NSData *urlData2 = [NSData dataWithContentsOfURL:url2];
            [urlData2 writeToFile:imagePath atomically:YES];
            
            // Add image to banner array
            NSData *photoData = [NSData dataWithContentsOfFile:imagePath];
            UIImage *imageUI = [UIImage imageWithData:photoData];
            [banners addObject:imageUI];
        }
    }
    
    // Set and start banner animation
    shelfImage.animationImages = banners;
    shelfImage.animationDuration = [banners count] * 5.0;
    shelfImage.animationRepeatCount = 0;
    [shelfImage startAnimating];
    [self.view addSubview:shelfImage];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
     [super viewDidLoad];
    
    if([publisher isReady]) {
        [self updateShelf:1];
    } 
    else {
        [self loadIssues];
    }
   
    //Library background
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
    
    if ([self isDownloadingAssets]){
        [self updateDownloadingAssetsOverlay:[self interfaceOrientation]];        
    }
    
    
    // Load banners             // <----------------------------------
    [self loadBanners];
}

- (void) updateDownloadingAssetsOverlay:(UIInterfaceOrientation)interfaceOrientation
{
    float currentProgress = 0.0f;
    
    if (downloadView){
        if (progressView) currentProgress = [progressView progress];
        for (UIView* v in [downloadView subviews]){
            [v removeFromSuperview];
            [v release];
        }
        [downloadView removeFromSuperview];
        [downloadView release];
    }
     
    downloadView = [[UIView alloc] init];
    progressView =  [[UIProgressView alloc] init];
    UILabel* l = [[[UILabel alloc] init] retain];

    [downloadView setFrame:scrollView.frame];
    [downloadView setBackgroundColor : [UIColor blackColor]];
    [downloadView setAlpha : 0.8f];
    
    CGRect labelFrame = CGRectMake(0, 50, scrollView.frame.size.width, 100);
    [l setFrame : labelFrame];
    [l setText : @"Continuing previous downloads..."];
    [l setBackgroundColor : [UIColor clearColor]];
    [l setTextColor: [UIColor whiteColor]];
    [l setTextAlignment:UITextAlignmentCenter];
    
    CGFloat pfw = 200;
    CGFloat pfh = 60;
    CGRect progressFrame;

    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        progressFrame = CGRectMake((scrollView.frame.size.width - pfw)/2, 200, pfw, pfh);
    }
    else {
        progressFrame = CGRectMake(200, (scrollView.frame.size.height - pfw)/2, pfh, pfw);
    }
    
    [progressView setFrame:progressFrame];
    [progressView setHidden:NO];
    [progressView setProgress:currentProgress];
    
    [downloadView addSubview:l];
    [downloadView addSubview:progressView];
    [self.view addSubview:downloadView];
    [l release];
}

- (void) hideDownloadingAssetsOverlay
{
    if (downloadView){
        for (UIView* v in [downloadView subviews]){
            [v removeFromSuperview];
            [v release];
        }
        [downloadView removeFromSuperview];
        [downloadView release];
    }
}

-(void)loadIssues {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publisherReady:) name:kPublisherDidUpdateNotification object:publisher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publisherFailed:) name:kPublisherFailedUpdateNotification object:publisher];
    [publisher getIssuesList];    
}

-(void)publisherReady:(NSNotification *)not {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPublisherDidUpdateNotification object:publisher];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPublisherFailedUpdateNotification object:publisher];
    [self updateShelf:1];
}

-(void)publisherFailed:(NSNotification *)not {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPublisherDidUpdateNotification object:publisher];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPublisherFailedUpdateNotification object:publisher];
    NSLog(@"%@",not);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Cannot get issues from publisher server."
                                                   delegate:nil
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    for (IssueViewController *ivc in issueViewControllers) [ivc release];
    if (downloadView){
        for (UIView* v in [downloadView subviews]){
            [v removeFromSuperview];
            [v release];
        }
        [downloadView removeFromSuperview];
        [downloadView release];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
    [shelfToolBar sizeToFit];
    //shelfToolBar.frame = CGRectMake(0, 0, shelfToolBar.frame.size.width, shelfToolBar.frame.size.height);
    
    // Update the size/position of some objects
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        scrollView.frame = CGRectMake(0, 239, 1024, 785);
		shelfImage.frame = CGRectMake(0, 44, 1024, 195);
        shelfTitle.frame = CGRectMake(228, 0, shelfTitle.frame.size.width, shelfTitle.frame.size.height);
    }
    else
    {
        scrollView.frame = CGRectMake(0, 239, 768, 785);
		shelfImage.frame = CGRectMake(0, 44, 768, 195);
        shelfTitle.frame = CGRectMake(100, 0, shelfTitle.frame.size.width, shelfTitle.frame.size.height);
    }
    
    
    // Clear existing views from the content
    for (UIView *view in scrollView.subviews)
    {
        if (![view isKindOfClass:[UIImageView class]])
            [view removeFromSuperview];
    }
    
    // Update issues view
    [self updateShelf:toInterfaceOrientation];
    
    // update overlay if necessary
    if ([self isDownloadingAssets]){
        [self updateDownloadingAssetsOverlay:toInterfaceOrientation];
    }
}

- (void) incrementDownloadingAssets{
    downloadingAssets++;
}
- (void) decrementDownloadingAssets{
    downloadingAssets--;
}

- (BOOL) isDownloadingAssets{
    return (downloadingAssets>0);
}

#pragma mark NSURLConnection protocol for the support of resuming downloads
-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    progressView.progress= 1.f*totalBytesWritten/expectedTotalBytes;
}

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    NSLog(@"Resume downloading %f",1.f*totalBytesWritten/expectedTotalBytes);
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes]; 
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    // copy file to destination URL
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NKIssue *dnlIssue = dnl.issue;
    NSLog(@"Issue downloaded: %@", dnlIssue); // should be the same as nkIssue
    NSString *contentPath = [publisher downloadPathForIssue:dnlIssue];
    NSLog(@"File is being unzipped to %@",contentPath);
    
    [SSZipArchive unzipFileAtPath:[destinationURL path] toDestination:contentPath];
    if (publisher){

        // update the Newsstand icon
        UIImage *img = [publisher coverImageForIssue:dnlIssue];
        if(img) {
            [[UIApplication sharedApplication] setNewsstandIconImage:img]; 
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:kLibraryViewControllerDidFinishDownloading object:dnlIssue];
        [self decrementDownloadingAssets];
        if (![self isDownloadingAssets])
        {
            [self hideDownloadingAssetsOverlay];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NKIssue *dnlIssue = dnl.issue;
    [[NSNotificationCenter defaultCenter] postNotificationName:kLibraryViewControllerDidFailDownloading object:dnlIssue];
    [self decrementDownloadingAssets];
    if (![self isDownloadingAssets])
    {
        [self hideDownloadingAssetsOverlay];
    }
}

@end
