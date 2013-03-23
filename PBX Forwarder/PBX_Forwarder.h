//
//  PBX_Forwarder.h
//  PBX Forwarder
//
//  Created by Ernesto MB on 21/03/13.
//  Copyright (c) 2013 Ernesto MB. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

#define KEY_TOGGLE_FORWARDING CFSTR("toggle_forwarding")
#define KEY_EXTENSION_NUMBER CFSTR("extension_number")
#define KEY_EXTENSION_PASSWORD CFSTR("extension_password")
#define KEY_TARGET_FORWARDING_NUMBER CFSTR("target_forwarding_number")
#define PREFPANE_NAME CFSTR("mx.menta.pbx-forwarder-prefpane")
#define APP_PATH @"/Applications/PBXForwarder.app"


@interface PBX_Forwarder : NSPreferencePane
{
    IBOutlet NSButton *forwardingToggler;
    IBOutlet NSTextField *extensionNumber;
    IBOutlet NSSecureTextField *extensionPassword;
    IBOutlet NSTextField *targetForwardingNumber;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *errorMessage;
    CFStringRef appID;
}

- (IBAction)preferenceDidChange:(id)sender;

- (id)getPreferenceValueForKey:(CFStringRef)key withType:(CFTypeID)type;

- (bool)getBooleanPreferenceValueForKey:(CFStringRef)key;

- (id)getStringPreferenceValueForKey:(CFStringRef)key;

- (void)setPreferenceValueForKey:(CFStringRef)key withValue:(CFPropertyListRef)value;

- (BOOL)requiredDataIsComplete;

- (void)addForwarderAsLoginItem;

- (void) removeForwarderAsLoginItem;

@end
