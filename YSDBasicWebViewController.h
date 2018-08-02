//
//  YSDBasicWebViewController.h
//  freeStuff
//
//  Created by 孙号斌 on 2017/11/6.
//  Copyright © 2017年 孙号斌. All rights reserved.
//

#import "YSDBasicViewController.h"
#import <WebKit/WebKit.h>

@interface YSDBasicWebViewController : YSDBasicViewController
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSURL *url;

@end
