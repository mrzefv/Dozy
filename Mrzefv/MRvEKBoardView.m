#import "MRvEKBoardView.h"

@interface MRvEKBoardEntry : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, assign) NSInteger views;
@end

@implementation MRvEKBoardEntry
@end

@interface MRvEKBoardViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<MRvEKBoardEntry *> *entries;
@end

@implementation MRvEKBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self buildMockEntries];
    [self buildHeader];
    [self buildTableView];
}

// Hardcoded placeholder rows only — no real people, no real backend,
// nothing fetched or uploaded.
- (void)buildMockEntries {
    NSMutableArray<MRvEKBoardEntry *> *entries = [NSMutableArray array];

    NSArray<NSArray<NSString *> *> *seed = @[
        @[@"Welcome", @"root", @"placeholder"],
        @[@"Build Log #1", @"root", @"placeholder"],
        @[@"Sample Entry A", @"guest", @"placeholder"],
        @[@"Sample Entry B", @"guest", @"placeholder"],
        @[@"Notes", @"root", @"placeholder"],
    ];

    for (NSArray<NSString *> *row in seed) {
        MRvEKBoardEntry *entry = [[MRvEKBoardEntry alloc] init];
        entry.title = row[0];
        entry.author = row[1];
        entry.date = row[2];
        entry.views = arc4random_uniform(40) + 1;
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
    word.text = @"MRvEK // LOG";
    word.textColor = [UIColor whiteColor];
    word.font = [UIFont monospacedSystemFontOfSize:15 weight:UIFontWeightBold];
    [header addSubview:word];

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

        [bottomLine.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [bottomLine.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [bottomLine.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [bottomLine.heightAnchor constraintEqualToConstant:1],
    ]];

    self.headerView = header;
}

- (void)buildTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 56;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MRvEKRow"];
    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
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
    title.font = [UIFont monospacedSystemFontOfSize:14 weight:UIFontWeightMedium];
    [cell.contentView addSubview:title];

    UILabel *meta = [[UILabel alloc] init];
    meta.translatesAutoresizingMaskIntoConstraints = NO;
    meta.text = [NSString stringWithFormat:@"%@ · %@ · %ld views", entry.author, entry.date, (long)entry.views];
    meta.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    meta.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    [cell.contentView addSubview:meta];

    [NSLayoutConstraint activateConstraints:@[
        [title.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [title.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
        [title.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:10],

        [meta.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [meta.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
        [meta.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:4],
    ]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // UI-only: no detail screen wired up on purpose.
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
