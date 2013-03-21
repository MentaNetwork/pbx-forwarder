//
//  PBX_Forwarder.h
//  PBX Forwarder
//
//  Created by Ernesto MB on 21/03/13.
//  Copyright (c) 2013 Ernesto MB. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@interface PBX_Forwarder : NSPreferencePane
{
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSNumberFormatter *extensionNumber;
    IBOutlet NSSecureTextField *extensionPassword;
    IBOutlet NSNumberFormatter *targetForwardingNumber;
    IBOutlet NSButton *toggleForwarding;
    
}
- (void)mainViewDidLoad;

@end
