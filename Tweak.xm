#import "Lifeguard.h"
#define VUP_BUTTON 102
#define VDOWN_BUTTON 103
#define POWER_BUTTON 104
#define HOME_BUTTON 101

static NSString *respringSequence = @"UDUD";
static NSString *safeModeSequence = @"SSUDUD";
static id lifeguardInstance;
static BOOL tweakEnabled = YES;
static BOOL isRunning = NO;

static void triggerLifeguard(char button) {
	if (tweakEnabled && !isRunning) {
		isRunning = YES;
		if (!lifeguardInstance) lifeguardInstance = [[Lifeguard alloc] init];
		[lifeguardInstance buttonPressed_LG:button];
		isRunning = NO;
	}
}


//iOS 13.4 and up
%hook SBFluidSwitcherGestureManager
- (void)grabberTongueBeganPulling:(id)arg1 withDistance:(double)arg2 andVelocity:(double)arg3 andGesture:(id)arg4  {
		NSLog(@"[BOP] 13.4");
  	triggerLifeguard('H');
		%orig;
}
%end


//iOS 13.3 and below
%hook SBFluidSwitcherGestureManager
-(void)grabberTongueBeganPulling:(id)arg1 withDistance:(double)arg2 andVelocity:(double)arg3  {
		triggerLifeguard('H');
			NSLog(@"[BOP] 13.3");
		%orig;
}
%end


%hook SpringBoard

-(void)_ringerChanged:(struct __IOHIDEvent *)arg1 {
	triggerLifeguard('S');
	%orig;
}

        
-(_Bool)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1 {
	// type = 101 -> Home button
	// type = 104 -> Power button
	// 102 and 103 are volume buttons

	// force = 0 -> button released
	// force = 1 -> button pressed

	int type2 = 0;
	int type = arg1.allPresses.allObjects[0].type;
	int force = arg1.allPresses.allObjects[0].force;
	if ([arg1.allPresses.allObjects count] >= 2){
		 type2 = arg1.allPresses.allObjects[1].type;
		 int force2 = arg1.allPresses.allObjects[1].force;
		 if ((type == VUP_BUTTON && type2 == VDOWN_BUTTON) || ((type == VDOWN_BUTTON) && (type2 == VUP_BUTTON))){
			 if (force == 1 && force2 == 1){
				// NSLog(@"[BOP] Volume");
				 triggerLifeguard('V');
			}
			}
		 if (type+type2 == 207 && force+force2 == 2){
			 triggerLifeguard('P');
		}
	}else {
		if (force == 1) {
		//	NSLog(@"[BOP] Single button %i", type);
				if (type == VDOWN_BUTTON)
					triggerLifeguard('D');
				else if (type == VUP_BUTTON)
					triggerLifeguard('U');
				else if (type == POWER_BUTTON)
					triggerLifeguard('L');
				else if (type == HOME_BUTTON)
					triggerLifeguard('H');
			}
	}
	return %orig;
}

%end


@implementation Lifeguard

NSMutableString *sequence = [@"" mutableCopy];
NSTimeInterval lastPress;

-(id)init {
	lastPress = 0.0;
	return self;
}

-(void)buttonPressed_LG:(char)button {

	NSTimeInterval now = [[NSDate date] timeIntervalSince1970] * 1000;
	if (now - lastPress > 650.0)
		[sequence setString:@""];
	if (now - lastPress < 100.0)
		[sequence deleteCharactersInRange:NSMakeRange([sequence length]-1, 1)];
	lastPress = now;
	
	[sequence appendFormat:@"%c", button];
	NSLog(@"[BOP] Sequence:%@ Added:%c" , sequence, button);
	if ([respringSequence length] >= [safeModeSequence length]) {
		if ([[sequence copy] containsString: respringSequence])
			[self respring_LG:NO];
		else if ([[sequence copy] containsString: safeModeSequence])
			[self respring_LG:YES];
	} else {
		if ([[sequence copy] containsString: safeModeSequence])
			[self respring_LG:YES];
		else if ([[sequence copy] containsString: respringSequence])
			[self respring_LG:NO];
	}
}

-(void)respring_LG:(BOOL)safeMode {
	[sequence setString:@""];
	pid_t pid;
	if (safeMode) {
		const char* args[] = {"killall", "-SEGV", "SpringBoard", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
	} else {
		const char* args[] = {"killall", "backboardd", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
	}
}

@end



static void loadPrefs() {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.kurrt.lifeguardprefs.plist"];
    if(prefs) {
        tweakEnabled = ([prefs objectForKey:@"tweakEnabled"] ? [[prefs objectForKey:@"tweakEnabled"] boolValue] : tweakEnabled);
        respringSequence = [(NSString*)[prefs objectForKey:@"respringSequence"] uppercaseString];
        safeModeSequence = [(NSString*)[prefs objectForKey:@"safeModeSequence"] uppercaseString];
		if ([respringSequence length] <= 0) respringSequence = @"X";
		if ([safeModeSequence length] <= 0) safeModeSequence = @"X";
    }
    [prefs release];
}

%ctor {
    	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.kurrt.lifeguardprefs/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    	loadPrefs();
}
