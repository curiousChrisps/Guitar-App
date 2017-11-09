//
//  FretBoardView.h
//  Practical14-7
//
//  Created by Christoph Schick on 11/03/2016.
//  Copyright © 2016 UWE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FretBoardView;

@protocol FretBoardViewDelegate <NSObject>
-(void)fretBoardView:(FretBoardView*)view fret:(int)fret string:(int)string state:(BOOL)fingerIsDown;
@end

@class GuitarStringsView;

// guitar fret interface
@interface FretBoardView : UIControl

// number of strings
@property (nonatomic, weak) GuitarStringsView* strings;

// number of frets
@property (nonatomic) int fretCount;

@property (weak, nonatomic) id <FretBoardViewDelegate> delegate;


@end
