//
//  PBXForwarderPrefPane.h
//  PBXForwarderPrefPane
//
//  Created by Ernesto MB on 23/03/13.
//  Copyright (c) 2013 Ernesto MB. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

extern NSString * const KEY_TOGGLE_FORWARDING;
extern NSString * const KEY_EXTENSION_NUMBER;
extern NSString * const KEY_EXTENSION_PASSWORD;
extern NSString * const KEY_TARGET_FORWARDING_NUMBER;
extern NSString * const APP_PATH;

@interface PBXForwarderPrefPane : NSPreferencePane
{
    IBOutlet NSButton *forwardingToggler;
    IBOutlet NSTextField *extensionNumber;
    IBOutlet NSSecureTextField *extensionPassword;
    IBOutlet NSTextField *targetForwardingNumber;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *errorMessage;
    IBOutlet NSImageView *logo;
}

- (IBAction)preferenceDidChange:(id)sender;

- (NSString *)getPreferenceValueForKey:(NSString *)key;

- (void)setPreferenceValueForKey:(NSString *)key withValue:(CFPropertyListRef)value;

- (void)updateForwardingVisualStatus;
                                                            
- (BOOL)requiredDataIsComplete;

- (void)addForwarderAsLoginItem;

- (void)removeForwarderAsLoginItem;

@end
