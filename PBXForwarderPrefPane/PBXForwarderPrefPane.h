//
//  PBXForwarderPrefPane.h
//  PBXForwarderPrefPane
//
//  Created by Ernesto MB on 23/03/13.
//  Copyright (c) 2013 Ernesto MB. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

#define KEY_TOGGLE_FORWARDING CFSTR("toggle_forwarding")
#define KEY_EXTENSION_NUMBER CFSTR("extension_number")
#define KEY_EXTENSION_PASSWORD CFSTR("extension_password")
#define KEY_TARGET_FORWARDING_NUMBER CFSTR("target_forwarding_number")
#define PREFPANE_NAME CFSTR("mx.menta.pbx-forwarder-prefpane")
#define APP_PATH @"/Applications/PBXForwarderService.app"


@interface PBXForwarderPrefPane : NSPreferencePane
{
    IBOutlet NSButton *forwardingToggler;
    IBOutlet NSTextField *extensionNumber;
    IBOutlet NSSecureTextField *extensionPassword;
    IBOutlet NSTextField *targetForwardingNumber;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *errorMessage;
    IBOutlet NSImageView *logo;
    CFStringRef appID;
}

- (IBAction)preferenceDidChange:(id)sender;

- (id)getPreferenceValueForKey:(CFStringRef)key withType:(CFTypeID)type;

- (bool)getBooleanPreferenceValueForKey:(CFStringRef)key;

- (id)getStringPreferenceValueForKey:(CFStringRef)key;

- (void)setPreferenceValueForKey:(CFStringRef)key withValue:(CFPropertyListRef)value;

- (void)updateForwardingVisualStatus;

- (BOOL)requiredDataIsComplete;

- (void)addForwarderAsLoginItem;

- (void)removeForwarderAsLoginItem;

@end
