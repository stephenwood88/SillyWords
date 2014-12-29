//
//  SRCoordinateQuadTreeController.m
//  Sales Rabbit
//
//  Created by Raul Lopez Villalpando on 6/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRQuadTreeController.h"
#import "SRClusterAnnotation.h"
#import "SRSalesConstants.h"
#import "Prequal+Rabbit.h"
#import "UserLocation+Rabbit.h"
#import "Lead+Rabbit.h"
#import "SlimLead+Rabbit.h"

#define MERCATOR_RADIUS 85445659.44705395


SRQuadTreeNodeData dataFromAnnotation(__unsafe_unretained id annotation, double x, double y)
{
    return SRQuadTreeNodeDataMake(x, y, annotation);
}


SRQuadTreeBoundingBox SRBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));
    
    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;
    
    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;
    
    return SRQuadTreeBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}


MKMapRect SRMapRectForBoundingBox(SRQuadTreeBoundingBox boundingBox)
{
    MKMapPoint topLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.x0, boundingBox.y0));
    MKMapPoint botRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xf, boundingBox.yf));
    
    return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y));
}

NSInteger SRZoomScaleToZoomLevel(MKZoomScale scale)
{
    //At Zoom level 0 The entire world it's made out of 256 pixels dimension
    //At Zoom level 1 The entire world it's made out of 512 pixels dimension
    //.. and so on
    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
    NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));
    
    return zoomLevel;
}

float SRCellSizeForZoomScale(MKZoomScale zoomScale)
{
    NSInteger zoomLevel = SRZoomScaleToZoomLevel(zoomScale);
    
    switch (zoomLevel) {
        case 13:
        case 14:
        case 15:
            return 64;
        case 16:
        case 17:
        case 18:
            return 32;
        case 19:
            return 16;
            
        default:
            return 88;
    }
}



@implementation SRQuadTreeController

- (id)init{
    self = [super init];
    if (self) {
        self.quadTree = [[SRQuadTree alloc] init];
        self.operationQueue = [NSOperationQueue new];
    }
    return self;
}

- (id)initWithOperationQueue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self) {
        self.quadTree = [[SRQuadTree alloc] init];
        self.operationQueue = queue;
    }
    return self;
}

#pragma mark - QuadTree operations

- (void) buildTree: (NSArray *) data
{
        NSInteger count = data.count - 1;
        
        SRQuadTreeNodeData *dataArray = malloc(sizeof(SRQuadTreeNodeData) * count);
        for (NSInteger i = 0; i < count; i++) {
            id<MKAnnotation> annotation = [data objectAtIndex:i];
            //MKAnnotationView *tempAnnotationView = (MKAnnotationView *)data[i];
            dataArray[i] = dataFromAnnotation(annotation, annotation.coordinate.latitude , annotation.coordinate.longitude);
        }
        
        //The entire World Map
        SRQuadTreeBoundingBox world = SRQuadTreeBoundingBoxMake(19, -166, 72, -53);
        _root = [self.quadTree quadTreeBuildWithData:dataArray andCount:(int)count andBoundingBox:world andCapacity:4];
}

- (NSArray *)clusteredAnnotationsWithinMapRect: (MKMapRect)rect withZoomScale:(double)zoomScale
{
    double SRCellSize = SRCellSizeForZoomScale(zoomScale);
    double scaleFactor = zoomScale / SRCellSize;
    
    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);
    
    NSMutableArray *annotationsToDisplay = [[NSMutableArray alloc] init];
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            
            //To average the location of the resulting clustered annotation
            __block double totalX = 0;
            __block double totalY = 0;
            
            //To determine the inventory of the Clustered annotation
            __block int prequalCount = 0;
            __block int leadCount = 0;
            __block int repLeadCount = 0;
            __block int userLocationCount = 0;
            
            __block id<MKAnnotation> annotation = nil;
            
            __block NSMutableArray *annotationsToCluster = [[NSMutableArray alloc] init];
            
            [self.quadTree quadTreeGatherDataInRange:SRBoundingBoxForMapRect(mapRect) andNode:self.root withReturnBlock:^(SRQuadTreeNodeData data) {
                totalX += data.x;
                totalY += data.y;
                
                annotation = (id<MKAnnotation>)data.data;
                [annotationsToCluster addObject:annotation];
                
                //Inventory of what's on the clustered annotation
                if ([annotation isKindOfClass:[Prequal class]]) {
                    prequalCount++;
                }
                else if ([annotation isKindOfClass:[Lead class]])
                {
                    leadCount++;
                }
                else if ([annotation isKindOfClass:[UserLocation class]])
                {
                    userLocationCount++;
                }
                else if([annotation isKindOfClass:[SlimLead class]])
                {
                    repLeadCount++;
                }
                
            }];
            
            if (annotationsToCluster.count == 1) {
                
                [annotationsToDisplay addObject:annotation];
            }
            else if ([self currentZoomLevel] > kZoomLevelForMapCluster && annotationsToCluster.count > 0)
            {
                for (int i=0; i<annotationsToCluster.count; i++) {
                    [annotationsToDisplay addObject:annotationsToCluster[i]];
                }
            }
            else if (annotationsToCluster.count > 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / annotationsToCluster.count, totalY / annotationsToCluster.count);
                SRClusterAnnotation *annotation = [[SRClusterAnnotation alloc] initWithCoordinate:coordinate count:annotationsToCluster.count];
                annotation.prequalCount = prequalCount;
                annotation.leadsCount = leadCount;
                annotation.repLeadsCount = repLeadCount;
                annotation.userLocationsCount = userLocationCount;
                [annotationsToDisplay addObject:annotation];
            }
        }
    }
    
    return [NSArray arrayWithArray:annotationsToDisplay];
}

- (void)insertData:(SRQuadTreeNodeData)data
{
    [self.operationQueue addOperationWithBlock:^{
        [self.quadTree quadTreeNodeInsertDataFromNode:self.root andData:data];
    }];
}

- (void)deleteData:(SRQuadTreeNodeData)data
{
    [self.operationQueue addOperationWithBlock:^{
        [self.quadTree quadTreeDeleteDataFromNode:self.root andData:data];
    }];
}

- (NSInteger)currentZoomLevel
{
    CLLocationDegrees longitudeDelta = self.mapView.region.span.longitudeDelta;
    CGFloat mapWidthInPixels = self.mapView.bounds.size.width;
    double zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapWidthInPixels);
    double zoomer = log2(MKMapSizeWorld.width / 256.0) - log2( zoomScale );
    if ( zoomer < 0 ) zoomer = 0;
    //  zoomer = round(zoomer);
    return zoomer;
}



@end