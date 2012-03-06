//
//  Content.m
//
//  Created by Bart Termorshuizen on 7/10/11.
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
#import "Content.h"
#import "Issue.h"
#import "SSZipArchive.h"
#import "IssueViewController.h"


@implementation Content
@dynamic path;
@dynamic url;
@dynamic issue;


- (void)resolve:(UIProgressView *) progressView
{
    // Set the progress view
    progressViewC = progressView;
    
    // Code updated to use newsstandKit functions to download issue
    
    // let's retrieve the NKIssue
    nkLib = [NKLibrary sharedLibrary];
    nkIssue = [nkLib issueWithName:[[[self issue] number] stringValue]];

    // let's get the publisher's server URL (stored in the issues plist) 
    NSURL *downloadURL = [[NSURL alloc] initWithString:[self url]];

    if(!downloadURL) return;
    
    // let's create a request and the NKAssetDownload object
    NSURLRequest *req = [NSURLRequest requestWithURL:downloadURL];
    NKAssetDownload *assetDownload = [nkIssue addAssetWithRequest:req];
    [assetDownload setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [[self issue] number], @"Index", nil]];

    // let's start download
    [assetDownload downloadWithDelegate:self];
        
    return;    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	NSDictionary *allHeaders = [((NSHTTPURLResponse *)response) allHeaderFields];
	NSLog(@"%@", allHeaders);

    
	if ([response respondsToSelector:@selector(statusCode)]) 
	{
		int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		
		// IF THE PAGE CANNOT BE FOUND CANCEL THE DOWNLOAD AND PRESENT A WARNING MESSAGE
        if (statusCode != 200)  
		{
			[connection cancel]; 
			NSString *errorMessage = [NSString stringWithFormat:@"Unable to download the prices file.  Prices shown may therefore not be current."];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occured" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			
			[alertView show];
			[alertView release], alertView = nil;
            
            // OTHERWISE CONTINUE WITH THE DOWNLOAD
		} else {
			if ( [response expectedContentLength] != NSURLResponseUnknownLength )
			{
				filesize = [[NSNumber numberWithLong: [response expectedContentLength] ] retain];
				NSLog(@"Length Avaialble (%@)", filesize);
			}
			else
			{
				//NSDictionary *allHeaders = 
				NSLog(@"Length NOT Avaialble");
			}
            
			//NSLog(@"Started to receive data");
            [receivedData setLength:0];
		}
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    float progress;
    progress = [receivedData length]/[filesize floatValue];
    
    // Update the progress value
    progressViewC.hidden = NO;
    progressViewC.progress = progress;

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
    NSLog(@"Content - Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    return;
}


// Methods for NSURLConnectionDownloadDelegate protocol
//
-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}


-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {    

    // Update the progress value
    progressViewC.hidden = NO;
    progressViewC.progress = 1.f*totalBytesWritten/expectedTotalBytes;    
}


-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    // copy file to destination URL
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    nkIssue = dnl.issue;
    NSString *contentPath = [[nkIssue.contentURL path] stringByAppendingPathComponent:@"issue.zip"];

    // Make progress bar invisible
    progressViewC.hidden = YES;
    
    NSError *error = nil;

    if([[NSFileManager defaultManager] moveItemAtPath:[destinationURL path] toPath:contentPath error:&error]==NO) {
        NSLog(@"Error copying file from %@ to %@", destinationURL, contentPath);
    }
    else {
        // unzip
        [SSZipArchive unzipFileAtPath:contentPath toDestination:[destinationURL path] overwrite:YES password:nil error:&error ];

        // remove downloaded file
        [[NSFileManager defaultManager] removeItemAtPath:contentPath error:NULL];
        if (error){
            NSLog(@"Content - Unzip failed! Error - %@  - %@",[error localizedDescription],[error userInfo]);
        }
        else {
            // update path component
            [self setPath:[destinationURL path]];
            // notify all interested parties of the uploaded and unpacked content
            [[NSNotificationCenter defaultCenter] postNotificationName:@"contentDownloaded" object:self];
        }
        
        
    }
}

@end
