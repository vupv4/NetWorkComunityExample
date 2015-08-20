//
//  MainVC.m
//  TypeDataExample
//
//  Created by Vu Phan on 4/4/15.
//  Copyright (c) 2015 Viettel. All rights reserved.
//

#import "MainVC.h"
#import "AFHTTPRequestOperationManager.h"
#import "ZipArchive.h"

#define POST_LINK @"http://vupv4.webege.com/mainPostMethod.php"
#define LINK_DOWNLOAD  @"http://vupv4.webege.com/Webbage.zip"
@interface MainVC ()

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

#pragma mark GET method
- (IBAction)getData:(id)sender {
    
    //http://vupv4.webege.com/mainPostMethod.php
    //http://vupv4.webege.com/mainGetMethod.php
    
    NSURL *url = [NSURL URLWithString:@"http://vupv4.webege.com/mainGetMethod.php?soa=6&sob=2"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    Parse data thanh Json
//    NSError *jsonError;
//    NSData *objectData = [ret dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
//                                                         options:NSJSONReadingMutableContainers
//                                                           error:&jsonError];

    self.lbShowResult.text = ret;
    
    //**********USE AF NETWORKING 2.0
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSURL *baseURL = [[NSURL alloc]initWithString:@"http://vupv4.webege.com/mainGetMethod.php"];
//    [manager GET:[baseURL absoluteString]
//      parameters:@{ @"soa": @"12", @"sob": @"5"}
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             // handle success
//             NSLog(@"success");
//         }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSLog(@"Failed");
//         }];
}


#pragma mark POST method
- (IBAction)postData:(id)sender {
    
    // ******** user post method systems
    //Set post string
    NSString *post = [NSString stringWithFormat:@"soa=%@&sob=%@",@"2",@"14"];
    //Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    //Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:@"http://vupv4.webege.com/mainPostMethod.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(conn) {
        self.lbShowResult.text = @"Connection Successful";
    } else {
        self.lbShowResult.text = @"Connection could not be made";
    }
    
    //**********USE AF NETWORKING 2.0
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *params = @{@"soa": @"12", @"sob": @"4"};
//    [manager POST:POST_LINK parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
    
}

// This method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {

//    NSError *jsonError;
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
//                                                         options:NSJSONReadingMutableContainers
//                                                           error:&jsonError];
    
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.lbShowResult.text = ret;
}

// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.lbShowResult.text = @"didFailWithError";
}

// This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    self.lbShowResult.text = @"connectionDidFinishLoading";
}

#pragma mark DOWNLOAD method
- (IBAction)downloadFile:(id)sender {
   
    // 1
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:LINK_DOWNLOAD];
        NSError *error = nil;
        // 2
        NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
        
        if(!error)
        {
            // 3
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *path = [paths objectAtIndex:0];
            NSString *zipPath = [path stringByAppendingPathComponent:@"zipfile.zip"];
            
            [data writeToFile:zipPath options:0 error:&error];
            
            if(!error)
            {
                ZipArchive *za = [[ZipArchive alloc] init];
                // 1
                if ([za UnzipOpenFile: zipPath]) {
                    // 2
                    BOOL ret = [za UnzipFileTo: path overWrite: YES];
                    if (NO == ret){} [za UnzipCloseFile];
                    
                    // 3

                    NSString *textFilePath = [path stringByAppendingPathComponent:@"Webbage"];
                    textFilePath = [textFilePath stringByAppendingPathComponent:@"getContact.php"];
                    NSString *textString = [NSString stringWithContentsOfFile:textFilePath
                                                                     encoding:NSASCIIStringEncoding error:nil];
                    
                    // 4           
                    dispatch_async(dispatch_get_main_queue(), ^{

                        self.lbShowResult.text = textString;
                    });
            }
            else
            {
                NSLog(@"Error saving file %@",error);
            }
        }
        else
        {
            NSLog(@"Error downloading zip file: %@", error);
        }
        
        }
    });
}

@end
