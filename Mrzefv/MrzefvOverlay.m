#import "MrzefvOverlay.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface MRZHomeController : UIViewController
@end

@implementation MRZHomeController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.blackColor;

    UILabel *brand = [UILabel new];
    brand.text = @"piracy.digital";
    brand.textColor = UIColor.whiteColor;
    brand.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    brand.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *logo = [UILabel new];
    logo.text = @"◇";
    logo.textColor = UIColor.whiteColor;
    logo.font = [UIFont systemFontOfSize:90];
    logo.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *name = [UILabel new];
    name.text = @"Mrzefv";
    name.textColor =
        [UIColor colorWithRed:1.0 green:0.03 blue:0.08 alpha:1.0];
    name.font = [UIFont systemFontOfSize:27 weight:UIFontWeightBold];
    name.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *success = [UILabel new];
    success.text = @"ONBOARDING SUCCESSFUL";
    success.textColor =
        [UIColor colorWithRed:0.30 green:1.0 blue:0.45 alpha:1.0];
    success.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    success.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *hint = [UILabel new];
    hint.text = @"Two-finger tap anywhere for developer menu";
    hint.textColor = UIColor.grayColor;
    hint.font = [UIFont systemFontOfSize:13];
    hint.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *card = [UIView new];
    card.backgroundColor =
        [UIColor colorWithWhite:0.07 alpha:1.0];
    card.layer.cornerRadius = 16;
    card.layer.borderWidth = 1;
    card.layer.borderColor =
        [UIColor colorWithWhite:0.22 alpha:1.0].CGColor;
    card.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *posts = [UILabel new];
    posts.text =
        @"📌  Pinned Posts\n\n"
        @"IPA.FARM — Broken Apps List\n"
        @"AltStore Alternatives (IPA)\n"
        @"IPA Signing Guide\n"
        @"Sideload IPA — Best Practices";

    posts.textColor = UIColor.whiteColor;
    posts.font = [UIFont systemFontOfSize:15];
    posts.numberOfLines = 0;
    posts.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:brand];
    [self.view addSubview:logo];
    [self.view addSubview:name];
    [self.view addSubview:success];
    [self.view addSubview:hint];
    [self.view addSubview:card];

    [card addSubview:posts];

    [NSLayoutConstraint activateConstraints:@[
        [brand.topAnchor
            constraintEqualToAnchor:
                self.view.safeAreaLayoutGuide.topAnchor
            constant:18],
        [brand.centerXAnchor
            constraintEqualToAnchor:self.view.centerXAnchor],

        [logo.topAnchor
            constraintEqualToAnchor:brand.bottomAnchor
            constant:35],
        [logo.centerXAnchor
            constraintEqualToAnchor:self.view.centerXAnchor],

        [name.topAnchor
            constraintEqualToAnchor:logo.bottomAnchor
            constant:6],
        [name.centerXAnchor
            constraintEqualToAnchor:self.view.centerXAnchor],

        [success.topAnchor
            constraintEqualToAnchor:name.bottomAnchor
            constant:12],
        [success.centerXAnchor
            constraintEqualToAnchor:self.view.centerXAnchor],

        [hint.topAnchor
            constraintEqualToAnchor:success.bottomAnchor
            constant:12],
        [hint.centerXAnchor
            constraintEqualToAnchor:self.view.centerXAnchor],

        [card.leadingAnchor
            constraintEqualToAnchor:self.view.leadingAnchor
            constant:22],
        [card.trailingAnchor
            constraintEqualToAnchor:self.view.trailingAnchor
            constant:-22],
        [card.topAnchor
            constraintEqualToAnchor:hint.bottomAnchor
            constant:28],
        [card.heightAnchor
            constraintGreaterThanOrEqualToConstant:220],

        [posts.leadingAnchor
            constraintEqualToAnchor:card.leadingAnchor
            constant:18],
        [posts.trailingAnchor
            constraintEqualToAnchor:card.trailingAnchor
            constant:-18],
        [posts.topAnchor
            constraintEqualToAnchor:card.topAnchor
            constant:18]
    ]];

    UITapGestureRecognizer *secret =
        [[UITapGestureRecognizer alloc]
            initWithTarget:self
            action:@selector(mrzSecretMenu:)];

    secret.numberOfTouchesRequired = 2;
    secret.numberOfTapsRequired = 1;

    [self.view addGestureRecognizer:secret];
}

- (void)mrzSecretMenu:(UITapGestureRecognizer *)gesture
{
    UIAlertController *menu =
        [UIAlertController
            alertControllerWithTitle:@"Mrzefv"
            message:@"Developer / local-device tools"
            preferredStyle:UIAlertControllerStyleActionSheet];

    [menu addAction:
        [UIAlertAction
            actionWithTitle:@"Local P2P"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                NSLog(@"[Mrzefv] Local P2P selected");
            }]];

    [menu addAction:
        [UIAlertAction
            actionWithTitle:@"Device Information"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {

                NSString *message =
                    [NSString stringWithFormat:
                        @"Model: %@\n"
                         "System: %@",
                        UIDevice.currentDevice.model,
                        UIDevice.currentDevice.systemVersion];

                UIAlertController *info =
                    [UIAlertController
                        alertControllerWithTitle:@"Local Device"
                        message:message
                        preferredStyle:UIAlertControllerStyleAlert];

                [info addAction:
                    [UIAlertAction
                        actionWithTitle:@"OK"
                        style:UIAlertActionStyleDefault
                        handler:nil]];

                [self presentViewController:info
                                   animated:YES
                                 completion:nil];
            }]];

    [menu addAction:
        [UIAlertAction
            actionWithTitle:@"Cancel"
            style:UIAlertActionStyleCancel
            handler:nil]];

    [self presentViewController:menu
                       animated:YES
                     completion:nil];
}

@end


static UIWindow *MRZWindow;

void MRZInstallOverlay(void)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (MRZWindow != nil)
            return;

        UIWindowScene *scene = nil;

        for (UIScene *candidate
             in UIApplication.sharedApplication.connectedScenes)
        {
            if ([candidate isKindOfClass:UIWindowScene.class] &&
                candidate.activationState ==
                    UISceneActivationStateForegroundActive)
            {
                scene = (UIWindowScene *)candidate;
                break;
            }
        }

        if (scene == nil)
            return;

        MRZWindow =
            [[UIWindow alloc] initWithWindowScene:scene];

        MRZWindow.windowLevel = UIWindowLevelAlert + 1;
        MRZWindow.backgroundColor = UIColor.clearColor;
        MRZWindow.rootViewController =
            [MRZHomeController new];

        [MRZWindow makeKeyAndVisible];
    });
}
