#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.guitarStringView.delegate = self;
    self.fretBoardView.strings = self.guitarStringView;
    self.fretBoardView.delegate = self;
    
    for (UIButton* zone in self.zones){         // Initialising buttons
        zone.highlighted = 0;
    }
    
}

-(void)guitarStringsView:(GuitarStringsView*)view stringPlucked:(int)index withVelocity:(float)velocity;
{    
    AppDelegate* app = [[UIApplication sharedApplication] delegate];
    [app play:index velocity:velocity];
}

-(void)fretBoardView:(FretBoardView*)view fret:(int)fret string:(int)string state:(BOOL)fingerIsDown
{
   AppDelegate* app = [[UIApplication sharedApplication] delegate];
    [app transpose:fret ofString:string withState:fingerIsDown];
   
    // updating the highlighted settings for the buttons
    for (UIButton* zone in self.zones)
    {
        if ((zone.tag == 0) && (string == 0) && (fret == 0))
        {
            zone.highlighted = fingerIsDown;
        }else if (zone.tag == ((fret*6)+string))
        {
            zone.highlighted = fingerIsDown;
        }
    }
    
}



@end
