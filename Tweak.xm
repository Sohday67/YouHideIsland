/**
 * YouHideIsland
 * A YTLite tweak that prevents the Dynamic Island from showing
 * when the YouTube app is in the foreground.
 * 
 * The Dynamic Island displays Now Playing information, which is
 * controlled by MPNowPlayingInfoCenter. This tweak hooks into
 * the setNowPlayingInfo: method and only allows updates when
 * the app is in the background state.
 * 
 * Licensed under MIT License
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

/**
 * Flag to allow clearing Now Playing info when returning to foreground.
 * This bypasses the hook check when we intentionally want to clear the info.
 */
static BOOL allowClearingNowPlayingInfo = NO;

/**
 * Flag to allow publishing stored Now Playing info when entering background.
 * This bypasses the foreground check when we want to publish the stored info.
 */
static BOOL allowPublishingStoredInfo = NO;

/**
 * Stores the last Now Playing info that was blocked while in foreground.
 * This info will be published when the app enters background.
 */
static NSDictionary *pendingNowPlayingInfo = nil;

/**
 * Lock object for thread-safe access to shared state.
 */
static NSObject *stateLock = nil;

/**
 * Helper function to check if the app is currently active (truly in foreground).
 * Returns YES only if the app is in Active state.
 * Note: We don't include Inactive state because that's a transitional state
 * (e.g., when app is going to background or coming from background).
 */
static BOOL isAppActive(void) {
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    return (state == UIApplicationStateActive);
}

%hook MPNowPlayingInfoCenter

/**
 * Hook the setNowPlayingInfo: method to conditionally block updates.
 * When the app is active (foreground), we store the info for later
 * and don't update the Now Playing info, preventing the Dynamic Island from showing.
 * When the app is in the background or transitioning, we allow the update to proceed.
 */
- (void)setNowPlayingInfo:(NSDictionary *)nowPlayingInfo {
    @synchronized(stateLock) {
        // Allow clearing Now Playing info when explicitly requested (app returning to foreground)
        if (allowClearingNowPlayingInfo && nowPlayingInfo == nil) {
            %orig(nowPlayingInfo);
            return;
        }
        
        // Allow publishing stored info when entering background
        if (allowPublishingStoredInfo) {
            %orig(nowPlayingInfo);
            return;
        }
        
        if (isAppActive()) {
            // App is in active foreground - store the info for later and don't update
            // This prevents the Dynamic Island from appearing while using the app
            if (nowPlayingInfo != nil) {
                pendingNowPlayingInfo = [nowPlayingInfo copy];
            }
            return;
        }
        
        // App is in the background or transitioning - allow the update to proceed
        // Also clear any pending info since we're publishing directly
        pendingNowPlayingInfo = nil;
        %orig(nowPlayingInfo);
    }
}

%end

/**
 * Constructor - runs when the tweak is loaded.
 * Sets up observers for app state changes to handle edge cases.
 */
%ctor {
    // Initialize the lock object
    stateLock = [[NSObject alloc] init];
    
    %init;
    
    // Observe when app enters background to publish any pending Now Playing info
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
        @synchronized(stateLock) {
            // When app enters background, publish any pending Now Playing info
            // This ensures the Dynamic Island shows correctly for background playback
            if (pendingNowPlayingInfo != nil) {
                allowPublishingStoredInfo = YES;
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:pendingNowPlayingInfo];
                allowPublishingStoredInfo = NO;
                pendingNowPlayingInfo = nil;
            }
        }
    }];
    
    // Observe when app becomes active to ensure Now Playing info is cleared
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
        @synchronized(stateLock) {
            // When app becomes active (foreground), clear existing Now Playing info
            // This removes any Dynamic Island display that might have been set
            // Also clear any pending info since we're back in foreground
            pendingNowPlayingInfo = nil;
            allowClearingNowPlayingInfo = YES;
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
            allowClearingNowPlayingInfo = NO;
        }
    }];
}
