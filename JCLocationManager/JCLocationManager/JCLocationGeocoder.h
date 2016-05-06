//
//  JCLocationGeocoder.h
//  JCLocationManager
//
//  Created by Jam on 16/4/26.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^locationCompletionHandler)(BOOL success);

@interface JCLocationGeocoder : NSObject <CLLocationManagerDelegate>

@property (nonatomic, readonly, getter = isGeocoding) BOOL geocoding;
@property (nonatomic, readonly) CLLocation *currentLocation;
@property (nonatomic, readonly, strong) NSError *error;

@property (nonatomic, readonly, copy) NSArray *locationPlacemarks;
@property (nonatomic, readonly, copy) CLPlacemark *locationPlacemark;

//自定义一个刷新时间默认60秒
@property (nonatomic, assign) NSTimeInterval locationRefreshTime;

+ (JCLocationGeocoder *)sharedInstance;
+ (JCLocationGeocoder *)sharedInstanceForKey:(NSString *)key;

+(BOOL)canGeocode;
+(void)geocode:(void(^)(BOOL success))completionHandler;
+(void)reverseGeocode:(void(^)(BOOL success))completionHandler;

-(BOOL)canGeocode;
-(void)geocode:(void (^)(BOOL success))completionHandler;
-(void)reverseGeocode:(void(^)(BOOL success))completionHandler;

@end
