#import "MrzefvOverlay.h"

__attribute__((constructor))
static void MRZEntry(void)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MRZInstallOverlay();
    });
}
