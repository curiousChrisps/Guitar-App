//
//  FretBoardView.m
//  Practical14-7
//
//  Created by Christoph Schick on 11/03/2016.
//  Copyright © 2016 UWE. All rights reserved.
//
#import "FretBoardView.h"
#import "GuitarStringsView.h"

// privately keep a record of the touches
@interface FretBoardView ()
@property (nonatomic, strong) NSMutableArray* touches;
@end

@implementation FretBoardView

@synthesize fretCount = _fretCount;

//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\  D R A W I N G  /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

- (void)drawRect:(CGRect)rect
{
    // get the "context" which is the place to which we will draw
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // save the state (colours, pen width etc) so we can restore it when we're done
    CGContextSaveGState(currentContext);
    
    // set up fill and stroke colours
    CGContextSetRGBFillColor(currentContext, 1.0, 1.0, 0.7, 1.0);   // light brown
    CGContextSetRGBStrokeColor(currentContext, 0.0, 0.0, 0.0, 1.0); // black
    
    // fill whole view with fill colour
    CGContextFillRect(currentContext, rect);

    // draw frets
    CGContextSetRGBStrokeColor(currentContext, 0.72, 0.63, 0.1, 1.0); // gold ish

    self.fretCount = 3;
    
    const int divisions = self.fretCount + 1;
    const CGFloat divisionHeight = self.bounds.size.height / divisions;
    
    // start at the first fret
    CGFloat fretY = divisionHeight;
    
    for (int i = 0; i < self.fretCount; ++i, fretY += divisionHeight) // move to next fret position each time
    {
        // add a line to the path
        CGContextMoveToPoint(currentContext, 0, fretY);
        CGContextAddLineToPoint(currentContext, self.bounds.size.width, fretY);
    }
    
    // draw the path (the strings)
    CGContextStrokePath(currentContext);
    
    CGContextSetRGBStrokeColor(currentContext, 0.0, 0.0, 0.0, 1.0); // black

    if (self.strings)
    {
        const int divisions = self.strings.stringCount + 1;
        const CGFloat divisionWidth = self.bounds.size.width / divisions;
        
        // start at the first string
        CGFloat stringX = divisionWidth;
        
        for (int i = 0; i < self.strings.stringCount; ++i, stringX += divisionWidth) // move to next string position each time
        {
            // add a line to the path
            CGContextMoveToPoint(currentContext, stringX, 0);
            CGContextAddLineToPoint(currentContext, stringX, self.bounds.size.height);
        }
        
        // draw the path (the strings)
        CGContextStrokePath(currentContext);
    }
  
    // restore the context
    CGContextRestoreGState(currentContext);
}

//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\  T O U C H   B E G I N S /\/\/\/\/\/\/\/\/\/\/\/\/
//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    // calculate geometry, divided screen into sections
    const int fretDivisions = self.fretCount + 1;
    const CGFloat fretDivisionHeight = self.bounds.size.height / fretDivisions;
    const int stringDivisions = self.strings.stringCount + 1;
    const CGFloat stringDivisionWidth = self.bounds.size.width / stringDivisions;
    
    
    // iterate over the touches
    for (UITouch* touch in touches)
    {
        
        // find just the touches that have just begun (finger down)
        if (touch.phase == UITouchPhaseBegan)
        {
            // add the touch to the touches array
            [self.touches addObject:touch];
            
            // update touchState
            BOOL touchState = 1;
            
            
            //get position of touch
            const CGFloat hereX = [touch locationInView:self].x;
            const CGFloat hereY = [touch locationInView:self].y;
            
            CGFloat stringX = stringDivisionWidth;
            CGFloat fretY = fretDivisionHeight;
            
            for (int i = 0; i < self.strings.stringCount; ++i, stringX +=stringDivisionWidth)
            {
                if ((hereX > stringX - 0.5*stringDivisionWidth) && (hereX < stringX + 0.5*stringDivisionWidth))
                {
                    for (int e = 0; e <= self.fretCount; ++e, fretY += fretDivisionHeight)
                    {
                        if ((hereY < fretY) && (hereY > fretY - fretDivisionHeight))
                        {
                            printf("\n Touch START: \n");
                            [self.delegate fretBoardView:self
                                                    fret: e
                                                  string: i
                                                   state: touchState];
                        }
                    }
                }
            }
        }
    }
}


