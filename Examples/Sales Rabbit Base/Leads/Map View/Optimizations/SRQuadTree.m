//
//  SRQuadTree.m
//  DishOne Sales
//
//  Created by Raul Lopez Villalpando on 6/23/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRQuadTree.h"

#pragma mark - Constructors for C Structs

SRQuadTreeNodeData SRQuadTreeNodeDataMake(double x, double y, __unsafe_unretained id data)
{
    SRQuadTreeNodeData d; d.x = x; d.y = y; d.data = data;
    return d;
}

SRQuadTreeBoundingBox SRQuadTreeBoundingBoxMake(double x0, double y0, double xf, double yf)
{
    SRQuadTreeBoundingBox bb; bb.x0 = x0; bb.y0 = y0; bb.xf = xf; bb.yf = yf;
    return bb;
}

SRQuadTreeNode* SRQuadTreeNodeMake(SRQuadTreeBoundingBox boundary, int bucketCapacity)
{
    SRQuadTreeNode* node = malloc(sizeof(SRQuadTreeNode));
    node->northWest = NULL;
    node->northEast = NULL;
    node->southWest = NULL;
    node->southEast = NULL;
    
    node->boundingBox = boundary;
    node->bucketCapacity = bucketCapacity;
    node->count = 0;
    node->points = malloc(sizeof(SRQuadTreeNodeData) * bucketCapacity);
    
    return node;
}

@implementation SRQuadTree

#pragma mark - Bounding Box Functions

- (BOOL)containsDataWithBox:(SRQuadTreeBoundingBox)box andData:(SRQuadTreeNodeData)data
{
    BOOL containsX = box.x0 <= data.x && data.x <= box.xf;
    BOOL containsY = box.y0 <= data.y && data.y <= box.yf;
    
    return containsX && containsY;
}

- (BOOL)boundingBoxIntersectsBoundingBox:(SRQuadTreeBoundingBox)b1 andBoundingBox:(SRQuadTreeBoundingBox)b2
{
    return (b1.x0 <= b2.xf && b1.xf >= b2.x0 && b1.y0 <= b2.yf && b1.yf >= b2.y0);
}


#pragma mark - Quad Tree Functions


- (void)quadTreeSubdivideNode:(SRQuadTreeNode*) node
{
    SRQuadTreeBoundingBox box = node->boundingBox;
    
    double xMid = (box.xf + box.x0) / 2.0;
    double yMid = (box.yf + box.y0) / 2.0;
    
    SRQuadTreeBoundingBox northWest = SRQuadTreeBoundingBoxMake(box.x0, box.y0, xMid, yMid);
    node->northWest = SRQuadTreeNodeMake(northWest, node->bucketCapacity);
    
    SRQuadTreeBoundingBox northEast = SRQuadTreeBoundingBoxMake(xMid, box.y0, box.xf, yMid);
    node->northEast = SRQuadTreeNodeMake(northEast, node->bucketCapacity);
    
    SRQuadTreeBoundingBox southWest = SRQuadTreeBoundingBoxMake(box.x0, yMid, xMid, box.yf);
    node->southWest = SRQuadTreeNodeMake(southWest, node->bucketCapacity);
    
    SRQuadTreeBoundingBox southEast = SRQuadTreeBoundingBoxMake(xMid, yMid, box.xf, box.yf);
    node->southEast = SRQuadTreeNodeMake(southEast, node->bucketCapacity);
}

- (void)quadTreeGatherDataInRange:(SRQuadTreeBoundingBox)range andNode:(SRQuadTreeNode*)node withReturnBlock:(SRDataReturnBlock)block
{
    // If range is not contained in the node's boundingBox then bail
    if (![self boundingBoxIntersectsBoundingBox:node->boundingBox andBoundingBox:range]) {
        return;
    }
    
    for (int i = 0; i < node->count; i++) {
        // Gather points contained in range
        if ([self containsDataWithBox:range andData:node->points[i]]) {
            block(node->points[i]);
        }
    }
    
    // Bail if node is leaf
    if (node->northWest == NULL) {
        return;
    }
    
    // Otherwise traverse down the tree
    [self quadTreeGatherDataInRange:range andNode:node->northWest withReturnBlock:block];
    [self quadTreeGatherDataInRange:range andNode:node->northEast withReturnBlock:block];
    [self quadTreeGatherDataInRange:range andNode:node->southWest withReturnBlock:block];
    [self quadTreeGatherDataInRange:range andNode:node->southEast withReturnBlock:block];
}

- (BOOL)quadTreeNodeInsertDataFromNode:(SRQuadTreeNode*)node andData:(SRQuadTreeNodeData)data
{
    // Bail if our coordinate is not in the boundingBox
    if (![self containsDataWithBox:node->boundingBox andData:data]) {
        return false;
    }
    
    // Add the coordinate to the points array
    if (node->count < node->bucketCapacity) {
        node->points[node->count++] = data;
        return true;
    }
    
    // Check to see if the current node is a leaf, if it is, split
    if (node->northWest == NULL) {
        [self quadTreeSubdivideNode:node];
    }
    
    // Traverse the tree
    if ([self quadTreeNodeInsertDataFromNode:node->northWest andData:data]) return true;
    if ([self quadTreeNodeInsertDataFromNode:node->northEast andData:data]) return true;
    if ([self quadTreeNodeInsertDataFromNode:node->southWest andData:data]) return true;
    if ([self quadTreeNodeInsertDataFromNode:node->southEast andData:data]) return true;

    return false;

}

- (BOOL)quadTreeDeleteDataFromNode:(SRQuadTreeNode *)node andData:(SRQuadTreeNodeData)data
{
    // Bail if our coordinate is not in the boundingBox
    if (![self containsDataWithBox:node->boundingBox andData:data]) {
        return false;
    }
    
    // Delete Data from node
    if (node->count > 0) {
        //Look for the Data within the points
        for (int i = 0; i < node->bucketCapacity; i++) {
            SRQuadTreeNodeData tempData = node->points[i];
            if(data.data == tempData.data){
                //Shift the rest of the data down
                for (int j = i; j< node->bucketCapacity - 1; j++) {
                    node->points[j] = node->points[j+1];
                }
                node->count--;
                return true;
            }
        }
    }
    
    // Check to see if the current node is a leaf, if it is, exit
    if (node->northWest == NULL) {
        return false;
    }
    
    // Traverse the tree
    if ([self quadTreeDeleteDataFromNode:node->northWest andData:data]) return true;
    if ([self quadTreeDeleteDataFromNode:node->northEast andData:data]) return true;
    if ([self quadTreeDeleteDataFromNode:node->southWest andData:data]) return true;
    if ([self quadTreeDeleteDataFromNode:node->southEast andData:data]) return true;
    
    return false;
}

- (SRQuadTreeNode*)quadTreeBuildWithData:(SRQuadTreeNodeData *)data andCount:(int) count andBoundingBox:(SRQuadTreeBoundingBox)boundingBox andCapacity:(int)capacity
{
    SRQuadTreeNode* root = SRQuadTreeNodeMake(boundingBox, capacity);
    for (int i = 0; i < count; i++) {
        [self quadTreeNodeInsertDataFromNode:root andData:data[i]];
    }
    
    return root;
}

@end