#import "MRvEKIdentity.h"
#import <Security/Security.h>

static NSString * const kMRvEKKeychainService = @"com.mrvek.uplink.identity";
static NSString * const kMRvEKKeychainAccount = @"mdid";

@implementation MRvEKIdentity

+ (NSString *)localMDID {
    NSString *existing = [self readFromKeychain];
    if (existing.length > 0) {
        return existing;
    }
    NSString *generated = [self generateMDID];
    [self writeToKeychain:generated];
    return generated;
}

+ (NSString *)generateMDID {
    NSString *alphabet = @"ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no 0/O/1/I
    NSMutableString *segmentA = [NSMutableString string];
    NSMutableString *segmentB = [NSMutableString string];
    for (int i = 0; i < 6; i++) {
        uint32_t idx = arc4random_uniform((uint32_t)alphabet.length);
        [segmentA appendFormat:@"%C", [alphabet characterAtIndex:idx]];
    }
    for (int i = 0; i < 2; i++) {
        uint32_t idx = arc4random_uniform((uint32_t)alphabet.length);
        [segmentB appendFormat:@"%C", [alphabet characterAtIndex:idx]];
    }
    return [NSString stringWithFormat:@"MRK-%@-%@", segmentA, segmentB];
}

+ (NSString *)readFromKeychain {
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kMRvEKKeychainService,
        (__bridge id)kSecAttrAccount: kMRvEKKeychainAccount,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
    };

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess && result) {
        NSData *data = (__bridge_transfer NSData *)result;
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (void)writeToKeychain:(NSString *)value {
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kMRvEKKeychainService,
        (__bridge id)kSecAttrAccount: kMRvEKKeychainAccount,
    };
    NSDictionary *attributesToUpdate = @{
        (__bridge id)kSecValueData: data,
    };

    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query,
                                     (__bridge CFDictionaryRef)attributesToUpdate);
    if (status == errSecItemNotFound) {
        NSMutableDictionary *addQuery = [query mutableCopy];
        addQuery[(__bridge id)kSecValueData] = data;
        addQuery[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
        SecItemAdd((__bridge CFDictionaryRef)addQuery, NULL);
    }
}

@end
