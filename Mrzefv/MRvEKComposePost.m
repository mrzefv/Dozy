#import "MRvEKComposePost.h"
#import "MRvEKLocalPosts.h"
#import "MRvEKIdentity.h"

@interface MRvEKComposePostViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextView *bodyView;
@end

@implementation MRvEKComposePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.92];
    [self buildHeader];
    [self buildForm];
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

    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = @"📌 New Post";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightBold];
    [header addSubview:title];

    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    cancel.translatesAutoresizingMaskIntoConstraints = NO;
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    cancel.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    cancel.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancel addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:cancel];

    UIView *line = [[UIView alloc] init];
    line.translatesAutoresizingMaskIntoConstraints = NO;
    line.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
    [header addSubview:line];

    [NSLayoutConstraint activateConstraints:@[
        [title.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [title.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [cancel.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-16],
        [cancel.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [line.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [line.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [line.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [line.heightAnchor constraintEqualToConstant:1],
    ]];
}

- (void)buildForm {
    UIColor *accent = [UIColor colorWithRed:0.35 green:0.85 blue:0.75 alpha:1.0];

    UILabel *mdidLabel = [[UILabel alloc] init];
    mdidLabel.translatesAutoresizingMaskIntoConstraints = NO;
    mdidLabel.text = [NSString stringWithFormat:@"Posting as %@", [MRvEKIdentity localMDID]];
    mdidLabel.textColor = accent;
    mdidLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    [self.view addSubview:mdidLabel];

    self.titleField = [[UITextField alloc] init];
    self.titleField.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleField.textColor = [UIColor whiteColor];
    self.titleField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.titleField.attributedPlaceholder = [[NSAttributedString alloc]
        initWithString:@"Title"
        attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.35]}];
    self.titleField.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.titleField.layer.cornerRadius = 8;
    self.titleField.delegate = self;
    UIView *titlePad = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    self.titleField.leftView = titlePad;
    self.titleField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:self.titleField];

    self.bodyView = [[UITextView alloc] init];
    self.bodyView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bodyView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.bodyView.textColor = [UIColor whiteColor];
    self.bodyView.font = [UIFont systemFontOfSize:14];
    self.bodyView.layer.cornerRadius = 8;
    self.bodyView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.view addSubview:self.bodyView];

    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeSystem];
    postButton.translatesAutoresizingMaskIntoConstraints = NO;
    [postButton setTitle:@"Post" forState:UIControlStateNormal];
    [postButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    postButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    postButton.backgroundColor = accent;
    postButton.layer.cornerRadius = 10;
    [postButton addTarget:self action:@selector(submitPost) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:postButton];

    UILabel *footnote = [[UILabel alloc] init];
    footnote.translatesAutoresizingMaskIntoConstraints = NO;
    footnote.text = @"Saved on this device only. No account, no server, no sync.";
    footnote.textColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    footnote.font = [UIFont systemFontOfSize:10.5];
    footnote.textAlignment = NSTextAlignmentCenter;
    footnote.numberOfLines = 0;
    [self.view addSubview:footnote];

    [NSLayoutConstraint activateConstraints:@[
        [mdidLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:60],
        [mdidLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],

        [self.titleField.topAnchor constraintEqualToAnchor:mdidLabel.bottomAnchor constant:14],
        [self.titleField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.titleField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.titleField.heightAnchor constraintEqualToConstant:44],

        [self.bodyView.topAnchor constraintEqualToAnchor:self.titleField.bottomAnchor constant:12],
        [self.bodyView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.bodyView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.bodyView.heightAnchor constraintEqualToConstant:160],

        [postButton.topAnchor constraintEqualToAnchor:self.bodyView.bottomAnchor constant:16],
        [postButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [postButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [postButton.heightAnchor constraintEqualToConstant:46],

        [footnote.topAnchor constraintEqualToAnchor:postButton.bottomAnchor constant:14],
        [footnote.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [footnote.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
    ]];
}

- (void)submitPost {
    NSString *title = self.titleField.text ?: @"";
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([title stringByTrimmingCharactersInSet:whitespace].length == 0) {
        [self.titleField becomeFirstResponder];
        return;
    }
    [MRvEKLocalPosts addPostWithTitle:title body:self.bodyView.text ?: @""];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
