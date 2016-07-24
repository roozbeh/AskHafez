//
//  HafezAPI.h
//  AskHafezNative4
//
//  Created by Roozbeh Zabihollahi on 7/17/16.
//
//

#import <Foundation/Foundation.h>

@interface HafezAPI : NSObject

- (BOOL) sendToken:(NSString *) token;
+ (HafezAPI *) instance;

- (void) saveSetting:(NSString *) key withValue: (NSString *) value;
- (NSString *) getSetting:(NSString *) key withDefault: (NSString *) defaultValue;

- (NSString *) getSetting:(NSString *) key;

- (void) removeSetting:(NSString *) key;
@end
