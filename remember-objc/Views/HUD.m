//
//  HUD.m
//  remember-objc
//
//  Created by Joseph Cheung on 1/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HUD.h"
#import "UIColor+Extensions.h"

@interface HUD ()
@property (weak, nonatomic) UIView *parentView;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) CGFloat tileWidth;
@property (nonatomic) CGFloat tileHeight;
@property (nonatomic) CGFloat tileSpacing;
@end

const int lowerBound = 1;
const int upperBound = 5;

@implementation HUD

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
        self.tileWidth = roundf(self.bounds.size.width / 16);
        self.tileHeight = roundf(self.tileWidth / 5);
        self.tileSpacing = roundf(self.tileHeight / 2);
    }
    return self;
}

+ (HUD *)hudInView:(UIView *)view
{
    HUD *hudView = [[HUD alloc] initWithFrame:view.bounds];
    hudView.opaque = NO;
    hudView.parentView = view;
    [view addSubview:hudView];
    view.userInteractionEnabled = NO;
    [hudView showAnimated];

    return hudView;
}

- (void)drawRect:(CGRect)rect {
    const CGFloat radius = roundf(self.bounds.size.width / 4);
    
    CGRect circleRect = CGRectMake(radius, roundf(self.bounds.size.height / 2) - radius, radius * 2, radius * 2);
    
    UIBezierPath *circularPath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    
    [[UIColor appGreyColor] setFill];
    [circularPath fill];
    
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName: font}];
    
    CGPoint textPoint = CGPointMake(self.center.x - roundf(textSize.width / 2.0f), self.center.y - roundf(textSize.height / 2.0f) + radius / 4.0f);
    
    [self.text drawAtPoint:textPoint withAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    [self randomTiles];
}

- (int)randomTileNumber
{
    return lowerBound + arc4random_uniform(upperBound - lowerBound + 1);
}

- (void)randomTiles
{
    for (int tileColumn = 0; tileColumn < 3; tileColumn ++) {
        int numberOfTiles = [self randomTileNumber];
        for (int tileIndex = 0; tileIndex < numberOfTiles; tileIndex ++) {
            [self drawTileForTileIndex:tileIndex AtTileColumn:tileColumn];
        }
    }
}

- (void)drawTileForTileIndex:(int)tileIndex AtTileColumn:(int)tileColumn
{
    CGFloat x;
    switch (tileColumn) {
        case 0:
            x = self.center.x - roundf(self.tileWidth / 2) - self.tileWidth - self.tileSpacing;
            break;
        case 1:
            x = self.center.x - roundf(self.tileWidth / 2);
            break;
        case 2:
            x = self.center.x + roundf(self.tileWidth / 2) + self.tileSpacing;
        default:
            break;
    }
    
    CGFloat y = self.center.y + self.tileHeight - tileIndex * (self.tileHeight + self.tileSpacing);
    CGRect tileRect = CGRectMake(x, y, self.tileWidth, self.tileHeight);
    UIBezierPath *tilePath = [UIBezierPath bezierPathWithRect:tileRect];
    
    [[UIColor whiteColor] setFill];
    [tilePath fill];
}

- (void)showAnimated
{
    self.alpha = 0.0f;
    self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    self.parentView.userInteractionEnabled = YES;
    [self.timer invalidate];
    self.timer = nil;
}

@end
