#import <Foundation/Foundation.h>

@interface MRvEKLocalPost : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *authorMDID;
@property (nonatomic, strong) NSDate *createdAt;
/// Filename only (not a full path) — resolve with
/// +[MRvEKLocalPosts attachmentsDirectory] joined with this. Nil if
/// the post has no attachment.
@property (nonatomic, copy) NSString *attachmentFilename;
@end

@interface MRvEKLocalPosts : NSObject

/// Locally-saved posts, oldest first. Lives in this app's own
/// NSUserDefaults — this device, this host app only. No networking.
+ (NSArray<MRvEKLocalPost *> *)allPosts;

/// Saves a new post, tagged with this device's MDID.
/// attachmentFilename may be nil.
+ (void)addPostWithTitle:(NSString *)title
                     body:(NSString *)body
       attachmentFilename:(nullable NSString *)attachmentFilename;

/// Folder attachments are copied into — Caches, not Documents, since
/// these are disposable local novelty content, not data worth backing up.
+ (NSString *)attachmentsDirectory;

@end
