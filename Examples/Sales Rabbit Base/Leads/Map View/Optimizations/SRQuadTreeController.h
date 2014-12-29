//
//  SRCoordinateQuadTreeController.h
//  Sales Rabbit
//
//  Created by Raul Lopez Villalpando on 6/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SRQuadTree.h"

SRQuadTreeNodeData dataFromAnnotation(__unsafe_unretained id annotation, double x, double y);


@interface SRQuadTreeController : NSObject
/**
 *  SRQuadTreeNode containing the root of the SRQuadTree
 */
@property(assign, nonatomic) SRQuadTreeNode *root;
/**
 *  MKMapView in which the clustering and rendering will happen
 */
@property(strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) SRQuadTree *quadTree;
/**
 *  NSOperationQueue to handle all the SRQuadTree operations
 */
@property (strong, nonatomic) NSOperationQueue *operationQueue;

//QuadTree Operations

/**
 *  Creates and updates root property to contain the root of the QuadTree.
 *
 *  @param data Array containing data to build Tree. This array must contain data that implements the protocol MKAnnotation
 */
- (void)buildTree: (NSArray *) data;

/**
 *  Clustered annotations that are contained on the given zoomScale and MKMapRect
 *
 *  @param rect      MKMapRect in which that needs to be contained
 *  @param zoomScale Zoom Scale value to determine how close the clustering needs to be handled
 *
 *  @return NSArray of id<MKAnnotation>
 */
- (NSArray *)clusteredAnnotationsWithinMapRect: (MKMapRect)rect withZoomScale:(double)zoomScale;

/**
 *  Insert the provided data into the QuadTree traversing from the root property
 *
 *  @param data Data to be inserted
 */
- (void)insertData:(SRQuadTreeNodeData)data;

/**
 *  Delete the provided data from the QuadTree traversing from the root property
 *
 *  @param data Data to be deleted
 */
- (void)deleteData:(SRQuadTreeNodeData)data;

//Initializers

/**
 *  Initiazlizer where an NSOperationQueue can be provided
 *
 *  @param queue Queue in which the QuadTree operations would be handled to improve performance
 *
 *  @return SRQuadTreeController with a specified NSOperationQueue
 */
- (id)initWithOperationQueue:(NSOperationQueue *)queue;

@end