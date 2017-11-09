#import <UIKit/UIKit.h>
#import <PAEEngine/PAEEngine.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


-(void)play:(int)index velocity:(float)velocity;
-(void)transpose:(int)fret ofString:(int)string withState:(BOOL)state;


@end


