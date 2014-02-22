
#import "SBChoosyAppType.h"
#import "SBChoosyAppTypeParameter.h"
#import "SBChoosyAppTypeAction.h"
#import "SBChoosyAppInfo.h"
#import "MTLValueTransformer.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "NSArray+ObjectiveSugar.h"
#import "SBChoosyLocalStore.h"

@implementation SBChoosyAppType

- (NSArray *)installedApps
{
    return [self.apps select:^BOOL(id object) {
        return ((SBChoosyAppInfo *)object).isInstalled;
    }];
}

- (SBChoosyAppInfo *)defaultApp
{
    NSString *defaultAppKey = [SBChoosyLocalStore defaultAppForAppTypeKey:self.key];
    if (!defaultAppKey) return nil;
    
    return [self.apps detect:^BOOL(id object) {
        return [((SBChoosyAppInfo *)object).appKey isEqualToString:defaultAppKey];
    }];
}

+ (SBChoosyAppType *)filterAppTypesArray:(NSArray *)appTypes byKey:(NSString *)appTypeKey
{
    if (!appTypes || !appTypeKey) return nil;
    
    for (SBChoosyAppType *appType in appTypes) {
        if ([appType.key isEqualToString:appTypeKey]) {
            return appType;
        }
    }
    
    return nil;
}

- (SBChoosyAppInfo *)findAppInfoWithAppKey:(NSString *)appKey
{
    if (!self.apps) return nil;
    
    for (SBChoosyAppInfo *appInfo in self.apps) {
        if ([appInfo.appKey isEqualToString:appKey]) {
            return appInfo;
        }
    }
    
    return nil;
}

#pragma mark Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    // no special mapping
    return @{
             };
}

+ (NSValueTransformer *)dateUpdatedJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)parametersJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[SBChoosyAppTypeParameter class]];
}

+ (NSValueTransformer *)actionsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[SBChoosyAppTypeAction class]];
}

+ (NSValueTransformer *)appsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[SBChoosyAppInfo class]];
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *_formatter;
    
    if (!_formatter) {
        _formatter = [NSDateFormatter new];
        _formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _formatter;
}

@end
