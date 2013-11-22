//
//  PKDataManager.h
//  ReactionTime
//
//  Created by Aaron Parecki on 11/22/13.
//  Copyright (c) 2013 Aaron Parecki. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const PKAPIEndpointDefaultsName = @"PKAPIEndpointDefaults";
static NSString *const PKSaveResultsDefaultsName = @"PKSaveResultsDefaults";
static NSString *const PKSendingStartedNotification = @"PKSendingStartedNotification";
static NSString *const PKSendingFinishedNotification = @"PKSendingFinishedNotification";

@interface PKDataManager : NSObject

+ (PKDataManager *)sharedManager;

@property (readonly) BOOL sendInProgress;
@property (strong, nonatomic, readonly) NSDate *lastSentDate;

- (void)addEntryToQueue:(NSDictionary *)data withKey:(NSString *)key;
- (void)numberOfEntriesInQueue:(void(^)(long num))callback;
- (void)deleteEntryFromQueue:(NSString *)key;
- (void)scheduleSend;
- (void)sendQueueNow;

@end
