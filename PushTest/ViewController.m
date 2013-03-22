//
//  ViewController.m
//  PushTest
//
//  Created by Ivan Ilyin on 3/19/13.
//  Copyright (c) 2013 Exadel. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UILabel *oldToken;
@property (nonatomic, strong) IBOutlet UILabel *lbNewToken;
@property (nonatomic, strong) IBOutlet UITextField *service;

@end

@implementation ViewController

@synthesize oldToken, lbNewToken, service;

- (void)dealloc
{
    self.oldToken = nil;
    self.lbNewToken = nil;
    self.service = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self load];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)generateTokens
{
    self.oldToken.text = self.lbNewToken.text;
    self.lbNewToken.text = [NSString new];
    for (int i = 0; i < 10; i++)
    {
        self.lbNewToken.text = [self.lbNewToken.text stringByAppendingFormat:@"%2x", (int)(rand() * 15 / 100)];
    }
}

- (void)sendRequest
{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?oldId='%@'&newId='%@'", self.service.text, self.oldToken.text, self.lbNewToken.text]]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *resp, NSData *data, NSError *er) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        if (er)
            [[[UIAlertView alloc] initWithTitle:@"Error" message:er.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Succeeded" message:@"Request has been sent successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (IBAction)onGenerate:(id)sender
{
    [self generateTokens];
    [self save];
}

- (IBAction)onSend:(id)sender
{
    [self sendRequest];
    [self save];
}

- (void)save
{
    NSString *folder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.lbNewToken.text, @"newkey", self.oldToken.text, @"oldkey", self.service.text, @"service",nil];
    [dictionary writeToFile:[folder stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
}

- (void)load
{
    NSString *folder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[folder stringByAppendingPathComponent:@"settings.plist"]];
    self.oldToken.text = [dictionary valueForKey:@"oldkey"];
    self.lbNewToken.text = [dictionary valueForKey:@"newkey"];
    self.service.text = [dictionary valueForKey:@"service"];
}

- (void)updateDeviceToken:(NSString*)token
{
    self.oldToken.text = self.lbNewToken.text;
    self.lbNewToken.text = token;
    [self save];
}

@end
