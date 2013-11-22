//
//  PKDataManager.m
//  ReactionTime
//
//  Created by Aaron Parecki on 11/22/13.
//  Copyright (c) 2013 Aaron Parecki. All rights reserved.
//

#import "PKDataManager.h"
#import "LOLDatabase.h"
#import "AFHTTPSessionManager.h"

@interface PKDataManager()

@property BOOL sendInProgress;
@property (strong, nonatomic) NSDate *lastSentDate;
@property (strong, nonatomic) NSTimer *scheduleSendTimer;

@property (strong, nonatomic) LOLDatabase *db;

@end

@implementation PKDataManager

static NSString *const PKCollectionQueueName = @"PKCollectionQueue";

AFHTTPSessionManager *_httpClient;

+ (PKDataManager *)sharedManager {
    static PKDataManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            
            _instance.db = [[LOLDatabase alloc] initWithPath:[self cacheDatabasePath]];
            _instance.db.serializer = ^(id object){
                return [self dataWithJSONObject:object error:NULL];
            };
            _instance.db.deserializer = ^(NSData *data) {
                return [self objectFromJSONData:data error:NULL];
            };
            
            [_instance setupHTTPClient];
        }
    }
    
    return _instance;
}

- (void)setupHTTPClient {
    NSURL *endpoint = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:PKAPIEndpointDefaultsName]];
    
    _httpClient = [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", endpoint.scheme, endpoint.host]]];
    _httpClient.requestSerializer = [AFJSONRequestSerializer serializer];
    _httpClient.responseSerializer = [AFJSONResponseSerializer serializer];
}

#pragma mark LOLDB

+ (NSString *)cacheDatabasePath
{
	NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	return [caches stringByAppendingPathComponent:@"PKDBCache.sqlite"];
}

+ (id)objectFromJSONData:(NSData *)data error:(NSError **)error;
{
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
}

+ (NSData *)dataWithJSONObject:(id)object error:(NSError **)error;
{
    return [NSJSONSerialization dataWithJSONObject:object options:0 error:error];
}

#pragma mark - Queue

- (void)addEntryToQueue:(NSDictionary *)data withKey:(NSString *)key
{
    NSLog(@"Adding Entry: %@", data);
	[self.db accessCollection:PKCollectionQueueName withBlock:^(id<LOLDatabaseAccessor> accessor) {
        [accessor setDictionary:data forKey:key];
	}];
}

- (void)numberOfLocationsInQueue:(void(^)(long num))callback {
    [self.db accessCollection:PKCollectionQueueName withBlock:^(id<LOLDatabaseAccessor> accessor) {
        [accessor countObjectsUsingBlock:callback];
    }];
}

- (void)sendingStarted {
    self.sendInProgress = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:PKSendingStartedNotification object:self];
}

- (void)sendingFinished {
    self.sendInProgress = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:PKSendingFinishedNotification object:self];
}

- (void)scheduleSend {
    // Sets a delay to send the data. If no new points are entered within the window, the data is sent
    if(!self.sendInProgress) {
        if(self.scheduleSendTimer) {
            // If there is already a timer, cancel it and set a new timer
            [self.scheduleSendTimer invalidate];
        }
        self.scheduleSendTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(sendNowAfterSchedule) userInfo:nil repeats:NO];
    }
}

// This method is run after the NSTimer fires, which means the data may or may not have already been sent anyway
- (void)sendNowAfterSchedule {
    NSLog(@"Timer fired");
    if(self.scheduleSendTimer && !self.sendInProgress) {
        [self.scheduleSendTimer invalidate];
        self.scheduleSendTimer = nil;
        [self sendQueueNow];
    }
}

- (void)sendQueueNow {
    [self sendingStarted];
    
    NSMutableSet *syncedEntries = [NSMutableSet set];
    NSMutableArray *entries = [NSMutableArray array];
    
    [self.db accessCollection:PKCollectionQueueName withBlock:^(id<LOLDatabaseAccessor> accessor) {
        
        [accessor enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *object) {
            [syncedEntries addObject:key];
            [entries addObject:object];
            return (BOOL)(entries.count >= 20);
        }];
        
    }];
    
    if(entries.count == 0) {
        [self sendingFinished];
        return;
    }
    
    NSDictionary *postData = @{@"entries": entries};
    
    NSString *endpoint = [[NSUserDefaults standardUserDefaults] stringForKey:PKAPIEndpointDefaultsName];
    NSLog(@"Endpoint: %@", endpoint);
    NSLog(@"Entries in post: %lu", (unsigned long)entries.count);
    
    [_httpClient POST:endpoint parameters:postData success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        
        if([responseObject objectForKey:@"result"] && [[responseObject objectForKey:@"result"] isEqualToString:@"ok"]) {
            self.lastSentDate = NSDate.date;
            
            [self.db accessCollection:PKCollectionQueueName withBlock:^(id<LOLDatabaseAccessor> accessor) {
                for(NSString *key in syncedEntries) {
                    [accessor removeDictionaryForKey:key];
                }
            }];
            
            [self sendingFinished];
        } else {
            
            if([responseObject objectForKey:@"error"]) {
                [self notify:[responseObject objectForKey:@"error"] withTitle:@"Error"];
                [self sendingFinished];
            } else {
                [self notify:[responseObject description] withTitle:@"Error"];
                [self sendingFinished];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        [self notify:error.description withTitle:@"Error"];
        [self sendingFinished];
    }];
    
}

#pragma mark -

- (void)notify:(NSString *)message withTitle:(NSString *)title
{
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    } else {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        localNotification.alertBody = [NSString stringWithFormat:@"%@: %@", title, message];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

@end
