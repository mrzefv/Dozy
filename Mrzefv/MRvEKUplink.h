#import <UIKit/UIKit.h>

@interface MRvEKUplink : NSObject <UIGestureRecognizerDelegate>

+ (instancetype)shared;

/// Wires a window up with the secret 2-finger-tap gesture and,
/// on first run, queues the onboarding splash. Safe to call more
/// than once per window — later calls are no-ops.
- (void)attachToWindow:(UIWindow *)window;

@end
