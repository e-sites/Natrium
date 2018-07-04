#import "NatriumConfig.h"

@implementation NatriumConfig
+ (EnvironmentType)environment {
    return EnvironmentTypeProduction;
}

+ (ConfigurationType)configuration {
    return ConfigurationTypeDebug;
}
@end
