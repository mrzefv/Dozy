#import "MRvEKComposePost.h"
#import "MRvEKLocalPosts.h"
#import "MRvEKIdentity.h"
#import <PhotosUI/PhotosUI.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface MRvEKComposePostViewController () <UITextFieldDelegate, PHPickerViewControllerDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextView *bodyView;
@property (nonatomic, strong) UIButton *attachButton;
@property (nonatomic, copy) NSString *attachmentFilename; // filename only, lives in MRvEKLocalPosts.attachmentsDirectory
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

    self.attachButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.attachButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self setAttachButtonIdleTitle];
    self.attachButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.attachButton.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.attachButton.titleLabel.font = [UIFont systemFontOfSize:12.5];
    self.attachButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    self.attachButton.layer.cornerRadius = 8;
    self.attachButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    [self.attachButton addTarget:self action:@selector(showAttachOptions) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.attachButton];

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
        [self.bodyView.heightAnchor constraintEqualToConstant:140],

        [self.attachButton.topAnchor constraintEqualToAnchor:self.bodyView.bottomAnchor constant:10],
        [self.attachButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.attachButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.attachButton.heightAnchor constraintEqualToConstant:38],

        [postButton.topAnchor constraintEqualToAnchor:self.attachButton.bottomAnchor constant:16],
        [postButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [postButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [postButton.heightAnchor constraintEqualToConstant:46],

        [footnote.topAnchor constraintEqualToAnchor:postButton.bottomAnchor constant:14],
        [footnote.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [footnote.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
    ]];
}

- (void)setAttachButtonIdleTitle {
    [self.attachButton setTitle:@"📎  Attach a photo or file (optional)" forState:UIControlStateNormal];
}

#pragma mark - Attach flow

- (void)showAttachOptions {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil
                                                                     message:nil
                                                              preferredStyle:UIAlertControllerStyleActionSheet];

    [sheet addAction:[UIAlertAction actionWithTitle:@"Photo"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        [self presentPhotoPicker];
    }]];

    [sheet addAction:[UIAlertAction actionWithTitle:@"File"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        [self presentFilePicker];
    }]];

    if (self.attachmentFilename.length > 0) {
        [sheet addAction:[UIAlertAction actionWithTitle:@"Remove Attachment"
                                                   style:UIAlertActionStyleDestructive
                                                 handler:^(UIAlertAction *action) {
            self.attachmentFilename = nil;
            [self setAttachButtonIdleTitle];
        }]];
    }

    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    sheet.popoverPresentationController.sourceView = self.attachButton;
    sheet.popoverPresentationController.sourceRect = self.attachButton.bounds;

    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)presentPhotoPicker {
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
    config.filter = [PHPickerFilter imagesFilter];
    config.selectionLimit = 1;
    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:config];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)presentFilePicker {
    UIDocumentPickerViewController *picker =
        [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeItem]];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)saveAttachmentData:(NSData *)data suggestedName:(NSString *)suggestedName {
    if (!data) return;
    NSString *safeName = [NSString stringWithFormat:@"%@-%@",
                           [[NSUUID UUID] UUIDString],
                           suggestedName.length > 0 ? suggestedName : @"attachment"];
    NSString *path = [[MRvEKLocalPosts attachmentsDirectory] stringByAppendingPathComponent:safeName];
    if ([data writeToFile:path atomically:YES]) {
        self.attachmentFilename = safeName;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.attachButton setTitle:[NSString stringWithFormat:@"📎  %@ — tap to change", safeName]
                                forState:UIControlStateNormal];
        });
    }
}

#pragma mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (results.count == 0) return;

    NSItemProvider *provider = results.firstObject.itemProvider;
    if (![provider canLoadObjectOfClass:[UIImage class]]) return;

    [provider loadObjectOfClass:[UIImage class] completionHandler:^(UIImage *image, NSError *error) {
        if (!image) return;
        NSData *jpegData = UIImageJPEGRepresentation(image, 0.8);
        [self saveAttachmentData:jpegData suggestedName:@"photo.jpg"];
    }];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller
didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) return;
    NSURL *url = urls.firstObject;

    BOOL accessing = [url startAccessingSecurityScopedResource];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (accessing) {
        [url stopAccessingSecurityScopedResource];
    }
    [self saveAttachmentData:data suggestedName:url.lastPathComponent];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // no-op
}

#pragma mark - Submit

- (void)submitPost {
    NSString *title = self.titleField.text ?: @"";
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([title stringByTrimmingCharactersInSet:whitespace].length == 0) {
        [self.titleField becomeFirstResponder];
        return;
    }
    [MRvEKLocalPosts addPostWithTitle:title
                                  body:self.bodyView.text ?: @""
                    attachmentFilename:self.attachmentFilename];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
