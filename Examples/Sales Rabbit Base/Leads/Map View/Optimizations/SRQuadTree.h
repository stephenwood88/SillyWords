//
//  SRQuadTree.h
//  DishOne Sales
//
//  Created by Raul Lopez Villalpando on 6/23/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef struct SRQuadTreeNodeData {
    double x;
    double y;
    __unsafe_unretained id data;
} SRQuadTreeNodeData;
SRQuadTreeNodeData SRQuadTreeNodeDataMake(double x, double y, __unsafe_unretained id data);

typedef struct SRQuadTreeBoundingBox {
    double x0; double y0;
    double xf; double yf;
} SRQuadTreeBoundingBox;
SRQuadTreeBoundingBox SRQuadTreeBoundingBoxMake(double x0, double y0, double xf, double yf);

typedef struct SRQuadTreeNode {
    struct SRQuadTreeNode* northWest;
    struct SRQuadTreeNode* northEast;
    struct SRQuadTreeNode* southWest;
    struct SRQuadTreeNode* southEast;
    struct SRQuadTreeBoundingBox boundingBox;
    int bucketCapacity;
    struct SRQuadTreeNodeData *points;
    int count;
} SRQuadTreeNode;
SRQuadTreeNode* SRQuadTreeNodeMake(SRQuadTreeBoundingBox boundary, int bucketCapacity);

typedef void(^SRDataReturnBlock)(SRQuadTreeNodeData data);

@interface SRQuadTree : NSObject

- (BOOL)containsDataWithBox:(SRQuadTreeBoundingBox) box andData:(SRQuadTreeNodeData) data;
- (BOOL)boundingBoxIntersectsBoundingBox:(SRQuadTreeBoundingBox)b1 andBoundingBox:(SRQuadTreeBoundingBox)b2;

- (void)quadTreeGatherDataInRange:(SRQuadTreeBoundingBox)range andNode:(SRQuadTreeNode*)node withReturnBlock:(SRDataReturnBlock) block;

- (BOOL)quadTreeNodeInsertDataFromNode:(SRQuadTreeNode*)node andData:(SRQuadTreeNodeData)data;
- (BOOL)quadTreeDeleteDataFromNode:(SRQuadTreeNode *)node andData:(SRQuadTreeNodeData)data;

- (SRQuadTreeNode*)quadTreeBuildWithData:(SRQuadTreeNodeData *)data andCount:(int) count andBoundingBox:(SRQuadTreeBoundingBox)boundingBox andCapacity:(int)capacity;


@end




