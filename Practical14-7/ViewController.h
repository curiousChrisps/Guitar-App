#import <UIKit/UIKit.h>
#import "GuitarStringsView.h"
#import "FretBoardView.h"

// our view controller is a GuitarStringsViewDelegate that can respond
// to pluck messages from our GuitarStringsView
// and touches on FretBoardView
@interface ViewController : UIViewController <GuitarStringsViewDelegate,FretBoardViewDelegate>
@property (weak, nonatomic) IBOutlet GuitarStringsView *guitarStringView;
@property (weak, nonatomic) IBOutlet FretBoardView *fretBoardView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *zones;


@end
