#import "MRvEKPostDetailView.h"
#import "MRvEKLocalPosts.h"

@interface MRvEKPostDetailViewController ()
@property (nonatomic, copy) NSString *postTitle;
@property (nonatomic, copy) NSString *postBody;
@property (nonatomic, copy) NSString *attachmentFilename;
@end

@implementation MRvEKPostDetailViewController

- (instancetype)initWithTitle:(NSString *)title body:(NSString *)body {
    return [self initWithTitle:title body:body attachmentFilename:nil];
}

- (instancetype)initWithTitle:(NSString *)title
                          body:(NSString *)body
            attachmentFilename:(NSString *)attachmentFilename {
    self = [super init];
    if (self) {
        _postTitle = [title copy];
        _postBody = [body copy];
        _attachmentFilename = [attachmentFilename copy];
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
    ]];

    UIView *lastView = body;

    if (self.attachmentFilename.length > 0) {
        NSString *path = [[MRvEKLocalPosts attachmentsDirectory] stringByAppendingPathComponent:self.attachmentFilename];
        UIImage *image = [UIImage imageWithContentsOfFile:path];

        if (image) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.image = image;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.layer.cornerRadius = 10;
            imageView.layer.masksToBounds = YES;
            imageView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
            [content addSubview:imageView];

            CGFloat aspect = image.size.height / MAX(image.size.width, 1);
            [NSLayoutConstraint activateConstraints:@[
                [imageView.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:18],
                [imageView.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
                [imageView.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
                [imageView.heightAnchor constraintEqualToAnchor:imageView.widthAnchor multiplier:MIN(aspect, 1.3)],
            ]];
            lastView = imageView;
        } else {
            UIButton *fileRow = [UIButton buttonWithType:UIButtonTypeSystem];
            fileRow.translatesAutoresizingMaskIntoConstraints = NO;
            [fileRow setTitle:[NSString stringWithFormat:@"📎  %@ — Share / Save", self.attachmentFilename]
                     forState:UIControlStateNormal];
            fileRow.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            fileRow.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
            fileRow.tintColor = [UIColor colorWithWhite:1.0 alpha:0.75];
            fileRow.titleLabel.font = [UIFont systemFontOfSize:13];
            fileRow.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
            fileRow.layer.cornerRadius = 8;
            [fileRow addTarget:self action:@selector(shareAttachment) forControlEvents:UIControlEventTouchUpInside];
            [content addSubview:fileRow];

            [NSLayoutConstraint activateConstraints:@[
                [fileRow.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:18],
                [fileRow.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
                [fileRow.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
                [fileRow.heightAnchor constraintEqualToConstant:44],
            ]];
            lastView = fileRow;
        }
    }

    [lastView.bottomAnchor constraintEqualToAnchor:content.bottomAnchor].active = YES;
}

- (void)shareAttachment {
    if (self.attachmentFilename.length == 0) return;
    NSString *path = [[MRvEKLocalPosts attachmentsDirectory] stringByAppendingPathComponent:self.attachmentFilename];
    NSURL *url = [NSURL fileURLWithPath:path];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[url]
                                                                              applicationActivities:nil];
    [self presentViewController:activity animated:YES completion:nil];
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
