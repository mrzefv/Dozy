#import "MRvEKBoardView.h"
#import "MRvEKPostDetailView.h"
#import "MRvEKIdentity.h"
#import "MRvEKFileTransfer.h"
#import "MRvEKLocalPosts.h"
#import "MRvEKComposePost.h"

@interface MRvEKBoardEntry : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
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
@property (nonatomic, strong) UIView *countRow;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<MRvEKBoardEntry *> *entries;
@property (nonatomic, strong) NSArray<MRvEKLocalPost *> *localPosts;
@end

@implementation MRvEKBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.92]; // dim, not opaque
    [self buildEntries];
    self.localPosts = [MRvEKLocalPosts allPosts];
    [self buildHeader];
    [self buildHero];
    [self buildSearchBar];
    [self buildCountRow];
    [self buildTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Picks up anything posted while a compose sheet was on top of this screen.
    self.localPosts = [MRvEKLocalPosts allPosts];
    [self.tableView reloadData];
}

// Real posts, real (original-written) content, mock comment/view counts
// for visual weight only — nothing here is tracked or fetched.
- (void)buildEntries {
    NSArray<NSArray<NSString *> *> *seed = @[
        @[@"IPA.FARM — Broken Apps List",
          @"Resigned and sideloaded IPAs break for two main reasons: your signing cert gets revoked (Apple pulls free 7-day certs constantly, paid dev certs less often), or the app's own backend changes and stops talking to an old build. Before resigning something that's stopped working, check whether it's a cert issue (reinstall fixes it) or a backend issue (a fresh IPA is the only fix). Keeping a personal changelog of what version and source worked saves a lot of repeat troubleshooting."],
        @[@"AltStore Alternatives (IPA)",
          @"AltStore isn't the only way in. SideStore drops the AltServer companion app and refreshes over a local VPN tunnel instead — same 7-day free-cert cycle, no desktop needed. TrollStore signs apps permanently but only works on vulnerable firmware versions, so it's not an option on every device. Feather and Scarlet are newer on-device signers built around the same free-cert idea as AltStore. Sideloadly is the desktop route if you'd rather sign from a Mac or PC. All of them hit the same wall eventually: Apple's cert limits, not the tool."],
        @[@"IPA Signing Guide",
          @"iOS won't run an app unless its binary is signed with a valid certificate and matching provisioning profile. A free Apple ID gets you a 7-day cert and a 3-app limit; a paid developer account gets a year and up to 100 apps. Re-signing tools like zsign or AltSign don't rebuild the app — they swap in your entitlements and provisioning profile, then re-sign the binary so it matches. Rough flow: get the IPA, get a valid cert and profile, run it through a signer, install via your sideloading tool of choice."],
        @[@"Sideload IPA — Best Practices",
          @"Only pull IPAs from sources you actually trust — a repacked binary can carry anything. Keep a local copy of anything you've signed, since a revocation means resigning from scratch, not just reinstalling. Check what entitlements an IPA is asking for before you sign it; a simple utility app doesn't need background location or contacts access. And plan for revocation — it's a \"when,\" not an \"if,\" with free certs especially, so don't build a workflow that assumes today's install lasts forever."],
    ];

    NSMutableArray<MRvEKBoardEntry *> *entries = [NSMutableArray array];
    for (NSArray<NSString *> *row in seed) {
        MRvEKBoardEntry *entry = [[MRvEKBoardEntry alloc] init];
        entry.title = row[0];
        entry.body = row[1];
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
    header.backgroundColor = [UIColor clearColor]; // shows through to the dimmed view behind it
    [self.view addSubview:header];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:44],
    ]];

    UILabel *menuIcon = [[UILabel alloc] init];
    menuIcon.translatesAutoresizingMaskIntoConstraints = NO;
    menuIcon.text = @"☰";
    menuIcon.textColor = [UIColor colorWithWhite:1.0 alpha:0.55];
    menuIcon.font = [UIFont systemFontOfSize:15];
    [header addSubview:menuIcon];

    UILabel *word = [[UILabel alloc] init];
    word.translatesAutoresizingMaskIntoConstraints = NO;
    word.text = @"📌 Mrzefv // Pinned";
    word.textColor = [UIColor whiteColor];
    word.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightBold];
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

    UIButton *login = [UIButton buttonWithType:UIButtonTypeSystem];
    login.translatesAutoresizingMaskIntoConstraints = NO;
    [login setTitle:@"Login" forState:UIControlStateNormal];
    login.tintColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    login.titleLabel.font = [UIFont systemFontOfSize:12];
    [login addTarget:self action:@selector(showLoginInfo) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:login];

    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
    [header addSubview:bottomLine];

    [NSLayoutConstraint activateConstraints:@[
        [menuIcon.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [menuIcon.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],

        [word.leadingAnchor constraintEqualToAnchor:menuIcon.trailingAnchor constant:10],
        [word.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],

        [close.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-16],
        [close.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],

        [login.trailingAnchor constraintEqualToAnchor:close.leadingAnchor constant:-14],
        [login.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],

        [more.trailingAnchor constraintEqualToAnchor:login.leadingAnchor constant:-14],
        [more.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],

        [bottomLine.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [bottomLine.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [bottomLine.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [bottomLine.heightAnchor constraintEqualToConstant:1],
    ]];

    self.headerView = header;
}

- (void)buildHero {
    UIView *hero = [[UIView alloc] init];
    hero.translatesAutoresizingMaskIntoConstraints = NO;
    hero.backgroundColor = [UIColor clearColor];
    [self.view addSubview:hero];

    UIColor *accent = [UIColor colorWithRed:0.35 green:0.85 blue:0.75 alpha:1.0];

    UILabel *glyph = [[UILabel alloc] init];
    glyph.translatesAutoresizingMaskIntoConstraints = NO;
    glyph.text = @"💀";
    glyph.textColor = [UIColor whiteColor];
    glyph.font = [UIFont systemFontOfSize:32];
    glyph.textAlignment = NSTextAlignmentCenter;
    [hero addSubview:glyph];

    UILabel *tagline = [[UILabel alloc] init];
    tagline.translatesAutoresizingMaskIntoConstraints = NO;
    tagline.text = @"local board · this device only";
    tagline.textColor = accent;
    tagline.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    tagline.textAlignment = NSTextAlignmentCenter;
    [hero addSubview:tagline];

    UIColor *red = [UIColor colorWithRed:1.0 green:0.03 blue:0.08 alpha:1.0];
    UILabel *stamp = [[UILabel alloc] init];
    stamp.translatesAutoresizingMaskIntoConstraints = NO;
    stamp.text = @"Mrzefv was here";
    stamp.textColor = red;
    stamp.font = [UIFont systemFontOfSize:9 weight:UIFontWeightSemibold];
    stamp.textAlignment = NSTextAlignmentCenter;
    [hero addSubview:stamp];

    [NSLayoutConstraint activateConstraints:@[
        [hero.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
        [hero.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [hero.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [hero.heightAnchor constraintEqualToConstant:92],

        [glyph.topAnchor constraintEqualToAnchor:hero.topAnchor constant:10],
        [glyph.centerXAnchor constraintEqualToAnchor:hero.centerXAnchor],

        [tagline.topAnchor constraintEqualToAnchor:glyph.bottomAnchor constant:4],
        [tagline.centerXAnchor constraintEqualToAnchor:hero.centerXAnchor],

        [stamp.topAnchor constraintEqualToAnchor:tagline.bottomAnchor constant:2],
        [stamp.centerXAnchor constraintEqualToAnchor:hero.centerXAnchor],
    ]];

    self.heroView = hero;
}

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

// Real count of what's actually here — no invented total, no fake
// page count. Currently always "1" since there's only ever one page.
- (void)buildCountRow {
    UIView *row = [[UIView alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:row];

    UILabel *count = [[UILabel alloc] init];
    count.translatesAutoresizingMaskIntoConstraints = NO;
    count.text = [NSString stringWithFormat:@"%lu pinned post%@",
                  (unsigned long)self.entries.count,
                  self.entries.count == 1 ? @"" : @"s"];
    count.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    count.font = [UIFont systemFontOfSize:10.5];
    [row addSubview:count];

    UILabel *pagePill = [[UILabel alloc] init];
    pagePill.translatesAutoresizingMaskIntoConstraints = NO;
    pagePill.text = @"1";
    pagePill.textColor = [UIColor whiteColor];
    pagePill.font = [UIFont systemFontOfSize:10.5];
    pagePill.textAlignment = NSTextAlignmentCenter;
    pagePill.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    pagePill.layer.cornerRadius = 5;
    pagePill.layer.masksToBounds = YES;
    [row addSubview:pagePill];

    [NSLayoutConstraint activateConstraints:@[
        [row.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor constant:8],
        [row.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [row.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [row.heightAnchor constraintEqualToConstant:18],

        [count.leadingAnchor constraintEqualToAnchor:row.leadingAnchor],
        [count.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],

        [pagePill.trailingAnchor constraintEqualToAnchor:row.trailingAnchor],
        [pagePill.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [pagePill.widthAnchor constraintGreaterThanOrEqualToConstant:20],
        [pagePill.heightAnchor constraintEqualToConstant:18],
    ]];

    self.countRow = row;
}

- (void)buildTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 64;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MRvEKRow"];
    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.countRow.bottomAnchor constant:10],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; // 0 = Pinned (static), 1 = Your Posts (local, MDID-tagged)
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.entries.count : self.localPosts.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"Pinned" : [NSString stringWithFormat:@"Your Posts (%lu)", (unsigned long)self.localPosts.count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    label.text = [[self tableView:tableView titleForHeaderInSection:section] uppercaseString];
    label.textColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    label.font = [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];
    label.frame = CGRectMake(16, 8, tableView.bounds.size.width - 32, 20);

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 34)];
    container.backgroundColor = [UIColor clearColor];
    [container addSubview:label];
    return container;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 34;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self pinnedCellForTableView:tableView indexPath:indexPath];
    }
    return [self localPostCellForTableView:tableView indexPath:indexPath];
}

- (UITableViewCell *)pinnedCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MRvEKRow" forIndexPath:indexPath];
    // Pinned tint uses your own red (same value as the "Mrzefv" wordmark),
    // not doxbin's — every row here is pinned, so all of them get it.
    cell.backgroundColor = [UIColor colorWithRed:0.20 green:0.03 blue:0.05 alpha:0.97]; // readable first, dim second
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

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

- (UITableViewCell *)localPostCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MRvEKRow" forIndexPath:indexPath];
    // No fake stats here — these are real, locally-created posts.
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    for (UIView *sub in cell.contentView.subviews) {
        [sub removeFromSuperview];
    }

    MRvEKLocalPost *post = self.localPosts[indexPath.row];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM d, h:mm a";

    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = post.title;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    title.numberOfLines = 0;
    [cell.contentView addSubview:title];

    UILabel *stats = [[UILabel alloc] init];
    stats.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *clip = post.attachmentFilename.length > 0 ? @"📎 " : @"";
    stats.text = [NSString stringWithFormat:@"%@by %@ · %@", clip, post.authorMDID, [formatter stringFromDate:post.createdAt]];
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

    if (indexPath.section == 0) {
        MRvEKBoardEntry *entry = self.entries[indexPath.row];
        MRvEKPostDetailViewController *detail =
            [[MRvEKPostDetailViewController alloc] initWithTitle:entry.title body:entry.body];
        detail.modalPresentationStyle = UIModalPresentationOverFullScreen;
        detail.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:detail animated:YES completion:nil];
    } else {
        MRvEKLocalPost *post = self.localPosts[indexPath.row];
        MRvEKPostDetailViewController *detail =
            [[MRvEKPostDetailViewController alloc] initWithTitle:post.title
                                                              body:post.body
                                                attachmentFilename:post.attachmentFilename];
        detail.modalPresentationStyle = UIModalPresentationOverFullScreen;
        detail.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:detail animated:YES completion:nil];
    }
}

#pragma mark - Dev menu

- (void)showDevMenu {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"Mrzefv"
                                                                    message:@"Developer / local-device tools"
                                                             preferredStyle:UIAlertControllerStyleActionSheet];

    [menu addAction:[UIAlertAction actionWithTitle:@"Local P2P"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        UIAlertController *soon = [UIAlertController alertControllerWithTitle:@"Local P2P"
                                                                        message:@"Coming soon — local peer-to-peer signing and install. No backend. Not built yet."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        [soon addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:soon animated:YES completion:nil];
    }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"File Transfer"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        MRvEKFileTransferViewController *vc = [[MRvEKFileTransferViewController alloc] init];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:vc animated:YES completion:nil];
    }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"New Post"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        MRvEKComposePostViewController *vc = [[MRvEKComposePostViewController alloc] init];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:vc animated:YES completion:nil];
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

- (void)showLoginInfo {
    NSString *mdid = [MRvEKIdentity localMDID];
    NSString *message = [NSString stringWithFormat:
        @"No accounts, no server — just a local device ID, generated once and kept in Keychain, same pattern as the signer app.\n\nMDID: %@",
        mdid];
    UIAlertController *info = [UIAlertController alertControllerWithTitle:@"Local Identity"
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [info addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:info animated:YES completion:nil];
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
