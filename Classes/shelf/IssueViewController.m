//
//  IssueViewController.m
//
//  Created by Bart Termorshuizen on 6/18/11.
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

#import "IssueViewController.h"
#import "Issue.h"
#import "Cover.h"
#import "Content.h"
#import "BakerAppDelegate.h"
#import "BakerViewController.h"

@implementation IssueViewController

@synthesize issue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Initiate issue status
        [issue setStatus:[NSNumber numberWithInt:-1]];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CGRect frame = issueView.frame;                    
    [[self view] setFrame:frame];
    
    [labelView setText:[issue title]];
    [descriptionView setText:[issue descr]];
    
    Cover *c =(Cover *)[issue cover];
    if ([[c path] isEqualToString:@""] || [c path] == nil) {
        // use dummy image
    }
    else {
        UIImage * coverImage = [[UIImage alloc] initWithContentsOfFile:[(Cover *)[issue cover] path]];
        [coverView setImage:coverImage];
        [coverImage release];
    }
    
    if ([[issue status] intValue] == 1 ) // issue is not downloaded
    {
        [buttonView setTitle:@"Download" forState:UIControlStateNormal];
    }
    if ([[issue status] intValue] == 2) // issue is downloaded - can be archived
    {
        [buttonView setTitle:@"Archive" forState:UIControlStateNormal];
    }    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resolvedCover:) name:@"coverResolved" object:nil ] ;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadedContent:) name:@"contentDownloaded" object:nil ] ;

    
    // Clear the progressbar and make it invisible
    progressView.progress = 0;
    progressView.hidden = YES;
    
    return;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(IBAction) btnClicked:(id) sender {
    
    if ([[issue status] intValue] != 0 ) // issue is NOT downloading
    {
      if ([[issue status] intValue] == 1 ) // issue is not downloaded
      {
          // Set status do 0 -> DOWNLOADING
          [issue setStatus:[NSNumber numberWithInt:0]];
          [buttonView setTitle:@"Wait..." forState:UIControlStateNormal];

          // Set progressView to Content
          [(Content *)[issue content] resolve:progressView];
      }
      else if ([[issue status] intValue] == 2 ) // issue is downloaded - needs to be archived
      {
          UIAlertView *updateAlert = [[UIAlertView alloc] 
                                      initWithTitle: @"Are you sure you want to archive this item?"
                                      message: @"This item will be removed from your device. You may download it at anytime for free."
                                      delegate: self
                                      cancelButtonTitle: @"Cancel"
                                      otherButtonTitles:@"Archive",nil];
          [updateAlert show];
          [updateAlert release];
      }
    }
}

-(IBAction) btnRead:(id) sender{
    if ([[issue status] intValue] == 2 ) // issue is downloaded
    {       
        NSLog(@"IssueViewController - Opening BakerViewController");  
        BakerAppDelegate *appDelegate = (BakerAppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController* navigationController = [appDelegate navigationController];

        BakerViewController * bvc = [BakerViewController alloc];
        
        [bvc initWithMaterial:issue];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration: 0.50];
        
        //Hook To MainView
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:navigationController.view cache:YES];
        
		[navigationController popViewControllerAnimated:YES];
        [navigationController pushViewController:(UIViewController*)bvc animated:NO];    
        [navigationController setToolbarHidden:YES animated:NO];
        [navigationController setNavigationBarHidden:YES];
        
        [bvc release];
        
        [UIView commitAnimations];            
    }
    else // issue is not downloaded 
    {
        NSLog(@"Cannot read");        
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        NSError * error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[(Content *)[issue content] path]  error:&error];
        if (error) {
            // implement error handling
        } else {
            Content * c = (Content *)[issue content];
            [c setPath:@""];
            [issue setStatus:[NSNumber numberWithInt:1]];
            [buttonView setTitle:@"Download" forState:UIControlStateNormal];
            // notify all interested parties of the archived content
            [[NSNotificationCenter defaultCenter] postNotificationName:@"contentArchived" object:self]; // make sure its persisted!
        }
    }
    
}

- (void) resolvedCover:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"coverResolved"]){
        // check if it is the correct cover
        if ([notification object] == [issue cover]){
            NSLog (@"IssueViewController: Received the coverResolved notification!");
            UIImage * coverImage = [[UIImage alloc] initWithContentsOfFile:[(Cover *)[issue cover] path]];
            [coverView setImage:coverImage];
            [coverImage release];
        }
                
    }
    
}

- (void) downloadedContent:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"contentDownloaded"]){
        // check if it is the correct cover
        if ([notification object] == [issue content]){
            NSLog (@"IssueViewController: Received the contentDownloaded notification!");
            [issue setStatus:[NSNumber numberWithInt:2]];
            [buttonView setTitle:@"Archive" forState:UIControlStateNormal];
            
            
            // Update the Newsstand icon
            if (isOS5()) {
              UIImage *img = [[UIImage alloc] initWithContentsOfFile:[(Cover *)[issue cover] path]];

              if (img) {
                  [[UIApplication sharedApplication] setNewsstandIconImage:img];
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
              }
                [img release];
            }
        }
    }
    
}

@end
