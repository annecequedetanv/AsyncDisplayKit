/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "ASLayoutSpec.h"

#import "ASAssert.h"
#import "ASBaseDefines.h"

#import "ASInternalHelpers.h"
#import "ASLayout.h"
#import "ASLayoutOptions.h"
#import "ASLayoutOptionsPrivate.h"

#import <objc/runtime.h>

static NSString * const kDefaultChildKey = @"kDefaultChildKey";
static NSString * const kDefaultChildrenKey = @"kDefaultChildrenKey";

@interface ASLayoutSpec()
@property (nonatomic, strong) NSMutableDictionary *layoutChildren;
@end

@implementation ASLayoutSpec

@dynamic spacingAfter, spacingBefore, flexGrow, flexShrink, flexBasis, alignSelf, ascender, descender, sizeRange, layoutPosition, layoutOptions;
@synthesize layoutChildren = _layoutChildren;
@synthesize isFinalLayoutable = _isFinalLayoutable;

- (instancetype)init
{
  if (!(self = [super init])) {
    return nil;
  }
  _layoutChildren = [NSMutableDictionary dictionary];
  _isMutable = YES;
  return self;
}

#pragma mark - Layout

- (ASLayout *)measureWithSizeRange:(ASSizeRange)constrainedSize
{
  return [ASLayout layoutWithLayoutableObject:self size:constrainedSize.min];
}

- (id<ASLayoutable>)finalLayoutable
{
  return self;
}

- (void)setChild:(id<ASLayoutable>)child;
{
  [self setChild:child forIdentifier:kDefaultChildKey];
}

- (id<ASLayoutable>)layoutableToAddFromLayoutable:(id<ASLayoutable>)child
{
  if (self.isFinalLayoutable == NO) {
    
    // If you are getting recursion crashes here after implementing finalLayoutable, make sure
    // that you are setting isFinalLayoutable flag to YES. This must be one BEFORE adding a child
    // to the new ASLayoutable.
    //
    // For example:
    //- (id<ASLayoutable>)finalLayoutable
    //{
    //  ASInsetLayoutSpec *insetSpec = [[ASInsetLayoutSpec alloc] init];
    //  insetSpec.insets = UIEdgeInsetsMake(10,10,10,10);
    //  insetSpec.isFinalLayoutable = YES;
    //  [insetSpec setChild:self];
    //  return insetSpec;
    //}

    id<ASLayoutable> finalLayoutable = [child finalLayoutable];
    if (finalLayoutable != child) {
      ASLayoutOptions *layoutOptions = [child layoutOptions];
      [layoutOptions copyIntoOptions:finalLayoutable.layoutOptions];
      return finalLayoutable;
    }
  }
  return child;
}

- (void)setChild:(id<ASLayoutable>)child forIdentifier:(NSString *)identifier
{
  ASDisplayNodeAssert(self.isMutable, @"Cannot set properties when layout spec is not mutable");
  self.layoutChildren[identifier] = [self layoutableToAddFromLayoutable:child];;
}

- (void)setChildren:(NSArray *)children
{
  ASDisplayNodeAssert(self.isMutable, @"Cannot set properties when layout spec is not mutable");
  
  NSMutableArray *finalChildren = [NSMutableArray arrayWithCapacity:children.count];
  for (id<ASLayoutable> child in children) {
    [finalChildren addObject:[self layoutableToAddFromLayoutable:child]];
  }
  
  self.layoutChildren[kDefaultChildrenKey] = [NSArray arrayWithArray:finalChildren];
}

- (id<ASLayoutable>)childForIdentifier:(NSString *)identifier
{
  return self.layoutChildren[identifier];
}

- (id<ASLayoutable>)child
{
  return self.layoutChildren[kDefaultChildKey];
}

- (NSArray *)children
{
  return self.layoutChildren[kDefaultChildrenKey];
}

                     
@end
