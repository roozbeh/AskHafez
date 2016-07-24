//
//  HafezAPI.m
//  AskHafezNative4
//
//  Created by Roozbeh Zabihollahi on 7/17/16.
//
//

#import "HafezAPI.h"

#define DEBUG_API_COMM

static HafezAPI *gInstance = NULL;

@implementation HafezAPI

+ (HafezAPI *) instance {
    @synchronized(self)
    {
        if (gInstance == NULL) {
            gInstance = [[self alloc] init];
        }
    }
    
    return(gInstance);
}

- (BOOL) checkResult:(NSDictionary *) jsonDict {
    NSString *s = [jsonDict valueForKey:@"success"];
    if(![s boolValue]) {
        return NO;
    }
    
    return YES;
}

- (NSString *) sendPostRequest:(NSString *) url withPost:(NSString *) postStr {
#ifdef DEBUG_API_COMM
    NSLog(@"[API] POST to %@", url);
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPBody:[postStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection  sendSynchronousRequest:request returningResponse: &response error: &error];
    return [NSString stringWithCString:[data bytes] length:[data length]];
}

- (NSDictionary *) sendPostRequestJson:(NSString *) url withPost:(NSString *) postStr {
    NSString *output = [self sendPostRequest:url withPost:postStr];
    
#ifdef DEBUG_API_COMM
    NSLog(@"[API] POST \n   url: %@\n   request: %@ \n   response %@", url, postStr, output);
#endif
    NSError *e = nil;
    NSData *jsonData = [output dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error: &e];
    
    return jsonDict;
}

- (NSDictionary *) sendGetRequestJson:(NSString *) url {
#ifdef DEBUG_API_COMM
    NSLog(@"[API] GET to %@", url);
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *apiHost = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"ApiHost"];
    
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection  sendSynchronousRequest:request returningResponse: &response error: &error];
    NSString *output = [NSString stringWithCString:[data bytes] length:[data length]];
#ifdef DEBUG_API_COMM
    NSLog(@"[API] Received %@", output);
#endif
    
    NSError *e = nil;
    NSData *jsonData = [output dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error: &e];
    
    if (e) {
        NSLog(@"Error: %@", e);
    }
    
    return jsonDict;
}

- (BOOL) sendToken:(NSString *) token {
    NSString *apiHost = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"ApiHost"];
    NSString *url = [NSString stringWithFormat:@"%@/setToken.php",
                     apiHost];
    
    NSString *post = [NSString stringWithFormat:@"token=%@&os=ios&uniq=%@",
                      token, [self identifierForVendor1]];
    
    NSDictionary *jsonDict = [self sendPostRequestJson:url withPost:post];
    if (!jsonDict) {
        return NO;
    }
    
    if (jsonDict[@"success"] && [jsonDict[@"success"] boolValue]) {
        return YES;
    }

    return NO;
}

- (void) saveSetting:(NSString *) key withValue: (NSString *) value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

- (NSString *) getSetting:(NSString *) key withDefault: (NSString *) defaultValue
{
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (value == nil) {
        return defaultValue;
    }
    
    return value;
}

- (void) removeSetting:(NSString *) key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}

- (NSString *) getSetting:(NSString *) key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (NSString *) identifierForVendor1
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return @"";
}

@end
