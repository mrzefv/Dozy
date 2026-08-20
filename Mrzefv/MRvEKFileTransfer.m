#import "MRvEKFileTransfer.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface MRvEKFileTransferViewController () <UIDocumentPickerDelegate>
@end

@implementation MRvEKFileTransferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.92];
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

    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = @"📌 Mrzefv // File Transfer";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightBold];
    [header addSubview:title];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.translatesAutoresizingMaskIntoConstraints = NO;
    [close setTitle:@"Close" forState:UIControlStateNormal];
    close.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    close.titleLabel.font = [UIFont systemFontOfSize:13];
    [close addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:close];

    UIView *line = [[UIView alloc] init];
    line.translatesAutoresizingMaskIntoConstraints = NO;
    line.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
    [header addSubview:line];

    [NSLayoutConstraint activateConstraints:@[
        [title.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [title.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [close.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-16],
        [close.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [line.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [line.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [line.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [line.heightAnchor constraintEqualToConstant:1],
    ]];
}

- (void)buildBody {
    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:content];

    [NSLayoutConstraint activateConstraints:@[
        [content.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-40],
        [content.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:28],
        [content.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-28],
    ]];

    UILabel *desc = [[UILabel alloc] init];
    desc.translatesAutoresizingMaskIntoConstraints = NO;
    desc.text = @"Uses the system file picker — works with any location the Files app can see, including an external drive if it has a Files-compatible driver. One file at a time, not a full browser.";
    desc.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    desc.font = [UIFont systemFontOfSize:12.5];
    desc.textAlignment = NSTextAlignmentCenter;
    desc.numberOfLines = 0;
    [content addSubview:desc];

    UIButton *importBtn = [self actionButtonWithTitle:@"Import File" action:@selector(startImport)];
    UIButton *exportBtn = [self actionButtonWithTitle:@"Export File" action:@selector(startExport)];
    [content addSubview:importBtn];
    [content addSubview:exportBtn];

    [NSLayoutConstraint activateConstraints:@[
        [desc.topAnchor constraintEqualToAnchor:content.topAnchor],
        [desc.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
        [desc.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],

        [importBtn.topAnchor constraintEqualToAnchor:desc.bottomAnchor constant:24],
        [importBtn.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
        [importBtn.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
        [importBtn.heightAnchor constraintEqualToConstant:46],

        [exportBtn.topAnchor constraintEqualToAnchor:importBtn.bottomAnchor constant:12],
        [exportBtn.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
        [exportBtn.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
        [exportBtn.heightAnchor constraintEqualToConstant:46],
        [exportBtn.bottomAnchor constraintEqualToAnchor:content.bottomAnchor],
    ]];
}

- (UIButton *)actionButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    button.backgroundColor = [UIColor colorWithRed:0.35 green:0.85 blue:0.75 alpha:1.0];
    button.layer.cornerRadius = 10;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Import

- (void)startImport {
    NSArray<UTType *> *types = @[UTTypeItem];
    UIDocumentPickerViewController *picker =
        [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:types];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Export

- (void)startExport {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *body = [NSString stringWithFormat:
        @"Dozy board export — %@\n\nIPA.FARM — Broken Apps List\nAltStore Alternatives (IPA)\nIPA Signing Guide\nSideload IPA — Best Practices\n",
        [formatter stringFromDate:[NSDate date]]];

    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"dozy-export.txt"];
    NSError *error = nil;
    [body writeToFile:tempPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [self showAlertWithTitle:@"Export Failed" message:error.localizedDescription];
        return;
    }

    NSURL *fileURL = [NSURL fileURLWithPath:tempPath];
    UIDocumentPickerViewController *picker =
        [[UIDocumentPickerViewController alloc] initForExportingURLs:@[fileURL]];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller
didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) return;
    NSURL *url = urls.firstObject;

    BOOL accessing = [url startAccessingSecurityScopedResource];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    if (accessing) {
        [url stopAccessingSecurityScopedResource];
    }

    if (data) {
        NSString *sizeString = [NSByteCountFormatter stringFromByteCount:data.length
                                                                countStyle:NSByteCountFormatterCountStyleFile];
        [self showAlertWithTitle:@"Imported"
                          message:[NSString stringWithFormat:@"%@\n%@", url.lastPathComponent, sizeString]];
    } else {
        [self showAlertWithTitle:@"Import Failed" message:error.localizedDescription ?: @"Could not read file"];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // no-op
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
