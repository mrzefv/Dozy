#import <UIKit/UIKit.h>

@interface MRvEKPostDetailViewController : UIViewController

- (instancetype)initWithTitle:(NSString *)title body:(NSString *)body;

/// attachmentFilename is a filename only (resolved against
/// +[MRvEKLocalPosts attachmentsDirectory]) — pass nil for pinned
/// posts, which never have one.
- (instancetype)initWithTitle:(NSString *)title
                          body:(NSString *)body
            attachmentFilename:(nullable NSString *)attachmentFilename;

@end
