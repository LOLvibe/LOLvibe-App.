#import "XMPPMessage.h"

@interface XMPPMessage (XEP_0066)

- (void)addOutOfBandURL:(NSURL *)URL desc:(NSString *)desc;
- (void)addOutOfBandURI:(NSString *)URI desc:(NSString *)desc;

- (BOOL)hasOutOfBandData;
- (BOOL)isUserDetail;

- (NSURL *)outOfBandURL;
- (NSString *)outOfBandURI;
- (NSString *)outOfBandDesc;

@end
