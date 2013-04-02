//
//  PBXForwarderPrefPane.m
//  PBXForwarderPrefPane
//
//  Created by Ernesto MB on 23/03/13.
//  Copyright (c) 2013 Ernesto MB. All rights reserved.
//

#import "PBXForwarderPrefPane.h"

NSString * const KEY_TOGGLE_FORWARDING = @"toggle_forwarding";
NSString * const KEY_EXTENSION_NUMBER = @"extension_number";
NSString * const KEY_EXTENSION_PASSWORD = @"extension_password";
NSString * const KEY_TARGET_FORWARDING_NUMBER = @"target_forwarding_number";
NSString * const PREFPANE_NAME = @"mx.menta.pbx-forwarder-prefpane";
NSString * const APP_PATH = @"/Applications/PBXForwarderService.app";

@implementation PBXForwarderPrefPane

- (id)initWithBundle:(NSBundle *)bundle
{
    if ((self = [super initWithBundle:bundle]) != nil ) {
        NSLog(@"-initWithBundle: starting app");
    }
    return self;
}

- (NSString *)getPreferenceValueForKey:(NSString *)key
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    [defaults addSuiteNamed:PREFPANE_NAME];
    return [defaults stringForKey:key];
}

- (void)setPreferenceValueForKey:(NSString *)key withValue:(CFPropertyListRef)value
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    [defaults addSuiteNamed:PREFPANE_NAME];
    [defaults setValue:(__bridge id)(value) forKey:key];
    [defaults synchronize];
}

- (void)mainViewDidLoad
{
    NSLog(@"-mainViewDidLoad: setting interface values from preferences");
    [forwardingToggler setStringValue:[self getPreferenceValueForKey:KEY_TOGGLE_FORWARDING]];
    [extensionNumber setStringValue:[self getPreferenceValueForKey:KEY_EXTENSION_NUMBER]];
    [extensionPassword setStringValue:[self getPreferenceValueForKey:KEY_EXTENSION_PASSWORD]];
    [targetForwardingNumber setStringValue:[self getPreferenceValueForKey:KEY_TARGET_FORWARDING_NUMBER]];
    
    [self updateForwardingVisualStatus];
    
    NSLog(@"-mainViewDidLoad: forwarding state is %@", [forwardingToggler stringValue]);
}

- (void)updateForwardingVisualStatus
{
    NSInteger on = [forwardingToggler state];
    [forwardingToggler setTitle:on ? @"DESACTIVAR FORWARDING" : @"ACTIVAR FORWARDING"];
    [logo setAlphaValue:on ? 1.0 : 0.3];
}

- (BOOL)requiredDataIsComplete
{
    NSString * error;
    
    if ([extensionNumber.stringValue isEqualToString:@""]) {
        error = @"Falta la extensión";
        [extensionNumber becomeFirstResponder];
    } else if ([extensionPassword.stringValue isEqualToString:@""]) {
        error = @"Falta el password";
        [extensionPassword becomeFirstResponder];
    } else if ([targetForwardingNumber.stringValue isEqualToString:@""]) {
        error = @"Falta el número de destino";
        [targetForwardingNumber becomeFirstResponder];
    } else if (targetForwardingNumber.stringValue.length < 8) {
        error = @"El número de destino es muy corto";
        [targetForwardingNumber becomeFirstResponder];
    } else {
        error = @"";
    }
    
    [errorMessage setStringValue:error];
    return [error isEqualToString:@""];
}

- (IBAction)preferenceDidChange:(id)sender
{
    //[progressIndicator setHidden:NO];
    //[progressIndicator startAnimation:self];
    
    if (![self requiredDataIsComplete]) {
        [forwardingToggler setState:0];
        [self removeForwarderAsLoginItem];
        [self updateForwardingVisualStatus];
        return;
    }
    
    if (sender == forwardingToggler) {
        CFBooleanRef forwarding = [forwardingToggler state] ? kCFBooleanTrue : kCFBooleanFalse;
        
        [self setPreferenceValueForKey:KEY_TOGGLE_FORWARDING withValue:forwarding];
        
        if (forwarding == kCFBooleanTrue) {
            [self addForwarderAsLoginItem];
        } else {
            [self removeForwarderAsLoginItem];
        }
        
        CFRelease(forwarding);
        
        [self updateForwardingVisualStatus];
        
    } else if (sender == extensionNumber) {
        [self setPreferenceValueForKey:KEY_EXTENSION_NUMBER withValue:(__bridge CFPropertyListRef)([extensionNumber stringValue])];
    } else if (sender == extensionPassword) {
        [self setPreferenceValueForKey:KEY_EXTENSION_PASSWORD withValue:(__bridge CFPropertyListRef)([extensionPassword stringValue])];
    } else if (sender == targetForwardingNumber) {
        [self setPreferenceValueForKey:KEY_TARGET_FORWARDING_NUMBER withValue:(__bridge CFPropertyListRef)([targetForwardingNumber stringValue])];
    }
    
    //[progressIndicator stopAnimation:self];
    //[progressIndicator setHidden:YES];
    
    NSLog(@"-preferenceDidChange: saving preference %@ with %@", sender, [sender stringValue]);
}

- (void)addForwarderAsLoginItem
{
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:APP_PATH];
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSLog(@"-addForwarderAsLoginItem: login items are %@", loginItems);
	if (loginItems) {
		// insert
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
        NSLog(@"-addForwarderAsLoginItem: adding login item %@", item);
		if (item) {
			CFRelease(item);
        }
        CFRelease(loginItems);
	}
}

- (void)removeForwarderAsLoginItem
{
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:APP_PATH];
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		// cast the login items to a NSArray for easy iteration
		NSArray *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
        
		for(int i = 0; i < [loginItemsArray count]; i++) {
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)loginItemsArray[i];
			// resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
				if ([urlPath compare:APP_PATH] == NSOrderedSame) {
                    NSLog(@"-removeForwarderAsLoginItem: removing login item %@", itemRef);
					LSSharedFileListItemRemove(loginItems, itemRef);
				}
			}
		}
	}
}

@end
