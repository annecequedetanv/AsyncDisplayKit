/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <AsyncDisplayKit/ASLayoutNode.h>

typedef NS_ENUM(NSUInteger, ASStackLayoutDirection) {
  ASStackLayoutDirectionVertical,
  ASStackLayoutDirectionHorizontal,
};

/** If no children are flexible, how should this node justify its children in the available space? */
typedef NS_ENUM(NSUInteger, ASStackLayoutJustifyContent) {
  /**
   On overflow, children overflow out of this node's bounds on the right/bottom side.
   On underflow, children are left/top-aligned within this node's bounds.
   */
  ASStackLayoutJustifyContentStart,
  /**
   On overflow, children are centered and overflow on both sides.
   On underflow, children are centered within this node's bounds in the stacking direction.
   */
  ASStackLayoutJustifyContentCenter,
  /**
   On overflow, children overflow out of this node's bounds on the left/top side.
   On underflow, children are right/bottom-aligned within this node's bounds.
   */
  ASStackLayoutJustifyContentEnd,
};

typedef NS_ENUM(NSUInteger, ASStackLayoutAlignItems) {
  /** Align children to start of cross axis */
  ASStackLayoutAlignItemsStart,
  /** Align children with end of cross axis */
  ASStackLayoutAlignItemsEnd,
  /** Center children on cross axis */
  ASStackLayoutAlignItemsCenter,
  /** Expand children to fill cross axis */
  ASStackLayoutAlignItemsStretch,
};

/**
 Each child may override their parent stack's cross axis alignment.
 @see ASStackLayoutNodeAlignItems
 */
typedef NS_ENUM(NSUInteger, ASStackLayoutAlignSelf) {
  /** Inherit alignment value from containing stack. */
  ASStackLayoutAlignSelfAuto,
  ASStackLayoutAlignSelfStart,
  ASStackLayoutAlignSelfEnd,
  ASStackLayoutAlignSelfCenter,
  ASStackLayoutAlignSelfStretch,
};

typedef struct {
  /** Specifies the direction children are stacked in. */
  ASStackLayoutDirection direction;
  /** The amount of space between each child. */
  CGFloat spacing;
  /** How children are aligned if there are no flexible children. */
  ASStackLayoutJustifyContent justifyContent;
  /** Orientation of children along cross axis */
  ASStackLayoutAlignItems alignItems;
} ASStackLayoutNodeStyle;

@class ASMutableStackLayoutNodeChild;

@interface ASStackLayoutNodeChild : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, readwrite) id<ASLayoutable> node;
/** Additional space to place before the node in the stacking direction. */
@property (nonatomic, readonly) CGFloat spacingBefore;
/** Additional space to place after the node in the stacking direction. */
@property (nonatomic, readonly) CGFloat spacingAfter;
/** If the sum of childrens' stack dimensions is less than the minimum size, should this node grow? */
@property (nonatomic, readonly) BOOL flexGrow;
/** If the sum of childrens' stack dimensions is greater than the maximum size, should this node shrink? */
@property (nonatomic, readonly) BOOL flexShrink;
/** Specifies the initial size in the stack dimension for the child. Default to ASRelativeDimensionUnconstrained. */
@property (nonatomic, readonly) ASRelativeDimension flexBasis;
/** Orientation of the child along cross axis, overriding alignItems */
@property (nonatomic, readonly) ASStackLayoutAlignSelf alignSelf;

+(instancetype)newWithInitializer:(void(^)(ASMutableStackLayoutNodeChild *mutableChild))initializer;

@end


/** A mutable stack layout node child intended for configuration. */
@interface ASMutableStackLayoutNodeChild : ASStackLayoutNodeChild

/** A read-write version of ASStackLayoutNodeChild node property */
@property (nonatomic, readwrite) id<ASLayoutable> node;
/** A read-write version of ASStackLayoutNodeChild spacingBefore property */
@property (nonatomic, readwrite) CGFloat spacingBefore;
/** A read-write version of ASStackLayoutNodeChild spacingAfter property */
@property (nonatomic, readwrite) CGFloat spacingAfter;
/** A read-write version of ASStackLayoutNodeChild flexGrow property */
@property (nonatomic, readwrite) BOOL flexGrow;
/** A read-write version of ASStackLayoutNodeChild flexShrink property */
@property (nonatomic, readwrite) BOOL flexShrink;
/** A read-write version of ASStackLayoutNodeChild flexBasis property */
@property (nonatomic, readwrite) ASRelativeDimension flexBasis;
/** A read-write version of ASStackLayoutNodeChild alignSelf property */
@property (nonatomic, readwrite) ASStackLayoutAlignSelf alignSelf;

@end


/**
 A simple layout node that stacks a list of children vertically or horizontally.

 - All children are initially laid out with the an infinite available size in the stacking direction.
 - In the other direction, this node's constraint is passed.
 - The children's sizes are summed in the stacking direction.
   - If this sum is less than this node's minimum size in stacking direction, children with flexGrow are flexed.
   - If it is greater than this node's maximum size in the stacking direction, children with flexShrink are flexed.
   - If, even after flexing, the sum is still greater than this node's maximum size in the stacking direction,
     justifyContent determines how children are laid out.

 For example:
 - Suppose stacking direction is Vertical, min-width=100, max-width=300, min-height=200, max-height=500.
 - All children are laid out with min-width=100, max-width=300, min-height=0, max-height=INFINITY.
 - If the sum of the childrens' heights is less than 200, nodes with flexGrow are flexed larger.
 - If the sum of the childrens' heights is greater than 500, nodes with flexShrink are flexed smaller.
   Each node is shrunk by `((sum of heights) - 500)/(number of nodes)`.
 - If the sum of the childrens' heights is greater than 500 even after flexShrink-able nodes are flexed,
   justifyContent determines how children are laid out.
 */
@interface ASStackLayoutNode : ASLayoutNode

/**
 @param style Specifies how children are laid out.
 @param children Children to be positioned, each is of type ASStackLayoutNodeChild.
 */
+ (instancetype)newWithStyle:(ASStackLayoutNodeStyle)style children:(NSArray *)children;

@end
