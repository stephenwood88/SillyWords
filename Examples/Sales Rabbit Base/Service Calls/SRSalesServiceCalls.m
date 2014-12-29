//
//  SRSalesServiceCalls.m
//  Original Sales
//
//  Created by Matthew McArthur on 10/21/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRSalesServiceCalls.h"
#import "SRGlobalState.h"
#import "Constants.h"
#import "SRConstants.h"
#import "Lead+Rabbit.h"
#import "AVTextUtilities.h"

@interface SRSalesServiceCalls ()

@property (nonatomic) BOOL syncScheduled;
@property (nonatomic) BOOL syncRunning;
@property (nonatomic, strong) NSPredicate *leadSyncPredicateTemplate;
@property (nonatomic, strong) NSPredicate *leadUpdatePredicateTemplate;

@property (strong, nonatomic) NSDate *lastLeadSyncServer;
@property (strong, nonatomic) NSDate *lastLeadSyncDevice;


@end

@implementation SRSalesServiceCalls

- (id)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (self) {
        self.syncScheduled = NO;
        self.syncRunning = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTimestampsInNSUserDefaults) name:kCoreDataAutoSaved object:nil];
        
    }
    return self;
}

-(void)updateTimeStampsAfterLogin{
    NSString *userId = [[SRGlobalState singleton] userId];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.lastLeadSyncServer = [[defaults objectForKey:kLastLeadSyncServerTimestamps] objectForKey:userId];
    self.lastLeadSyncDevice = [[defaults objectForKey:kLastLeadSyncDeviceTimestamps] objectForKey:userId];
}

- (void)sync
{
    [self syncLeads];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/syncleads/
 */
- (void)syncLeads:(NSArray *)leads modifiedSince:(NSDate *)date delete:(NSArray *)deleteLeads completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (date) {
        params[@"modifiedSince"] = [NSNumber numberWithLongLong:[[NSNumber numberWithDouble:date.timeIntervalSince1970 * 1000] longLongValue]];
    }
    if (deleteLeads && deleteLeads.count) {
        params[@"leadsToDelete"] = deleteLeads;
    }
    if (leads && leads.count) {
        NSMutableArray *leadsJson = [NSMutableArray arrayWithCapacity:leads.count];
        for (Lead *lead in leads) {
            [leadsJson addObject:[lead proxyForJson]];
        }
        params[@"leads"] = leadsJson;
    }
    [self postServiceCall:@"syncLeads" withParameters:params includeDepartment:YES completionHandler:^(BOOL success, id result, NSError *error) {
        if (success) {
            completionHandler(YES, result, nil);
        }
        else {
            completionHandler(NO, nil, error);
        }
    }];
}

- (void)syncLeads {
    
    if (self.syncRunning) {
        // Assuming that since these methods will all be called on the main thread, syncScheduled will always be atomically set to NO right after syncRunning is set to YES. This method should never be called in between those two lines or parallel syncs will be scheduled.
        [self scheduleLeadSyncAfterDelay:kSecondsBetweenLeadSyncs];
    }
    else if (!self.syncScheduled) {
        NSDate *lastSyncDevice = self.lastLeadSyncDevice;
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval delay = kSecondsBetweenLeadSyncs - (now - lastSyncDevice.timeIntervalSince1970);
        if (delay <= 0) {
            //NSLog(@"sync leads now");
            [self performLeadSync];
        }
        else {
            //NSLog(@"sync leads after delay of %f seconds", delay);
            [self scheduleLeadSyncAfterDelay:delay];
        }
    }
}

- (void)scheduleLeadSyncAfterDelay:(NSTimeInterval)delay {
    
    self.syncScheduled = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performLeadSync) object:nil];
    [self performSelector:@selector(performLeadSync) withObject:nil afterDelay:delay];
}

