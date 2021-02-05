//
//  MCMapPrefsController.h
//  MCMap Live
//
//  Created by DK on 10/24/10.
//

#import <Cocoa/Cocoa.h>
#import "MCMapOpenGLView.h"

@interface MCMapPrefsController : NSWindowController <NSTableViewDataSource> {
    
    IBOutlet MCMapOpenGLView * mapview;
    IBOutlet NSTableView * colorsTable;
    IBOutlet NSTextField * numberOfRenderers;
    IBOutlet NSStepper * numberOfRenderersStepper;
}

- (IBAction)setRenderSettings:(id)sender;
- (IBAction)defaultRenderSettings:(id)sender;
- (IBAction)setMaxRenderers:(id)sender;
- (IBAction)showColorsInFinder:(id)sender;
- (void) awakeFromNib;
- (void) populateColorsList;
- (IBAction) addColor:(id)sender;
- (IBAction) removeColor:(id)sender;
- (void) windowWillClose:(NSNotification *)notification;
- (void) windowDidBecomeKey:(NSNotification *)notification; 

@end
