#import <Foundation/Foundation.h>

@interface MRvEKLocalPost : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *authorMDID;
@property (nonatomic, strong) NSDate *createdAt;
@end

@interface MRvEKLocalPosts : NSObject

/// Locally-saved posts, oldest first. Lives in this app's own
/// NSUserDefaults — this device, this host app only. No networking.
+ (NSArray<MRvEKLocalPost *> *)allPosts;

/// Saves a new post, tagged with this device's MDID.
+ (void)addPostWithTitle:(NSString *)title body:(NSString *)body;

@end
