#import <UIKit/UIKit.h>

@class GuitarStringsView;

// delegate class for responding to stings being "plucked"
@protocol GuitarStringsViewDelegate <NSObject>

// string at a certain index was plucked at a particular velocity
-(void)guitarStringsView:(GuitarStringsView*)view stringPlucked:(int)index withVelocity:(float)velocity;
@end

// guitar string interface
@interface GuitarStringsView : UIView

// number of strings, minimum 1
// can be set via the User Defined Runtime Attributes in Interface Builder
@property (nonatomic) int stringCount;

// delegate for responding to stings being "plucked"
@property (weak, nonatomic) id <GuitarStringsViewDelegate> delegate;
@end
