//
//  CommonUtils.m
//  RSI 2
//
//  Created by Roozbeh on ۱۲/۱۰/۲۹.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils

+ (void)alert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];

    [alert show];
}

@end
