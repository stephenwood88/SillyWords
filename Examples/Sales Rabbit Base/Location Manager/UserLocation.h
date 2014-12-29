//
//  UserLocation.h
//  
//
//  Created by Bryan Bryce on 1/20/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UserLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userLocationId;
@property (nonatomic, retain) NSNumber * alpha;

@end
