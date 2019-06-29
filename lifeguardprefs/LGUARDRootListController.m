#include "LGUARDRootListController.h"

static UIColor *defaultTint;
static UIButton *save;

@implementation LGUARDRootListController

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	UIColor *tintColor = [UIColor redColor];
	UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
	defaultTint = [keyWindow tintColor];
	[keyWindow setTintColor:tintColor];

	[[NSNotificationCenter defaultCenter] addObserver:self 
                                         selector:@selector(keyboardDidShow:)
                                             name:UIKeyboardWillShowNotification
                                           object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (defaultTint) {
		UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
		[keyWindow setTintColor:defaultTint];
	}
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

-(void)save {
	[self.view endEditing:YES];
	save.hidden = YES;
}


-(void)loadView {
	[super loadView];
	save = [[UIButton alloc] initWithFrame:CGRectZero];
	[save setTitle:@"Save" forState:UIControlStateNormal];
	[save sizeToFit];
	[save setTitleColor: [UIColor redColor] forState:UIControlStateNormal];
	[save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
	save.hidden = YES;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:save];
}


-(void) email {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:[@"mailto:dev@kurrt.com?subject=Lifeguard Support Request&body=Please provide as mush detail as possible about your request. If you encounter a bug, the more information you provide me, the quicker I am going to be able to fix the bug.<br>Device Model: <br>iOS Version: <br><br>" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
	[application openURL:URL options:@{} completionHandler:nil];
}

-(void) twitter {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://twitter.com/KurrtDev"];
	[application openURL:URL options:@{} completionHandler:nil];
}

-(void) website {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://kurrt.com"];
	[application openURL:URL options:@{} completionHandler:nil];
}

-(void) more {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://kurrt.com/repo"];
	[application openURL:URL options:@{} completionHandler:nil];
}


- (void)keyboardDidShow: (NSNotification *) notif{
    save.hidden = NO;
}


@end


@implementation LifeguardBigTextCell

float cellHeight = 200.0f;

- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
	if (self) {
		_label = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, self.frame.size.width - 32, cellHeight - 48)];
		[_label setLineBreakMode:NSLineBreakByWordWrapping];
		[_label setNumberOfLines:0];
		[_label setText:@"H - Home Button\nL - Lock Button\nU - Volume Up Button\nD - Volume Down Button\nS - Mute Switch\n"];
		[_label sizeToFit];
		[self addSubview:_label];
		[_label release];
		
		UILabel *_label2 = [[UILabel alloc] initWithFrame:CGRectMake(16, _label.frame.size.height + 16, self.frame.size.width - 32, cellHeight - 48)];
		[_label2 setLineBreakMode:NSLineBreakByWordWrapping];
		[_label2 setNumberOfLines:0];
		[_label2 setText:@"Define your chosen patterns using the letters above.\ne.g. SSUDUD defines the pattern: [toggle switch] [toggle switch] [volume up] [volume down] [volume up] [volume down]\n\nPatterns are not case sensitive. To disable an option leave the field blank. Use of undefined letters will also disable the option."];
		[_label2 setFont:[UIFont systemFontOfSize:12]];
		[_label2 sizeToFit];
		[self addSubview:_label2];
		[_label2 release];
		
		cellHeight = _label.frame.size.height + _label2.frame.size.height + 48;
		
	}
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	// Return a custom cell height.
	return cellHeight;
}
@end


@implementation LifeguardColorButtonCell
-(void) layoutSubviews {
	[super layoutSubviews];
	UIColor *tintColor = [UIColor redColor];
	[[self textLabel] setTextColor:tintColor];
}
@end

@implementation LifeguardSRSwitchTableCell

-(id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier { //init method
	self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
	UIColor *tintColor = [UIColor redColor];
	if (self) {
		[((UISwitch *)[self control]) setOnTintColor:tintColor];
	}
	return self;
}

@end