#import "MRvEKLocalPosts.h"
#import "MRvEKIdentity.h"

static NSString * const kMRvEKLocalPostsKey = @"com.mrvek.uplink.localPosts";

@implementation MRvEKLocalPost
@end

@implementation MRvEKLocalPosts

+ (NSArray<MRvEKLocalPost *> *)allPosts {
    NSArray<NSDictionary *> *raw = [[NSUserDefaults standardUserDefaults] arrayForKey:kMRvEKLocalPostsKey];
    if (raw.count == 0) return @[];

    NSMutableArray<MRvEKLocalPost *> *posts = [NSMutableArray array];
    for (NSDictionary *dict in raw) {
        if (![dict isKindOfClass:[NSDictionary class]]) continue;
        MRvEKLocalPost *post = [[MRvEKLocalPost alloc] init];
        post.title = dict[@"title"] ?: @"";
        post.body = dict[@"body"] ?: @"";
        post.authorMDID = dict[@"authorMDID"] ?: @"";
        NSNumber *timestamp = dict[@"createdAt"];
        post.createdAt = timestamp ? [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue] : [NSDate date];
        [posts addObject:post];
    }
    return posts;
}

+ (void)addPostWithTitle:(NSString *)title body:(NSString *)body {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedTitle = [title stringByTrimmingCharactersInSet:whitespace];
    NSString *trimmedBody = [body stringByTrimmingCharactersInSet:whitespace];
    if (trimmedTitle.length == 0) return;

    NSArray<NSDictionary *> *existing = [[NSUserDefaults standardUserDefaults] arrayForKey:kMRvEKLocalPostsKey] ?: @[];
    NSMutableArray<NSDictionary *> *raw = [existing mutableCopy];

    NSDictionary *entry = @{
        @"title": trimmedTitle,
        @"body": trimmedBody,
        @"authorMDID": [MRvEKIdentity localMDID],
        @"createdAt": @([[NSDate date] timeIntervalSince1970]),
    };
    [raw addObject:entry];

    [[NSUserDefaults standardUserDefaults] setObject:raw forKey:kMRvEKLocalPostsKey];
}

@end
