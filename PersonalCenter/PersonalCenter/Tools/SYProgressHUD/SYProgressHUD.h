//
//  SYProgressHUD.h
//  SYHUDView
//
//  Created by Saucheong Ye on 8/12/15.
//  Copyright © 2015 sauchye.com. All rights reserved.
//

#import "MBProgressHUD.h"

typedef NS_ENUM(NSInteger, SYProgressHUDStatus) {
    
    SYProgressHUDStatusSuccess = 0,
    SYProgressHUDStatusFailure,
    SYProgressHUDStatusInfo,
    SYProgressHUDStatusLoading
};

@interface SYProgressHUD : MBProgressHUD

+ (void)showStatus:(SYProgressHUDStatus)status
              text:(NSString *)text
              hide:(NSTimeInterval)time;

/** success icon and text */
+ (void)showSuccessText:(NSString *)text;

/** failure or error icon and text */
+ (void)showFailureText:(NSString *)text;

/** info  icon and text */
+ (void)showInfoText:(NSString *)text;

/** Indeterminate loading window and text */
+ (void)showLoadingWindowText:(NSString *)text;

/** hide window hud */
+ (void)hide;

/** Indeterminate loading window or view */
+ (SYProgressHUD *)showToLoadingView:(UIView *)view;


/** show center text*/
+ (SYProgressHUD *)showToCenterText:(NSString *)text;

/** show bottom text */
+ (SYProgressHUD *)showToBottomText:(NSString *)text;

/** setting customImage and text */
+ (SYProgressHUD *)showToCustomImage:(UIImage *)image
                                text:(NSString *)text;



@end
