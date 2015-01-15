#import "TRWeatherViewModel.h"
#import "TRCurrentConditions.h"
#import "TRHistoricalConditions.h"
#import "TRTemperature.h"
#import "TRTemperatureComparisonFormatter.h"
#import "NSMutableAttributedString+TRAttributeHelpers.h"
#import "TRBearingFormatter.h"
#import "TRSettingsController.h"
#import "TRTemperatureFormatter.h"

@interface TRWeatherViewModel ()

@property (nonatomic) TRCurrentConditions *currentConditions;
@property (nonatomic) TRHistoricalConditions *yesterdaysConditions;

@end

@implementation TRWeatherViewModel

- (instancetype)initWithCurrentConditions:(TRCurrentConditions *)currentConditions yesterdaysConditions:(TRHistoricalConditions *)yesterdaysConditions
{
    self = [super init];
    if (!self) return nil;

    self.currentConditions = currentConditions;
    self.yesterdaysConditions = yesterdaysConditions;

    return self;
}

#pragma mark - Properties

- (UIImage *)conditionsImage
{
    return [UIImage imageNamed:self.currentConditions.conditionsDescription];
}

- (NSString *)formattedTemperatureRange
{
    TRTemperatureFormatter *formatter = [TRTemperatureFormatter new];
    formatter.usesMetricSystem = [[TRSettingsController new] unitSystem] == TRUnitSystemMetric;
    NSString *high = [formatter stringFromTemperature:self.currentConditions.highTemperature];
    NSString *low = [formatter stringFromTemperature:self.currentConditions.lowTemperature];
    return [NSString stringWithFormat:@"%@ / %@", high, low];
}

- (NSString *)formattedWindSpeed
{
    NSString *bearing = [TRBearingFormatter abbreviatedCardinalDirectionStringFromBearing:self.currentConditions.windBearing];
    return [NSString stringWithFormat:@"%.1f mph %@", self.currentConditions.windSpeed, bearing];
}

- (NSAttributedString *)attributedTemperatureComparison
{
    TRTemperatureComparison comparison = [self.currentConditions.temperature comparedTo:self.yesterdaysConditions.temperature];

    NSString *adjective;
    NSString *comparisonString = [TRTemperatureComparisonFormatter localizedStringFromComparison:comparison adjective:&adjective];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:comparisonString];
    [attributedString setFont:[UIFont defaultUltraLightFontOfSize:37]];
    [attributedString setTextColor:[UIColor defaultTextColor]];
    [attributedString setLineHeightMultiple:1.15f spacing:2.0f];
    [attributedString setTextColor:[self colorForTemperatureComparison:comparison] forSubstring:adjective];

    return attributedString;
}

- (CGFloat)precipitationProbability
{
    return self.currentConditions.precipitationProbability;
}

#pragma mark - Private Methods

- (UIColor *)colorForTemperatureComparison:(TRTemperatureComparison)comparison
{
    switch (comparison) {
        case TRTemperatureComparisonSame:
            return [UIColor defaultTextColor];
        case TRTemperatureComparisonColder:
            return [UIColor coldColor];
        case TRTemperatureComparisonCooler:
            return [UIColor coolerColor];
        case TRTemperatureComparisonHotter:
            return [UIColor hotColor];
        case TRTemperatureComparisonWarmer:
            return [UIColor warmerColor];
    }
}

@end