- (void)performLeadSync {
    
    if (self.syncRunning) {
        // If sync is still in progress (shouldn't be after waiting kSecondsBetweenLeadSyncs), reschedule it again.
        [self scheduleLeadSyncAfterDelay:kSecondsBetweenLeadSyncs];
        return;
    }
    //NSLog(@"perform lead sync...");
    self.syncRunning = YES;
    self.syncScheduled = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [[SRGlobalState singleton] userId];
    
    NSArray *leadIdsToDelete = [defaults objectForKey:kDeletedLeadIds];
    
    NSFetchRequest *syncFetch = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
    if (self.lastLeadSyncDevice) {
        syncFetch.predicate = [self.leadSyncPredicateTemplate predicateWithSubstitutionVariables:@{@"USER_ID": userId, @"LAST_SYNC": self.lastLeadSyncDevice}];
    }
    else {
        // First sync won't have a last sync date
        syncFetch.predicate = [NSPredicate predicateWithFormat:@"(userId == %@) AND (saved == YES)", userId];
    }
    self.lastLeadSyncDevice = [NSDate date];
    
    NSError *error = nil;
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSArray *leadsToSync = [context executeFetchRequest:syncFetch error:&error];
    if (!error) {
        [self syncLeads:leadsToSync modifiedSince:self.lastLeadSyncServer delete:leadIdsToDelete completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
            if (success) {
                
                NSMutableArray *addedLeads = [NSMutableArray array];
                NSMutableArray *updatedLeads = [NSMutableArray array];
                NSArray *deletedLeads = @[];
                // Update leads
                NSDictionary *oldLeads = result[@"OldLeads"];
                if (oldLeads && oldLeads.count) {
                    NSArray *oldLeadIds = [oldLeads allKeys];
                    NSFetchRequest *updateFetch = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
                    updateFetch.predicate = [self.leadUpdatePredicateTemplate predicateWithSubstitutionVariables:@{@"LEAD_IDS": oldLeadIds}];
                    NSArray *leadsToUpdate = [context executeFetchRequest:updateFetch error:&error];
                    
                    if (!error) {
                        NSMutableDictionary *leadsToUpdateDict = [NSMutableDictionary dictionaryWithCapacity:leadsToUpdate.count];
                        for (Lead *lead in leadsToUpdate) {
                            leadsToUpdateDict[lead.leadId] = lead;
                        }
                        for (NSString *leadId in oldLeads) {
                            NSAssert([leadId isKindOfClass:[NSString class]], @"Expecting lead ID keys in response to be strings. Are they numbers instead?");
                            NSDictionary *oldLeadDict = oldLeads[leadId];
                            Lead *lead = leadsToUpdateDict[leadId];
                            if (!lead) {
                                lead = [Lead newLead];
                                lead.leadId = leadId;
                                [addedLeads addObject:lead];
                            }
                            else {
                                [updatedLeads addObject:lead];
                            }
                            [lead updateFromJson:oldLeadDict withDateModified:self.lastLeadSyncDevice];
                        }
                    }
                    else {
                        NSLog(@"Error fetching leads to update: %@", error.localizedDescription);
                    }
                }
                // Add lead IDs to newly inserted leads
                
                NSDictionary *newLeads = result[@"NewLeads"];
                if (newLeads && newLeads.count) {
                    NSMutableDictionary *newLeadsToUpdate = [NSMutableDictionary dictionaryWithCapacity:newLeads.count];
                    
                    for (Lead *lead in leadsToSync) {
                        if (!lead.leadId) {
                            newLeadsToUpdate[[NSNumber numberWithLongLong:[[NSNumber numberWithDouble:lead.dateCreated.timeIntervalSince1970 * 1000] longLongValue]]] = lead;
                        }
                    }
                    for (NSString *creationDateString in newLeads) {
                        NSAssert([creationDateString isKindOfClass:[NSString class]], @"Expecting creation dates in new leads to be strings. Are they numbers instead?");
                        NSNumber *creationDate = [AVTextUtilities numberForString:creationDateString];
                        Lead *lead = newLeadsToUpdate[creationDate];
                        NSAssert(lead, @"Got a lead in the NewLeads response that I can't locate! creationDate = %@", creationDate);
                        NSAssert(!lead.leadId, @"This lead shouldn't have a lead ID yet! leadId = %@", lead.leadId);
                        NSAssert([newLeads[creationDateString] isKindOfClass:[NSNumber class]], @"Expecting lead IDs in NewLeads sync response to be numbers. Are they strings instead?");
                        lead.leadId = [newLeads[creationDateString] stringValue];
                    }
                }
                // Remove deleted leads
                NSArray *leadsToDelete = result[@"LeadsToDelete"];
                if (leadsToDelete && leadsToDelete.count) {
                    NSFetchRequest *deleteFetch = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
                    deleteFetch.predicate = [self.leadUpdatePredicateTemplate predicateWithSubstitutionVariables:@{@"LEAD_IDS": leadsToDelete}];
                    deletedLeads = [context executeFetchRequest:deleteFetch error:&error];
                    if (!error) {
                        for (Lead *lead in deletedLeads) {
                            [lead deleteLeadSync:NO];
                        }
                    }
                    else {
                        NSLog(@"Error fetching leads to delete: %@", error.localizedDescription);
                    }
                }
                // Clear lead IDs to delete now that they've been synced
                NSMutableSet *leadIdsToDeleteNow = [NSMutableSet setWithArray:[defaults objectForKey:kDeletedLeadIds]];
                for (NSString *leadId in leadIdsToDelete) {
                    [leadIdsToDeleteNow removeObject:leadId];
                }
                [defaults setObject:leadIdsToDeleteNow.allObjects forKey:kDeletedLeadIds];
                // Update transient sync timestamp
                self.lastLeadSyncServer = [NSDate dateWithTimeIntervalSince1970:([result[@"modifiedAt"] doubleValue] / 1000)];
                
                if (addedLeads.count > 0 || updatedLeads.count > 0 || deletedLeads.count > 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kAddedLeads: [addedLeads copy], kUpdatedLeads: [updatedLeads copy], kDeletedLeads: deletedLeads}];
                }
                self.syncRunning = NO;
                //NSLog(@"leads synced");
            }
            else {
                NSLog(@"Error syncing leads: %@", error.localizedDescription);
                self.syncRunning = NO;
                [self scheduleLeadSyncAfterDelay:kSecondsBetweenLeadSyncs];
            }
        }];
    }
    else {
        NSLog(@"Error fetching leads to sync: %@", error.localizedDescription);
        self.syncRunning = NO;
        [self scheduleLeadSyncAfterDelay:kSecondsBetweenLeadSyncs];
    }
    [self scheduleLeadSyncAfterDelay:kSecondsBetweenLeadSyncs];
}

