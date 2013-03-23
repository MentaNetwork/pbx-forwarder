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

- (void)addForwarderAsLoginItem
{
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:APP_PATH];
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		// insert
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
        NSLog(@"Adding login item %@", item);
		if (item) {
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}

- (void)removeForwarderAsLoginItem
{
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:APP_PATH];
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		// cast the login items to a NSArray for easy iteration
		NSArray *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
        
		for(int i = 0; i < [loginItemsArray count]; i++) {
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
			// resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:APP_PATH] == NSOrderedSame) {
                    NSLog(@"Removing login item %@", itemRef);
					LSSharedFileListItemRemove(loginItems, itemRef);
				}
			}
		}
		[loginItemsArray release];
	}
}


@end
