#import "MRvEKConnectView.h"
#import <sys/utsname.h>

@implementation MRvEKConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.92]; // dim, not opaque — host app stays faintly visible behind it

    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:content];

    [NSLayoutConstraint activateConstraints:@[
        [content.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [content.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32],
        [content.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32],
    ]];

    UILabel *brand = [[UILabel alloc] init];
    brand.translatesAutoresizingMaskIntoConstraints = NO;
    brand.text = @"piracy.digital";
    brand.textColor = [UIColor whiteColor];
    brand.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    brand.textAlignment = NSTextAlignmentCenter;
    [content addSubview:brand];

    UILabel *glyph = [[UILabel alloc] init];
    glyph.translatesAutoresizingMaskIntoConstraints = NO;
    glyph.text = @"◇";
    glyph.textColor = [UIColor whiteColor];
    glyph.font = [UIFont systemFontOfSize:64];
    glyph.textAlignment = NSTextAlignmentCenter;
    [content addSubview:glyph];

    UILabel *name = [[UILabel alloc] init];
    name.translatesAutoresizingMaskIntoConstraints = NO;
    name.text = @"Mrzefv";
    name.textColor = [UIColor colorWithRed:1.0 green:0.03 blue:0.08 alpha:1.0];
    name.font = [UIFont systemFontOfSize:27 weight:UIFontWeightBold];
    name.textAlignment = NSTextAlignmentCenter;
    [content addSubview:name];

    UILabel *status = [[UILabel alloc] init];
    status.translatesAutoresizingMaskIntoConstraints = NO;
    status.text = @"ONBOARDING SUCCESSFUL";
    status.textColor = [UIColor colorWithRed:0.30 green:1.0 blue:0.45 alpha:1.0];
    status.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    status.textAlignment = NSTextAlignmentCenter;
    [content addSubview:status];

    UILabel *hint = [[UILabel alloc] init];
    hint.translatesAutoresizingMaskIntoConstraints = NO;
    hint.text = @"Two-finger tap anywhere for developer menu";
    hint.textColor = [UIColor grayColor];
    hint.font = [UIFont systemFontOfSize:13];
    hint.textAlignment = NSTextAlignmentCenter;
    [content addSubview:hint];

    UIView *divider = [[UIView alloc] init];
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    divider.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    [content addSubview:divider];

    [NSLayoutConstraint activateConstraints:@[
        [brand.topAnchor constraintEqualToAnchor:content.topAnchor],
        [brand.centerXAnchor constraintEqualToAnchor:content.centerXAnchor],

        [glyph.topAnchor constraintEqualToAnchor:brand.bottomAnchor constant:20],
        [glyph.centerXAnchor constraintEqualToAnchor:content.centerXAnchor],

        [name.topAnchor constraintEqualToAnchor:glyph.bottomAnchor constant:4],
        [name.centerXAnchor constraintEqualToAnchor:content.centerXAnchor],

        [status.topAnchor constraintEqualToAnchor:name.bottomAnchor constant:10],
        [status.centerXAnchor constraintEqualToAnchor:content.centerXAnchor],

        [hint.topAnchor constraintEqualToAnchor:status.bottomAnchor constant:10],
        [hint.centerXAnchor constraintEqualToAnchor:content.centerXAnchor],

        [divider.topAnchor constraintEqualToAnchor:hint.bottomAnchor constant:20],
        [divider.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
        [divider.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
        [divider.heightAnchor constraintEqualToConstant:1],
    ]];

    NSArray<NSArray<NSString *> *> *rows = @[
        @[@"Device", [self deviceModel]],
        @[@"System", [self systemVersion]],
        @[@"Arch", [self architecture]],
        @[@"Session", [self sessionID]],
    ];

    UIView *lastView = divider;
    BOOL first = YES;
    for (NSArray<NSString *> *row in rows) {
        UIView *rowView = [self rowViewWithLabel:row[0] value:row[1]];
        rowView.translatesAutoresizingMaskIntoConstraints = NO;
        [content addSubview:rowView];
        [NSLayoutConstraint activateConstraints:@[
            [rowView.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:(first ? 20 : 12)],
            [rowView.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
            [rowView.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
        ]];
        lastView = rowView;
        first = NO;
    }

    UILabel *footer = [[UILabel alloc] init];
    footer.translatesAutoresizingMaskIntoConstraints = NO;
    footer.text = @"Local overlay only — nothing leaves this device. Tap to continue.";
    footer.textColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    footer.font = [UIFont systemFontOfSize:11];
    footer.textAlignment = NSTextAlignmentCenter;
    footer.numberOfLines = 0;
    [content addSubview:footer];

    [NSLayoutConstraint activateConstraints:@[
        [footer.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:24],
        [footer.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
        [footer.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
        [footer.bottomAnchor constraintEqualToAnchor:content.bottomAnchor],
    ]];

    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelf)];
    [self.view addGestureRecognizer:dismissTap];

    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf dismissSelf];
    });
}

- (UIView *)rowViewWithLabel:(NSString *)label value:(NSString *)value {
    UIView *row = [[UIView alloc] init];

    UILabel *labelView = [[UILabel alloc] init];
    labelView.translatesAutoresizingMaskIntoConstraints = NO;
    labelView.text = [label uppercaseString];
    labelView.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    labelView.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    [row addSubview:labelView];

    UILabel *valueView = [[UILabel alloc] init];
    valueView.translatesAutoresizingMaskIntoConstraints = NO;
    valueView.text = value;
    valueView.textColor = [UIColor whiteColor];
    valueView.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightMedium];
    valueView.textAlignment = NSTextAlignmentRight;
    [row addSubview:valueView];

    [NSLayoutConstraint activateConstraints:@[
        [labelView.leadingAnchor constraintEqualToAnchor:row.leadingAnchor],
        [labelView.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [valueView.trailingAnchor constraintEqualToAnchor:row.trailingAnchor],
        [valueView.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [valueView.leadingAnchor constraintGreaterThanOrEqualToAnchor:labelView.trailingAnchor constant:8],
        [row.heightAnchor constraintEqualToConstant:18],
    ]];

    return row;
}

- (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *code = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return code ?: @"iPhone";
}

- (NSString *)systemVersion {
    return [NSString stringWithFormat:@"iOS %@", [UIDevice currentDevice].systemVersion];
}

- (NSString *)architecture {
#if defined(__arm64e__)
    return @"arm64e";
#elif defined(__arm64__)
    return @"arm64";
#else
    return @"unknown";
#endif
}

- (NSString *)sessionID {
    static NSString *sessionID;
    if (!sessionID) {
        sessionID = [[[NSUUID UUID] UUIDString] substringToIndex:8];
    }
    return sessionID;
}

- (void)dismissSelf {
    if (self.isBeingDismissed || self.presentingViewController == nil) {
        return; // already gone — tap and the 5s timer can both fire
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
