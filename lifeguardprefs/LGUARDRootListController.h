#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LGUARDRootListController : PSListController
-(NSArray *)specifiers;
-(void)save;
-(void)email;
-(void)twitter;
-(void)website;
-(void)more;
@end


@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(PSSpecifier *)specifier;
- (CGFloat)preferredHeightForWidth:(CGFloat)width;
@end

@interface LifeguardBigTextCell : PSTableCell <PreferencesTableCustomView> {
	UILabel *_label;
}
@end

@interface PSControlTableCell : PSTableCell
- (UIControl *)control;
@end
@interface PSSwitchTableCell : PSControlTableCell
- (id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface LifeguardSRSwitchTableCell : PSSwitchTableCell
@end

@interface LifeguardColorButtonCell : PSTableCell
@end