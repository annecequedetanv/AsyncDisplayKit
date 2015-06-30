/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "ASOverlayLayoutNode.h"

#import "ASAssert.h"
#import "ASBaseDefines.h"

@implementation ASOverlayLayoutNode
{
  id<ASLayoutable> _overlay;
  id<ASLayoutable> _child;
}

+ (instancetype)newWithChild:(id<ASLayoutable>)child overlay:(id<ASLayoutable>)overlay
{
  ASOverlayLayoutNode *n = [super new];
  if (n) {
    ASDisplayNodeAssertNotNil(child, @"Child that will be overlayed on shouldn't be nil");
    n->_overlay = overlay;
    n->_child = child;
  }
  return n;
}

+ (instancetype)new
{
  ASDISPLAYNODE_NOT_DESIGNATED_INITIALIZER();
}

/**
 First layout the contents, then fit the overlay on top of it.
 */
- (ASLayout *)calculateLayoutThatFits:(ASSizeRange)constrainedSize
{
  ASLayout *contentsLayout = [_child calculateLayoutThatFits:constrainedSize];
  contentsLayout.position = CGPointZero;
  NSMutableArray *layoutChildren = [NSMutableArray arrayWithObject:contentsLayout];
  if (_overlay) {
    ASLayout *overlayLayout = [_overlay calculateLayoutThatFits:{contentsLayout.size, contentsLayout.size}];
    overlayLayout.position = CGPointZero;
    [layoutChildren addObject:overlayLayout];
  }
  
  return [ASLayout newWithLayoutableObject:self size:contentsLayout.size children:layoutChildren];
}

@end