//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\  T O U C H   M O V E S  /\/\/\/\/\/\/\/\/\/\/\/
///\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // calculate geometry, divided screen into sections
    const int fretDivisions = self.fretCount + 1;
    const CGFloat fretDivisionHeight = self.bounds.size.height / fretDivisions;
    const int stringDivisions = self.strings.stringCount + 1;
    const CGFloat stringDivisionWidth = self.bounds.size.width / stringDivisions;
    
    // iterate over the touches
    for (UITouch* touch in touches)
    {
        
        //get position of touch
        const CGFloat hereX = [touch locationInView:self].x;
        const CGFloat hereY = [touch locationInView:self].y;
        const CGFloat prevX = [touch previousLocationInView:self].x;
        const CGFloat prevY = [touch previousLocationInView:self].y;
        
        // assign geometry of one 'zone'
        CGFloat stringX = stringDivisionWidth;
        CGFloat fretY = fretDivisionHeight;
        
        // check for touches that moved. Check where they moved: X or Y and switch previous fret touchState to 0
        if (touch.phase == UITouchPhaseMoved)
        {
            for (int i = 0; i < self.strings.stringCount; ++i, stringX +=stringDivisionWidth)
            {       // check for X-movement UP
                if ((prevX < stringX - 0.5*stringDivisionWidth) && (hereX >= stringX - 0.5*stringDivisionWidth))
                {
                    for (int e = 0; e <= self.fretCount; ++e, fretY += fretDivisionHeight)
                    {
                        if ((hereY < fretY) && (hereY > fretY - fretDivisionHeight))
                        {
                            printf("\n X-UP: \n");
                            [self.delegate fretBoardView:self       // These blocks update
                                                    fret: e         // the touchState
                                                  string: i-1       // in case a touch moves.
                                                   state: 0];
                            
                            [self.delegate fretBoardView:self
                                                    fret: e
                                                  string: i
                                                   state: 1];
                        }
                    }   // check for X-movement DOWN
                }else if ((prevX > stringX + 0.5*stringDivisionWidth) && (hereX <= stringX + 0.5*stringDivisionWidth))
                {
                    for (int e = 0; e <= self.fretCount; ++e, fretY += fretDivisionHeight)
                    {
                        if ((hereY < fretY) && (hereY > fretY - fretDivisionHeight))
                        {
                            printf("\n X-DOWN: \n");
                            [self.delegate fretBoardView:self
                                                    fret: e
                                                  string: i+1
                                                   state: 0];
                            
                            [self.delegate fretBoardView:self
                                                    fret: e
                                                  string: i
                                                   state: 1];
                        }
                    }
                }else if ((hereX > stringX - 0.5*stringDivisionWidth) && (hereX < stringX + 0.5*stringDivisionWidth) &&
                          (prevX > stringX - 0.5*stringDivisionWidth) && (prevX < stringX + 0.5*stringDivisionWidth))
                {
                    for (int e = 0; e <= self.fretCount; ++e, fretY += fretDivisionHeight)
                    {   // check for Y-movement UP
                        if ((prevY < fretY) && (hereY >= fretY))
                        {
                            printf("\n Y-UP: \n");
                            [self.delegate fretBoardView:self
                                                    fret: e
                                                  string: i
                                                   state: 0];
                            
                            [self.delegate fretBoardView:self
                                                    fret: e+1
                                                  string: i
                                                   state: 1];
                            // check for Y-movement DOWN
                        }else if ((prevY > fretY) && (hereY <= fretY))
                        {
                            printf("\n Y-DOWN: \n");
                            [self.delegate fretBoardView:self
                                                    fret: e+1
                                                  string: i
                                                   state: 0];
                            
                            [self.delegate fretBoardView:self
                                                    fret: e
                                                  string: i
                                                   state: 1];
                        }
                    }
                }
            }
        }
    }
}


//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\  T O U C H   E N D S /\/\/\/\/\/\/\/\/\/\/
//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // calculate geometry, divided screen into sections
    const int fretDivisions = self.fretCount + 1;
    const CGFloat fretDivisionHeight = self.bounds.size.height / fretDivisions;
    const int stringDivisions = self.strings.stringCount + 1;
    const CGFloat stringDivisionWidth = self.bounds.size.width / stringDivisions;
    
    // iterate over the touches
    for (UITouch* touch in touches)
    {
        // just get touches that have ended or have been cancelled
        if ((touch.phase == UITouchPhaseEnded) ||
            (touch.phase == UITouchPhaseCancelled))
        {
            // get the index of this touch in our touches array
            const int index = [self.touches indexOfObject:touch];
            
            // update touchState
            BOOL touchState = 0;
            
            //get position of touch
            const CGFloat hereX = [touch locationInView:self].x;
            const CGFloat hereY = [touch locationInView:self].y;
            
            // assign geometry of one 'zone'
            CGFloat stringX = stringDivisionWidth;
            CGFloat fretY = fretDivisionHeight;
            
            // Check for touches that have just enden or have been cancelled and switch touchState to 0
            if ((touch.phase == UITouchPhaseEnded) ||
                (touch.phase == UITouchPhaseCancelled))
            {
                for (int i = 0; i < self.strings.stringCount; ++i, stringX +=stringDivisionWidth)
                {
                    if ((hereX > stringX - 0.5*stringDivisionWidth) && (hereX < stringX + 0.5*stringDivisionWidth))
                    {
                        for (int e = 0; e <= self.fretCount; ++e, fretY += fretDivisionHeight)
                        {
                            if ((hereY < fretY) && (hereY > fretY - fretDivisionHeight))
                            {
                                printf("\n Touch END: \n");
                                [self.delegate fretBoardView:self
                                                        fret: e
                                                      string: i
                                                       state: touchState];
                            }
                        }
                    }
                }
            }
            // remove the touch from the touches array
            [self.touches removeObjectAtIndex:index];
        }
    }
}

//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//\/\/\/\/\/\/\/\/\/\/\/\/\/\  T O U C H   I S   C A N C E L L E D /\/\/\/\/\/\/\/\/
//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // do same as touchesEnded: in this case
    [self touchesEnded:touches withEvent:event];
}
@end
