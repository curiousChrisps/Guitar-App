#import "GuitarStringsView.h"

// privately keep a record of the touches and their timestamps
// timestamps correspond to the touch at the same index in the touches array
@interface GuitarStringsView ()
@property (nonatomic, strong) NSMutableArray* touches;
@property (nonatomic, strong) NSMutableArray* timestamps;
@end

@implementation GuitarStringsView

@synthesize stringCount = _stringCount;

- (id)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ([super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    // initialise string count and the arrays to log the touches
    self.stringCount = 1;
    self.touches = [[NSMutableArray alloc] initWithCapacity:2];
    self.timestamps = [[NSMutableArray alloc] initWithCapacity:2];
}

// stringCount getter
-(int)stringCount
{
    return _stringCount;
}

// stringCount setter
-(void)setStringCount:(int)stringCount
{
    // clip to >= 1
    if (stringCount < 1)
        stringCount = 1;
    
    // if changed
    if (stringCount != _stringCount)
    {
        // update
        _stringCount = stringCount;
        
        // tell the system it needs to redraw this view
        [self setNeedsDisplay];
    }
}

// drawing
- (void)drawRect:(CGRect)rect
{
    // get the "context" which is the place to which we will draw
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // save the state (colours, pen width etc) so we can restore it when we're done
    CGContextSaveGState(currentContext);
    
    // set up fill and stroke colours
    CGContextSetRGBFillColor(currentContext, 0.5, 0.0, 0.0, 1.0);   // dark red
    CGContextSetRGBStrokeColor(currentContext, 0.0, 0.0, 0.0, 1.0); // black
    
    // set the stroke pen width
    CGContextSetLineWidth(currentContext, 1);
    
    // fill whole view with fill colour
    CGContextFillRect(currentContext, rect);
    
    // calculate geometry, divided screen into N sections where N is stringCount + 1
    const int divisions = self.stringCount + 1;
    const CGFloat divisionWidth = self.bounds.size.width / divisions;
    
    // start at the first string
    CGFloat stringX = divisionWidth;

    for (int i = 0; i < self.stringCount; ++i, stringX += divisionWidth) // move to next string position each time
    {
        // add a line to the path
        CGContextMoveToPoint(currentContext, stringX, 0);
        CGContextAddLineToPoint(currentContext, stringX, self.bounds.size.height);
    }
    
    // draw the path (the strings)
    CGContextStrokePath(currentContext);
    
    // restore the context
    CGContextRestoreGState(currentContext);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    // iterate over the touches
    for (UITouch* touch in touches)
    {
        // find just the touches that have just begun (finger down)
        if (touch.phase == UITouchPhaseBegan)
        {
            // add the touch to the touches array
            [self.touches addObject:touch];
            
            // get the timestamp of the touch and add that as an NSNumber to the timestamps array
            NSNumber* timestamp = [NSNumber numberWithDouble:touch.timestamp];
            [self.timestamps addObject:timestamp];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // calculate geometry, divided screen into N sections where N is stringCount + 1
    const int divisions = self.stringCount + 1;
    const CGFloat divisionWidth = self.bounds.size.width / divisions;
    
    // iterate over the touches
    for (UITouch* touch in touches)
    {
        // find just the touches that have just moved 
        if (touch.phase == UITouchPhaseMoved)
        {
            // compare the timestamps of the last time we saw this touch and now
            // to get the duration since we last saw this touch
            const int timestampIndex = [self.touches indexOfObject:touch];
            NSNumber* prevTimestampObject = self.timestamps[timestampIndex];

            const NSTimeInterval prevTimestamp = [prevTimestampObject doubleValue];
            const NSTimeInterval thisTimestamp = touch.timestamp;
            const NSTimeInterval duration = thisTimestamp - prevTimestamp;
            
            // get the previous and current x positions of this touch
            const CGFloat hereX = [touch locationInView:self].x;
            const CGFloat prevX = [touch previousLocationInView:self].x;
            
            CGFloat stringX = divisionWidth;

            // iterate over the strings
            for (int i = 0; i < self.stringCount; ++i, stringX += divisionWidth)
            {
                // did the touch cross this string since the last time we saw this touch?
                if (((prevX < stringX) && (hereX >= stringX)) ||
                    ((prevX > stringX) && (hereX <= stringX)))
                {
                    // calculate a velocity value based on the speed the finger was moving
                    const CGFloat distance = fabsf (hereX - prevX) / self.bounds.size.width;
                    const CGFloat velocity = (distance / duration) / self.stringCount;
                    
                    // send the pluck message to our delegate, clipping velocity to <= 1
                    [self.delegate guitarStringsView:self
                                       stringPlucked:i
                                        withVelocity:velocity < 1 ? velocity : 1.f];
                }
            }
            
            // update the strored timestamp for this touch for next time
            self.timestamps[timestampIndex] = [NSNumber numberWithDouble:thisTimestamp];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // iterate over the touches
    for (UITouch* touch in touches)
    {
        // just get touches that have ended or have been cancelled
        if ((touch.phase == UITouchPhaseEnded) ||
            (touch.phase == UITouchPhaseCancelled))
        {
            // get the index of this touch in our touches array
            const int index = [self.touches indexOfObject:touch];
            
            // remove the touch from the touches array
            [self.touches removeObjectAtIndex:index];
            
            // remove the associated timestamp
            [self.timestamps removeObjectAtIndex:index];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // do same as touchesEnded: in this case
    [self touchesEnded:touches withEvent:event];
}


@end
