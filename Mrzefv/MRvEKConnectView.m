#import "MRvEKConnectView.h"
#import <QuartzCore/QuartzCore.h>
#import <sys/utsname.h>

@implementation MRvEKConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:content];

    [NSLayoutConstraint activateConstraints:@[
        [content.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [content.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32],
        [content.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32],
    ]];

    UIColor *accent = [UIColor colorWithRed:0.35 green:0.85 blue:0.75 alpha:1.0];

    // Original mark: a simple drawn diamond, not any third-party logo.
    UIView *markView = [[UIView alloc] init];
    markView.translatesAutoresizingMaskIntoConstraints = NO;
    [content addSubview:markView];

    CGFloat markSize = 56;
    [NSLayoutConstraint activateConstraints:@[
        [markView.topAnchor constraintEqualToAnchor:content.topAnchor],
        [markView.centerXAnchor constraintEqualToAnchor:content.centerXAnchor],
        [markView.widthAnchor constraintEqualToConstant:markSize],
        [markView.heightAnchor constraintEqualToConstant:markSize],
    ]];

    CAShapeLayer *diamond = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(markSize / 2, 0)];
    [path addLineToPoint:CGPointMake(markSize, markSize / 2)];
    [path addLineToPoint:CGPointMake(markSize / 2, markSize)];
    [path addLineToPoint:CGPointMake(0, markSize / 2)];
    [path closePath];
    diamond.path = path.CGPath;
    diamond.strokeColor = accent.CGColor;
    diamond.fillColor = [UIColor clearColor].CGColor;
    diamond.lineWidth = 2.0;
    diamond.frame = CGRectMake(0, 0, markSize, markSize);
    [markView.layer addSublayer:diamond];

    UILabel *wordmark = [[UILabel alloc] init];
    wordmark.translatesAutoresizingMaskIntoConstraints = NO;
    wordmark.text = @"MRvEK";
    wordmark.textColor = [UIColor whiteColor];
    wordmark.font = [UIFont monospacedSystemFontOfSize:24 weight:UIFontWeightBold];
    wordmark.textAlignment = NSTextAlignmentCenter;
    [content addSubview:wordmark];

    [NSLayoutConstraint activateConstraints:@[
        [wordmark.topAnchor constraintEqualToAnchor:markView.bottomAnchor constant:16],
        [wordmark.centerXAnchor constraintEqualToAnchor:content.centerXAnchor],
    ]];

    UILabel *status = [[UILabel alloc] init];
    status.translatesAutoresizingMaskIntoConstraints = NO;
    status.text = @"CONNECTED";
    status.textColor = accent;
    status.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightSemibold];
    status.textAlignment = NSTextAlignmentCenter;
    [content addSubview:status];

    [NSLayoutConstraint activateConstraints:@[
        [status.topAnchor constraintEqualToAnchor:wordmark.bottomAnchor constant:6],
        [status.centerXAnchor constraintEqualToAnchor:content.centerXAnchor],
    ]];

    UIView *divider = [[UIView alloc] init];
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    divider.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    [content addSubview:divider];

    [NSLayoutConstraint activateConstraints:@[
        [divider.topAnchor constraintEqualToAnchor:status.bottomAnchor constant:20],
        [divider.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
        [divider.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
        [divider.heightAnchor constraintEqualToConstant:1],
    ]];

    // Local device info only — this is the host device's own info, not a
    // remote target's.
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

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissSelf];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
