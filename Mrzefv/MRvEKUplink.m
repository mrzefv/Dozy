#import "MRvEKUplink.h"
#import <objc/runtime.h>
#import "MRvEKConnectView.h"
#import "MRvEKBoardView.h"

static NSString * const kMRvEKOnboardShownKey = @"com.mrvek.uplink.onboardShown";

#pragma mark - UIWindow swizzle

@interface UIWindow (MRvEKUplinkSwizzle)
- (void)mrvek_makeKeyAndVisible;
@end

@implementation UIWindow (MRvEKUplinkSwizzle)

- (void)mrvek_makeKeyAndVisible {
    // Selectors are exchanged at load time, so this call invokes
    // the original -makeKeyAndVisible implementation.
    [self mrvek_makeKeyAndVisible];
    [[MRvEKUplink shared] attachToWindow:self];
}

@end

#pragma mark - MRvEKUplink

@interface MRvEKUplink ()
@property (nonatomic, strong) NSMapTable<UIWindow *, NSNumber *> *attachedWindows;
@end

@implementation MRvEKUplink

+ (instancetype)shared {
    static MRvEKUplink *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _attachedWindows = [NSMapTable weakToStrongObjectsMapTable];
    }
    return self;
}

- (void)attachToWindow:(UIWindow *)window {
    if (!window || [self.attachedWindows objectForKey:window]) {
        return;
    }
    [self.attachedWindows setObject:@YES forKey:window];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(handleSecretTap:)];
    tap.numberOfTouchesRequired = 2;
    tap.numberOfTapsRequired = 1;
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [window addGestureRecognizer:tap];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:kMRvEKOnboardShownKey]) {
        __weak UIWindow *weakWindow = window;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentOnboarding:weakWindow];
        });
    }
}

- (UIViewController *)topViewControllerForWindow:(UIWindow *)window {
    UIViewController *top = window.rootViewController;
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    return top;
}

- (void)presentOnboarding:(UIWindow *)window {
    if (!window) return;
    UIViewController *top = [self topViewControllerForWindow:window];
    if (!top) return;

    MRvEKConnectViewController *vc = [[MRvEKConnectViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [top presentViewController:vc animated:YES completion:nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMRvEKOnboardShownKey];
}

- (void)handleSecretTap:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateRecognized) return;
    UIWindow *window = (UIWindow *)recognizer.view;
    UIViewController *top = [self topViewControllerForWindow:window];
    if (!top || [top isKindOfClass:[MRvEKBoardViewController class]]) {
        return;
    }
    MRvEKBoardViewController *vc = [[MRvEKBoardViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [top presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

#pragma mark - Load-time swizzle

__attribute__((constructor))
static void MRvEKUplinkConstructor(void) {
    @autoreleasepool {
        Class cls = [UIWindow class];
        SEL originalSel = @selector(makeKeyAndVisible);
        SEL swizzledSel = @selector(mrvek_makeKeyAndVisible);

        Method originalMethod = class_getInstanceMethod(cls, originalSel);
        Method swizzledMethod = class_getInstanceMethod(cls, swizzledSel);
        if (originalMethod && swizzledMethod) {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}
