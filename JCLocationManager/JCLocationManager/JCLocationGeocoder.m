//
//  JCLocationGeocoder.m
//  JCLocationManager
//
//  Created by Jam on 16/4/26.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCLocationGeocoder.h"

@interface JCLocationGeocoder ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) locationCompletionHandler completionHandler;

@property (nonatomic, assign) BOOL isNeedReverse;
@property (nonatomic, strong) CLGeocoder *reverseGeocoder;

@end

@implementation JCLocationGeocoder

- (CLGeocoder *)reverseGeocoder {
    if (_reverseGeocoder == nil) {
        _reverseGeocoder = [[CLGeocoder alloc] init];
    }
    
    return _reverseGeocoder;
}

+ (JCLocationGeocoder *)sharedInstance {
    static JCLocationGeocoder *defaultLocationGeocoder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLocationGeocoder = [[self alloc] init];
    });
    return defaultLocationGeocoder;
}

+ (JCLocationGeocoder *)sharedInstanceForKey:(NSString *)key {
    if (key == nil) {
        return [JCLocationGeocoder sharedInstance];
    }
    static NSMutableDictionary *instances = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instances = [NSMutableDictionary new];
    });
    
    JCLocationGeocoder *instance = [instances objectForKey:key];
    
    if( instance == nil ){
        instance = [self new];
        
        [instances setObject:instance forKey:key];
    }
    
    return instance;
    
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        _geocoding = NO;
        _locationRefreshTime = 60;
        _isNeedReverse = NO;
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        #endif
        
    }
    
    return self;
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)delegator didFailWithError:(NSError *)error {
    if( error.code == kCLErrorLocationUnknown ) {
    } else {
        [self completeGeocodeWithError:error];
    }
}


-(void)locationManager:(CLLocationManager *)delegator didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self locationManagerDidUpdateToLocation:newLocation];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    
    [self locationManagerDidUpdateToLocation:newLocation];
}

#pragma mark self method

- (void)completeGeocodeWithError:(NSError *)error {
    
    if (_geocoding) {
        _geocoding = NO;
        _error = error;
        
        if(_completionHandler != nil ) {
            if (error == nil) {
                _completionHandler(YES);
                return;
            }
            _completionHandler(NO);
        }
        
    }
}

- (void)locationManagerDidUpdateToLocation:(CLLocation *)newLocation {
    
    if( newLocation == nil || newLocation.horizontalAccuracy < 0 ) {
        return;
    }
    
    CLLocationCoordinate2D newLocationCoordinate = newLocation.coordinate;
    
    if( !CLLocationCoordinate2DIsValid(newLocationCoordinate) || ( newLocationCoordinate.latitude == 0.0 && newLocationCoordinate.longitude == 0.0 )) {
        return;
    }
    
    _currentLocation = newLocation;
    
    [self cancelForwardGeocode];
    
    if (_isNeedReverse) {
        [self reverseGeocode];
    } else {
        [self completeGeocodeWithError:nil];
    }
}

- (void)cancelForwardGeocode {
    if (_locationManager != nil) {
        [_locationManager stopUpdatingLocation];
    }
}

- (void)startGeocodeWithCompletion:(void (^)(BOOL success))completionHandler {
    _error = nil;
    _geocoding = YES;
    
    _completionHandler = completionHandler;
    
    BOOL useCache = (_currentLocation != nil && ([[_currentLocation.timestamp dateByAddingTimeInterval:_locationRefreshTime] timeIntervalSinceNow] > 0));
    
    if (useCache) {
        if (_isNeedReverse) {
            [self reverseGeocode];
        } else {
            [self completeGeocodeWithError:nil];
        }
    } else {
        [self forwardGeocode];
    }
}

- (void)forwardGeocode {
    if([JCLocationGeocoder canGeocode]) {
        [_locationManager startUpdatingLocation];
    } else {
        [self completeGeocodeWithError:[NSError errorWithDomain:kCLErrorDomain code:kCLErrorDenied userInfo:nil]];
    }
}

- (void)reverseGeocode {
    if (self.reverseGeocoder.isGeocoding) {
        [self.reverseGeocoder cancelGeocode];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.reverseGeocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error){
        if (error) {
            [self completeGeocodeWithError:error];
        } else {
            if ([placemarks count] > 0) {
                _locationPlacemark = [placemarks objectAtIndex:0];
                [weakSelf completeGeocodeWithError:nil];
                
                return ;
            }
            [weakSelf completeGeocodeWithError:[NSError errorWithDomain:kCLErrorDomain code:kCLErrorGeocodeFoundNoResult userInfo:nil]];
        }
    }];
}

#pragma mark public method

+(BOOL)canGeocode {
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        return ([CLLocationManager locationServicesEnabled] && ((authStatus == kCLAuthorizationStatusAuthorizedAlways) || (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) || (authStatus == kCLAuthorizationStatusNotDetermined)));
    }
    
    #endif
    
    //屏蔽一个编译报警
    //http://stackoverflow.com/questions/4318708/checking-for-ios-location-services
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return ([CLLocationManager locationServicesEnabled] && ((authStatus == kCLAuthorizationStatusAuthorized) || (authStatus == kCLAuthorizationStatusNotDetermined)));
    #pragma clang diagnostic pop
}

+(void)geocode:(void(^)(BOOL success))completionHandler {
    [[JCLocationGeocoder sharedInstance] geocode:completionHandler];
}

+(void)reverseGeocode:(void(^)(BOOL success))completionHandler {
    [[JCLocationGeocoder sharedInstance] reverseGeocode:completionHandler];
}

-(void)geocode:(void (^)(BOOL success))completionHandler {
    [self startGeocodeWithCompletion:completionHandler];
}

-(BOOL)canGeocode {
    return [JCLocationGeocoder canGeocode];
}

-(void)reverseGeocode:(void(^)(BOOL success))completionHandler {
    _isNeedReverse = YES;
    [self startGeocodeWithCompletion:completionHandler];
}

@end
