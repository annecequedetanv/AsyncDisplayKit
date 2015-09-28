//
//  ASViewController.m
//  AsyncDisplayKit
//
//  Created by Huy Nguyen on 16/09/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "ASViewController.h"
#import "ASAssert.h"
#import "ASDimension.h"

// FIXME: Temporary nonsense import until method names are finalized and exposed
#import "ASDisplayNode+Subclasses.h"

@implementation ASViewController
{
  BOOL _ensureDisplayed;
}

- (instancetype)initWithNode:(ASDisplayNode *)node
{
  if (!(self = [super init])) {
    return nil;
  }
  
  ASDisplayNodeAssertNotNil(node, @"Node must not be nil");
  ASDisplayNodeAssertTrue(!node.layerBacked);
  _node = node;
  
  return self;
}

- (void)loadView
{
  ASDisplayNodeAssertTrue(!_node.layerBacked);
  self.view = _node.view;
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  CGSize viewSize = self.view.bounds.size;
  ASSizeRange constrainedSize = ASSizeRangeMake(viewSize, viewSize);
  [_node measureWithSizeRange:constrainedSize];
}

- (void)viewDidLayoutSubviews
{
  if (_ensureDisplayed && self.neverShowPlaceholders) {
    _ensureDisplayed = NO;
    [self.node recursivelyEnsureDisplay];
  }
  [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  _ensureDisplayed = YES;
  [_node recursivelyFetchData];
}

@end
