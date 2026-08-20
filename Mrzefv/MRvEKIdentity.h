#import <Foundation/Foundation.h>

@interface MRvEKIdentity : NSObject

/// This device's local MDID — generated once and persisted in the
/// Keychain, same pattern as the signer app. Same value on every call
/// after the first, including after the host app is reinstalled
/// (Keychain data survives that; app sandbox data does not).
+ (NSString *)localMDID;

@end
