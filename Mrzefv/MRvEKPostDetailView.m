#import "MRvEKPostDetailView.h"

@interface MRvEKPostDetailViewController ()
@property (nonatomic, copy) NSString *postTitle;
@property (nonatomic, copy) NSString *postBody;
@end

@implementation MRvEKPostDetailViewController

- (instancetype)initWithTitle:(NSString *)title body:(NSString *)body {
    self = [super init];
    if (self) {
        _postTitle = [title copy];
        _postBody = [body copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.92]; // dim, not opaque
    [self buildHeader];
    [self buildBody];
}

- (void)buildHeader {
    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.backgroundColor = [UIColor clearColor];
    [self.view addSubview:header];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:44],
    ]];

    UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
    back.translatesAutoresizingMaskIntoConstraints = NO;
    [back setTitle:@"← Back" forState:UIControlStateNormal];
    back.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    back.titleLabel.font = [UIFont systemFontOfSize:13];
    [back addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:back];

    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
    [header addSubview:bottomLine];

    [NSLayoutConstraint activateConstraints:@[
        [back.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [back.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],

        [bottomLine.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [bottomLine.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [bottomLine.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [bottomLine.heightAnchor constraintEqualToConstant:1],
    ]];
}

- (void)buildBody {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];

    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:44],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:content];

    [NSLayoutConstraint activateConstraints:@[
        [content.topAnchor constraintEqualToAnchor:scroll.topAnchor constant:20],
        [content.leadingAnchor constraintEqualToAnchor:scroll.leadingAnchor constant:20],
        [content.trailingAnchor constraintEqualToAnchor:scroll.trailingAnchor constant:-20],
        [content.bottomAnchor constraintEqualToAnchor:scroll.bottomAnchor constant:-30],
        [content.widthAnchor constraintEqualToAnchor:scroll.widthAnchor constant:-40],
    ]];

    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = self.postTitle;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    title.numberOfLines = 0;
    [content addSubview:title];

    UILabel *body = [[UILabel alloc] init];
    body.translatesAutoresizingMaskIntoConstraints = NO;
    body.text = self.postBody;
    body.textColor = [UIColor colorWithWhite:1.0 alpha:0.75];
    body.font = [UIFont systemFontOfSize:14];
    body.numberOfLines = 0;
    [content addSubview:body];

    [NSLayoutConstraint activateConstraints:@[
        [title.topAnchor constraintEqualToAnchor:content.topAnchor],
        [title.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
        [title.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],

        [body.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:14],
        [body.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
        [body.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
        [body.bottomAnchor constraintEqualToAnchor:content.bottomAnchor],
    ]];
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
