//
//  mcmap_macAppDelegate.h
//  mcmap-mac
//
//  Created by DK on 10/7/10.
//

#import <Cocoa/Cocoa.h>

@interface mcmap_macAppDelegate : NSObject <NSApplicationDelegate, NSFileManagerDelegate>

- (void)windowWillClose:(NSNotification *)aNotification;

@property (weak) IBOutlet NSWindow *window;

@end
