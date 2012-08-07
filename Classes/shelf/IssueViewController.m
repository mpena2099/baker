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
#import "BakerAppDelegate.h"
#import "BakerViewController.h"
#import "SSZipArchive.h"
#import "LibraryViewController.h"

@implementation IssueViewController

@synthesize publisher, index;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NSString* issueTitle=[publisher titleOfIssueAtIndex:index];
    nkIssue = [nkLib issueWithName:issueTitle];
    
    [labelView setText:[[self publisher] titleOfIssueAtIndex:[self index]]];
    [descriptionView setText:[[self publisher] descriptionOfIssueAtIndex:[self index]]];
    
    coverView.image=nil; // reset image as it will be retrieved asychronously
    [publisher setCoverOfIssueAtIndex:index completionBlock:^(UIImage *img) {
        dispatch_async(dispatch_get_main_queue(), ^{
            coverView.image=img;
        });
    }];
    //
    
    [progressView setHidden:YES];
    
    if(nkIssue.status==NKIssueContentStatusAvailable) {
        [buttonView setTitle:@"Excluir" forState:UIControlStateNormal];
    } 
    else if(nkIssue.status==NKIssueContentStatusDownloading) {
        [buttonView setTitle:@"Aguarde..." forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kLibraryViewDidFinishDownloading:) name:kLibraryViewControllerDidFinishDownloading object:nkIssue];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LibraryViewDidFailDownloading:) name:kLibraryViewControllerDidFailDownloading object:nkIssue];
    } 
    else {
        [buttonView setTitle:@"Baixar" forState:UIControlStateNormal];
        
    }
    return;
}

- (void)LibraryViewDidFinishDownloading:(NSNotification*)not
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLibraryViewControllerDidFinishDownloading object:nkIssue];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLibraryViewControllerDidFailDownloading object:nkIssue];
    [buttonView setTitle:@"Excluir" forState:UIControlStateNormal];
}

- (void)LibraryViewDidFailDownloading:(NSNotification*)not
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLibraryViewControllerDidFinishDownloading object:nkIssue];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLibraryViewControllerDidFailDownloading object:nkIssue];
    [buttonView setTitle:@"Baixar" forState:UIControlStateNormal];
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
    /*
    if  (nkIssue.status==NKIssueContentStatusDownloading){
        // still downloading
        [buttonView setTitle:@"Wait..." forState:UIControlStateNormal];
    }
    else */
    if (nkIssue.status==NKIssueContentStatusNone){
        // wait message
        [buttonView setTitle:@"Aguarde..." forState:UIControlStateNormal];
        // start download
        NSURL *downloadURL = [publisher contentURLForIssueWithName:nkIssue.name];
        if(!downloadURL) return;
        NSURLRequest *req = [NSURLRequest requestWithURL:downloadURL];
        NKAssetDownload *assetDownload = [nkIssue addAssetWithRequest:req];
        [assetDownload downloadWithDelegate:self];
    }
    else if (nkIssue.status==NKIssueContentStatusAvailable){
        // archive
        UIAlertView *updateAlert = [[UIAlertView alloc] 
                                    initWithTitle: @"Você tem certeza que quer excluir esse item?"
                                    message: @"Esse item será removido do seu iPad. Você poderá baixa-lo novamente a qualquer hora."
                                    delegate: self
                                    cancelButtonTitle: @"Cancelar"
                                    otherButtonTitles:@"Excluir",nil];
        [updateAlert show];
        [updateAlert release];
    }
}


-(void) openBakerThred {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //sleep(5);  // sleep for 5 seconds

        NSLog(@"IssueViewController - Opening BakerViewController");  
        BakerAppDelegate *appDelegate = (BakerAppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController* navigationController = [appDelegate navigationController];
        
        BakerViewController * bvc = [BakerViewController alloc];
        [bvc initWithMaterial:nkIssue];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration: 0.50];
        
        //Hook To MainView
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:navigationController.view cache:YES];
        
        
        [navigationController popViewControllerAnimated:YES];
        [navigationController pushViewController:(UIViewController*)bvc animated:NO];    
        [navigationController setToolbarHidden:YES animated:NO];
        [navigationController setNavigationBarHidden:YES];
        
        [bvc release];
        
        
        // hidden activity view indicator
        [activityView stopAnimating];    
        
        [UIView commitAnimations]; 
        
    });
    
}


-(IBAction) btnRead:(id) sender{
    
    if (nkIssue.status == NKIssueContentStatusAvailable) // issue is downloaded
    {     
        NSLog(@"READ");   
        
        // shows activity view indicator
        [activityView startAnimating];
        
        // Open Baker in other thred
        [self performSelectorInBackground:@selector(openBakerThred) withObject:nil];
        
    }
    else // issue is not downloaded 
    {
        NSLog(@"Cannot read");        
    }
    
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        NSLog(@"Archiving %@",nkIssue);
        nkIssue = [publisher removeIssueAtIndex:[self index]];
        [buttonView setTitle:@"Baixar" forState:UIControlStateNormal];
        [progressView setHidden:YES];
    }
}

#pragma mark - NSURLConnectionDownloadDelegate


-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [progressView setHidden:NO];
    progressView.progress=1.f*totalBytesWritten/expectedTotalBytes;   
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
    [progressView setHidden:YES];
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NKIssue *dnlIssue = dnl.issue;
    NSLog(@"Issue downloaded: %@", dnlIssue); // should be the same as nkIssue
    NSString *contentPath = [publisher downloadPathForIssue:nkIssue];
    NSLog(@"File is being unzipped to %@",contentPath);

    [SSZipArchive unzipFileAtPath:[destinationURL path] toDestination:contentPath];
    // update the Newsstand icon
    UIImage *img = [publisher coverImageForIssue:nkIssue];
    if(img) {
        [[UIApplication sharedApplication] setNewsstandIconImage:img]; 
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    }
    [buttonView setTitle:@"Excluir" forState:UIControlStateNormal];
}

@end
