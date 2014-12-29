//
//  SRManagedDocument.m
//  Dish Sales
//
//  Created by Bryan Bryce on 2/3/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
// 

#import "SRManagedDocument.h"
#import "SRGlobalState.h"
#import "SRConstants.h"

@implementation SRManagedDocument

//This method is called when the Core Data store is saved to persistent storage
- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSLog(@"Auto-Saving Document");
    [[NSNotificationCenter defaultCenter] postNotificationName:kCoreDataAutoSaved object:nil];
    return [super contentsForType:typeName error:outError];
}

-(void)autosaveWithCompletionHandler:(void (^)(BOOL))completionHandler{
    
}

//This method is used for handling Core Data errors
- (void)handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted
{
    /*
    NSLog(@"UIManagedDocument error: %@", error.localizedDescription);
    NSArray* errors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    if(errors != nil && errors.count > 0) {
        for (NSError *error in errors) {
            NSLog(@"  Error: %@", error.userInfo);
        }
    } else {
        NSLog(@"  %@", error.userInfo);
    }*/
    
    //NSLog(@"Managed object context has changes: %s", [self.SRGlobalState.managedObjectContext hasChanges]?"Yes":"No");
    if ([[SRGlobalState singleton].managedObjectContext hasChanges]) {
        NSError *error = nil;
        if (![[SRGlobalState singleton].managedObjectContext save:&error]) {
            // Core Data info log output
            /*NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
             NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
             if (detailedErrors != nil && [detailedErrors count] > 0) {
             for(NSError* detailedError in detailedErrors) {
             NSLog(@"  DetailedError: %@", [detailedError userInfo]);
             }
             }
             else {
             NSLog(@"  %@", [error userInfo]);
             }*/
            
            // Better formatted core data info log output
            if ([[error domain] isEqualToString:@"NSCocoaErrorDomain"]) {
                // ...check whether there's an NSDetailedErrors array
                NSDictionary *userInfo = [error userInfo];
                if ([userInfo valueForKey:@"NSDetailedErrors"] != nil) {
                    // ...and loop through the array, if so.
                    NSArray *errors = [userInfo valueForKey:@"NSDetailedErrors"];
                    for (NSError *anError in errors) {
                        
                        NSDictionary *subUserInfo = [anError userInfo];
                        subUserInfo = [anError userInfo];
                        // Granted, this indents the NSValidation keys rather a lot
                        // ...but it's a small loss to keep the code more readable.
                        NSLog(@"Core Data Save Error\n\n \
                              NSValidationErrorKey\n%@\n\n \
                              NSValidationErrorPredicate\n%@\n\n \
                              NSValidationErrorObject\n%@\n\n \
                              NSLocalizedDescription\n%@",
                              [subUserInfo valueForKey:@"NSValidationErrorKey"],
                              [subUserInfo valueForKey:@"NSValidationErrorPredicate"],
                              [subUserInfo valueForKey:@"NSValidationErrorObject"],
                              [subUserInfo valueForKey:@"NSLocalizedDescription"]);
                    }
                }
                // If there was no NSDetailedErrors array, print values directly
                // from the top-level userInfo object. (Hint: all of these keys
                // will have null values when you've got multiple errors sitting
                // behind the NSDetailedErrors key.
                else {
                    NSLog(@"Core Data Save Error\n\n \
                          NSValidationErrorKey\n%@\n\n \
                          NSValidationErrorPredicate\n%@\n\n \
                          NSValidationErrorObject\n%@\n\n \
                          NSLocalizedDescription\n%@",
                          [userInfo valueForKey:@"NSValidationErrorKey"],
                          [userInfo valueForKey:@"NSValidationErrorPredicate"],
                          [userInfo valueForKey:@"NSValidationErrorObject"],
                          [userInfo valueForKey:@"NSLocalizedDescription"]);
                }
            }
            // Handle mine--or 3rd party-generated--errors
            else {
                NSLog(@"Custom Error: %@", [error localizedDescription]);
            }
        }
        [[SRGlobalState singleton].managedObjectContext.parentContext save:&error];
        /*else {
         NSLog(@"Changes saved");
         }*/
    }

}

@end
