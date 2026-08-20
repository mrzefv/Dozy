#import "MRvEKBoardView.h"

@interface MRvEKBoardEntry : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *dateLabel;
@property (nonatomic, assign) NSInteger comments;
@property (nonatomic, assign) NSInteger views;
@end

@implementation MRvEKBoardEntry
@end

@interface MRvEKBoardViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *heroView;
@property (nonatomic, strong) UIView *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<MRvEKBoardEntry *> *entries;
@end

@implementation MRvEKBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self buildEntries];
    [self buildHeader];
    [self buildHero];
    [self buildSearchBar];
    [self buildTableView];
}

// Real pinned-post titles, with mock comment/view counts for visual
// weight only — nothing here is tracked or fetched from anywhere.
- (void)buildEntries {
    NSArray<NSString *> *titles = @[
        @"IPA.FARM — Broken Apps List",
        @"AltStore Alternatives (IPA)",
        @"IPA Signing Guide",
        @"Sideload IPA — Best Practices",
    ];

    NSMutableArray<MRvEKBoardEntry *> *entries = [NSMutableArray array];
    for (NSString *title in titles) {
        MRvEKBoardEntry *entry = [[MRvEKBoardEntry alloc] init];
        entry.title = title;
        entry.dateLabel = @"Pinned";
        entry.comments = arc4random_uniform(4);
        entry.views = arc4random_uniform(50) + 8;
        [entries addObject:entry];
    }
    self.entries = entries;
}

- (void)buildHeader {
    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.backgroundColor = [UIColor blackColor];
    [self.view addSubview:header];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:44],
    ]];

    UILabel *word = [[UILabel alloc] init];
    word.translatesAutoresizingMaskIntoConstraints = NO;
    word.text = @"Mrzefv // Pinned Posts";
    word.textColor = [UIColor whiteColor];
    word.font = [UIFont monospacedSystemFontOfSize:15 weight:UIFontWeightBold];
    [header addSubview:word];

    UIButton *more = [UIButton buttonWithType:UIButtonTypeSystem];
    more.translatesAutoresizingMaskIntoConstraints = NO;
    [more setTitle:@"⋯" forState:UIControlStateNormal];
    more.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    more.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    [more addTarget:self action:@selector(showDevMenu) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:more];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.translatesAutoresizingMaskIntoConstraints = NO;
    [close setTitle:@"Close" forState:UIControlStateNormal];
    close.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    close.titleLabel.font = [UIFont systemFontOfSize:13];
    [close addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:close];

    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
    [header addSubview:bottomLine];

    [NSLayoutConstraint activateConstraints:@[
        [word.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [word.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],

        [close.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-16],
        [close.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],

        [more.trailingAnchor constraintEqualToAnchor:close.leadingAnchor constant:-16],
        [more.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],

        [bottomLine.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [bottomLine.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [bottomLine.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [bottomLine.heightAnchor constraintEqualToConstant:1],
    ]];

    self.headerView = header;
}

// Small original mark + tagline — structural echo of a hero banner,
// none of the actual doxbin branding.
- (void)buildHero {
    UIView *hero = [[UIView alloc] init];
    hero.translatesAutoresizingMaskIntoConstraints = NO;
    hero.backgroundColor = [UIColor blackColor];
    [self.view addSubview:hero];

    UIColor *accent = [UIColor colorWithRed:0.35 green:0.85 blue:0.75 alpha:1.0];

    UILabel *glyph = [[UILabel alloc] init];
    glyph.translatesAutoresizingMaskIntoConstraints = NO;
    glyph.text = @"◇";
    glyph.textColor = [UIColor whiteColor];
    glyph.font = [UIFont systemFontOfSize:30];
    glyph.textAlignment = NSTextAlignmentCenter;
    [hero addSubview:glyph];

    UILabel *tagline = [[UILabel alloc] init];
    tagline.translatesAutoresizingMaskIntoConstraints = NO;
    tagline.text = @"local board · this device only";
    tagline.textColor = accent;
    tagline.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    tagline.textAlignment = NSTextAlignmentCenter;
    [hero addSubview:tagline];

    [NSLayoutConstraint activateConstraints:@[
        [hero.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
        [hero.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [hero.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [hero.heightAnchor constraintEqualToConstant:76],

        [glyph.topAnchor constraintEqualToAnchor:hero.topAnchor constant:10],
        [glyph.centerXAnchor constraintEqualToAnchor:hero.centerXAnchor],

        [tagline.topAnchor constraintEqualToAnchor:glyph.bottomAnchor constant:4],
        [tagline.centerXAnchor constraintEqualToAnchor:hero.centerXAnchor],
    ]];

    self.heroView = hero;
}

// Decorative only — visual parity with the reference layout, doesn't
// filter anything. Fine to wire up to a real search later if wanted.
- (void)buildSearchBar {
    UIView *bar = [[UIView alloc] init];
    bar.translatesAutoresizingMaskIntoConstraints = NO;
    bar.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    bar.layer.cornerRadius = 8;
    [self.view addSubview:bar];

    UILabel *placeholder = [[UILabel alloc] init];
    placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    placeholder.text = @"Search pinned posts…";
    placeholder.textColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    placeholder.font = [UIFont systemFontOfSize:13];
    [bar addSubview:placeholder];

    [NSLayoutConstraint activateConstraints:@[
        [bar.topAnchor constraintEqualToAnchor:self.heroView.bottomAnchor constant:10],
        [bar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [bar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [bar.heightAnchor constraintEqualToConstant:36],

        [placeholder.leadingAnchor constraintEqualToAnchor:bar.leadingAnchor constant:12],
        [placeholder.centerYAnchor constraintEqualToAnchor:bar.centerYAnchor],
    ]];

    self.searchBar = bar;
}

- (void)buildTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 64;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MRvEKRow"];
    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor constant:12],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MRvEKRow" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    for (UIView *sub in cell.contentView.subviews) {
        [sub removeFromSuperview];
    }

    MRvEKBoardEntry *entry = self.entries[indexPath.row];

    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = entry.title;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    title.numberOfLines = 0;
    [cell.contentView addSubview:title];

    UILabel *stats = [[UILabel alloc] init];
    stats.translatesAutoresizingMaskIntoConstraints = NO;
    stats.text = [NSString stringWithFormat:@"💬 %ld   👁 %ld   %@",
                  (long)entry.comments, (long)entry.views, entry.dateLabel];
    stats.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    stats.font = [UIFont systemFontOfSize:11];
    [cell.contentView addSubview:stats];

    [NSLayoutConstraint activateConstraints:@[
        [title.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [title.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
        [title.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:10],

        [stats.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [stats.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
        [stats.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:4],
        [stats.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-10],
    ]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // UI-only: no detail screen wired up on purpose.
}

#pragma mark - Dev menu

- (void)showDevMenu {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"Mrzefv"
                                                                    message:@"Developer / local-device tools"
                                                             preferredStyle:UIAlertControllerStyleActionSheet];

    [menu addAction:[UIAlertAction actionWithTitle:@"Local P2P"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        NSLog(@"[Mrzefv] Local P2P selected");
    }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"Device Information"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        NSString *message = [NSString stringWithFormat:@"Model: %@\nSystem: %@",
                              UIDevice.currentDevice.model,
                              UIDevice.currentDevice.systemVersion];
        UIAlertController *info = [UIAlertController alertControllerWithTitle:@"Local Device"
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        [info addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:info animated:YES completion:nil];
    }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    menu.popoverPresentationController.sourceView = self.view;
    menu.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width - 40, 60, 1, 1);

    [self presentViewController:menu animated:YES completion:nil];
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
