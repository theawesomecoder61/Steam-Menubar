//
//  AppDelegate.m
//  Steam Menubar
//
//  Created by Andrew Mellen on 7/9/16.
//  Copyright © 2016 Andrew Mellen. All rights reserved.
//

#import "AppDelegate.h"
#import "DCOAboutWindowController.h"
#import "MASPreferencesWindowController.h"
#import "GeneralTab.h"
#import "FavoritesTab.h"

#define seperatorName @"- Seperator -"


@interface AppDelegate () {
    DCOAboutWindowController *aboutWindow;
    NSWindowController *_preferencesWindowController;
}

@property (weak) IBOutlet NSWindow *window;

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *puMenu;
@property (weak) IBOutlet NSMenu *recentMenu;
@property (weak) IBOutlet NSMenu *favoritesMenu;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    aboutWindow = [[DCOAboutWindowController alloc] init];

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.puMenu];
    NSImage *img = [NSImage imageNamed:@"mbi"];
    [img setSize:NSMakeSize(16, 16)];
    [self.statusItem setImage:img];
    [self.statusItem.image setTemplate:YES];
    [self.statusItem setHighlightMode:YES];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"Order"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"Online", @"Busy", @"Away", @"Offline", seperatorName, @"Store", @"Library", @"Community", seperatorName, @"Friends", @"Music Player", @"Screenshots", @"Servers", @"Settings", seperatorName, @"Big Picture", @"Exit", nil] forKey:@"Order"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"Enabled"] == nil) {
        NSArray *arr = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Order"]];
        NSMutableArray *marr = [NSMutableArray array];
        for(int i=0;i<[arr count];i++) {
            [marr addObject:[NSNumber numberWithBool:YES]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"Enabled"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emptyAndFillMenu) name:@"ReloadItems" object:nil];
    
    
    // recent - not too sure if this is possible
    
    // favorites - coming soon
    
    // the rest
    [self emptyAndFillMenu];
    
//    [self openPrefs];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - MASPrefs
- (NSWindowController*)preferencesWindowController {
    if(_preferencesWindowController == nil) {
        NSArray *controllers = [[NSArray alloc] initWithObjects:[[GeneralTab alloc] init], nil];
        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
    }
    return _preferencesWindowController;
}


- (void)emptyAndFillMenu {
    for(NSMenuItem *mi in [self.puMenu itemArray]) {
        [self.puMenu removeItem:mi];
    }
    
    NSArray *items = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Order"]];
    NSArray *enabled = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Enabled"]];
    NSArray *actions = [NSArray arrayWithObjects:@"setOnline", @"setBusy", @"setAway", @"setOffline", @"openStore", @"openLibrary", @"openCommunity", @"openFriends", @"openMusicPlayer", @"openScreenshots", @"openServers", @"openSettings", @"openBigPicture", @"exitSteam", nil];
    for(int i=0;i<[items count];i++) {
        // detect if the item is a seperator
        if([[items objectAtIndex:i] isNotEqualTo:seperatorName]) {
            if([[enabled objectAtIndex:i] boolValue] == YES) {
                for(NSString *a in actions) {
                    if([[a lowercaseString] containsString:[[[items objectAtIndex:i] lowercaseString]stringByReplacingOccurrencesOfString:@" " withString:@""]]) {
                        [self.puMenu addItemWithTitle:[items objectAtIndex:i] action:NSSelectorFromString(a) keyEquivalent:@""];
                    }
                }
            }
        } else {
            [self.puMenu addItem:[NSMenuItem separatorItem]];
        }
    }
    
    // lastly
    [self.puMenu addItem:[NSMenuItem separatorItem]];
    [self.puMenu addItemWithTitle:@"About" action:@selector(openAbout) keyEquivalent:@""];
    [self.puMenu addItemWithTitle:@"Preferences" action:@selector(openPrefs) keyEquivalent:@","];
    [self.puMenu addItemWithTitle:@"Quit" action:@selector(quitApp) keyEquivalent:@"q"];
}

//
// ACTIONS
//
- (void)setOnline {
    [self runScheme:@"steam://friends/status/online"];
}
- (void)setBusy {
    [self runScheme:@"steam://friends/status/busy"];
}
- (void)setAway {
    [self runScheme:@"steam://friends/status/away"];
}
- (void)setOffline {
    [self runScheme:@"steam://friends/status/offline"];
}
//
- (void)openStore {
    [self runScheme:@"steam://url/StoreFrontPage"];
}
- (void)openLibrary {
    [self runScheme:@"steam://open/games"];
}
- (void)openCommunity {
    [self runScheme:@"steam://url/CommunityHome/"];
}
- (void)openFriendActivity { // I can't find this one
    [self runScheme:@"steam://"];
}
//
- (void)openFriends {
    [self runScheme:@"steam://open/friends"];
}
- (void)openMusicPlayer {
    [self runScheme:@"steam://open/musicplayer"];
}
- (void)openScreenshots {
    [self runScheme:@"steam://open/screenshots"];
}
- (void)openServers {
    [self runScheme:@"steam://open/servers"];
}
- (void)openSettings {
    [self runScheme:@"steam://open/settings"];
}
//
- (void)openBigPicture {
    [self runScheme:@"steam://open/bigpicture"];
}
- (void)openSteamVR { // same here
    [self runScheme:@"steam://open/vr"];
}
- (void)exitSteam {
    NSArray *ra = [[NSWorkspace sharedWorkspace] runningApplications];
    for(NSRunningApplication *a in ra) {
        if([[a bundleIdentifier] isEqualTo:@"com.valvesoftware.steam"]) {
            [a terminate];
        }
    }
}
//
- (void)openAbout {
    [aboutWindow showWindow:nil];
}
- (void)openPrefs {
    [NSApp activateIgnoringOtherApps:YES];
    [[NSUserDefaults standardUserDefaults] setValue:0 forKey:@"MASPreferences Selected Identifier View"];
    [self.preferencesWindowController showWindow:nil];
}
- (void)quitApp {
    [NSApp terminate:self];
}

//
// HELPER
//
- (void)runScheme:(NSString *)u {
    NSLog(@"%@", u);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:u]];
}

@end