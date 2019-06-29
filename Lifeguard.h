#import <Foundation/Foundation.h>
#import <spawn.h>

@interface Lifeguard: NSObject
-(id)init;
-(void)buttonPressed_LG:(char) button;
-(void)respring_LG:(BOOL)safeMode;
@end
