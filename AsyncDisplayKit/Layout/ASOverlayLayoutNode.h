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

/**
 This node lays out a single node and then overlays a node on top of it streched to its size
 */
@interface ASOverlayLayoutNode : ASLayoutNode

+ (instancetype)newWithNode:(ASLayoutNode *)node overlay:(ASLayoutNode *)overlay;

@end