#pragma mark - Custom Accessors

- (NSPredicate *)leadSyncPredicateTemplate {
    
    if (!_leadSyncPredicateTemplate) {
        _leadSyncPredicateTemplate = [NSPredicate predicateWithFormat:@"(userId == $USER_ID) AND (dateModified > $LAST_SYNC) AND (saved == YES)"];
    }
    return _leadSyncPredicateTemplate;
}

- (NSPredicate *)leadUpdatePredicateTemplate {
    
    if (!_leadUpdatePredicateTemplate) {
        _leadUpdatePredicateTemplate = [NSPredicate predicateWithFormat:@"(leadId IN $LEAD_IDS) AND (saved == YES)"];
    }
    return _leadUpdatePredicateTemplate;
}

#pragma mark - time stamps


- (void)updateTimestampsInNSUserDefaults
{
    if (self.lastLeadSyncServer) {
        
        // Update sync timestamps
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userId = [[SRGlobalState singleton] userId];

        // Update sync timestamps
        NSMutableDictionary *lastSyncDeviceDict = [[defaults objectForKey:kLastLeadSyncDeviceTimestamps] mutableCopy];
        lastSyncDeviceDict[userId] = self.lastLeadSyncDevice;
        [defaults setObject:lastSyncDeviceDict forKey:kLastLeadSyncDeviceTimestamps];
        NSMutableDictionary *lastSyncServerDict = [[defaults objectForKey:kLastLeadSyncServerTimestamps] mutableCopy];
        lastSyncServerDict[userId] = self.lastLeadSyncServer;
        [defaults setObject:lastSyncServerDict forKey:kLastLeadSyncServerTimestamps];
    }
}

@end
