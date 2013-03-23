//
//  PBX_Forwarder.m
//  PBX Forwarder
//
//  Created by Ernesto MB on 21/03/13.
//  Copyright (c) 2013 Ernesto MB. All rights reserved.
//

#import "PBX_Forwarder.h"

@implementation PBX_Forwarder


- (id)initWithBundle:(NSBundle *)bundle
{
    if ((self = [super initWithBundle:bundle]) != nil ) {
        appID = PREFPANE_NAME;
    }
    
    return self;
}

- (id)getPreferenceValueForKey:(CFStringRef)key withType:(CFTypeID)type
{
    CFPropertyListRef value = CFPreferencesCopyAppValue(key, appID);
    
    if (type == CFBooleanGetTypeID()) {
        if (value && CFGetTypeID(value) == type) {
            return (id)CFBooleanGetValue(value);
        }
        return NO;
    } else if (type == CFStringGetTypeID()) {
        if (value && CFGetTypeID(value) == type) {
            return (NSString *)value;
        }
    }
    if (value) {
        CFRelease(value);
    }
    return @"";
}

- (bool)getBooleanPreferenceValueForKey:(CFStringRef)key
{
    return [self getPreferenceValueForKey:key withType:CFBooleanGetTypeID()];
}

- (id)getStringPreferenceValueForKey:(CFStringRef)key
{
    return [self getPreferenceValueForKey:key withType:CFStringGetTypeID()];
}

- (void)setPreferenceValueForKey:(CFStringRef)key withValue:(CFPropertyListRef)value
{
    CFNotificationCenterRef center;
    CFPreferencesSetAppValue(key, value, appID);
    CFPreferencesAppSynchronize(appID);
    center = CFNotificationCenterGetDistributedCenter();
    CFNotificationCenterPostNotification(center, CFSTR("Menta PBX preferences changed"), NULL, NULL, TRUE);
}

- (void)mainViewDidLoad
{
    NSLog(@"mainViewDidLoad");
    
    [forwardingToggler setState:[self getBooleanPreferenceValueForKey:KEY_TOGGLE_FORWARDING]];
    [extensionNumber setStringValue:[self getStringPreferenceValueForKey:KEY_EXTENSION_NUMBER]];
    [extensionPassword setStringValue:[self getStringPreferenceValueForKey:KEY_EXTENSION_PASSWORD]];
    [targetForwardingNumber setStringValue:[self getStringPreferenceValueForKey:KEY_TARGET_FORWARDING_NUMBER]];
    
    [self updateForwardingTogglerButton];
    
    NSLog(@"state %@", [forwardingToggler stringValue]);
    
}

- (void)updateForwardingTogglerButton
{
    [forwardingToggler setTitle:[forwardingToggler state] ? @"DESACTIVAR FORWARDING" : @"ACTIVAR FORWARDING"];
}

- (IBAction)preferenceDidChange:(id)sender
{

    [progressIndicator setHidden:FALSE];
    [progressIndicator startAnimation:self];
    
    if (sender == forwardingToggler) {
        [self setPreferenceValueForKey:KEY_TOGGLE_FORWARDING withValue:[forwardingToggler state] ? kCFBooleanTrue : kCFBooleanFalse];
        [self updateForwardingTogglerButton];
        
    } else if (sender == extensionNumber) {
        [self setPreferenceValueForKey:KEY_EXTENSION_NUMBER withValue:[extensionNumber stringValue]];
    } else if (sender == extensionPassword) {
        [self setPreferenceValueForKey:KEY_EXTENSION_PASSWORD withValue:[extensionPassword stringValue]];
    } else if (sender == targetForwardingNumber) {
        [self setPreferenceValueForKey:KEY_TARGET_FORWARDING_NUMBER withValue:[targetForwardingNumber stringValue]];
    }
    
    [progressIndicator stopAnimation:self];
    [progressIndicator setHidden:TRUE];
    
    NSLog(@"Saving %@ = %@ in preferenceDidChange", sender, [sender stringValue]);
}



@end
