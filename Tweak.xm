#import "Lifeguard.h"

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

%hook SpringBoard

-(void)_ringerChanged:(struct __IOHIDEvent *)arg1 {
	triggerLifeguard('S');
	%orig;
}

-(_Bool)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1 {
	int type = arg1.allPresses.allObjects[0].type;
   	 int force = arg1.allPresses.allObjects[0].force;
        
	// type = 101 -> Home button
	// type = 104 -> Power button
	// 102 and 103 are volume buttons

	// force = 0 -> button released
	// force = 1 -> button pressed
	if (force == 1) {
		if (type == 103)
			triggerLifeguard('D');
		else if (type == 102)
			triggerLifeguard('U');
		else if (type == 104)
			triggerLifeguard('L');
		else if (type == 101)
			triggerLifeguard('H');
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
	lastPress = now;
	
	[sequence appendFormat:@"%c", button];
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

