//
//  YSDBasicWebViewController.m
//  freeStuff
//
//  Created by 孙号斌 on 2017/11/6.
//  Copyright © 2017年 孙号斌. All rights reserved.
//

#import "YSDBasicWebViewController.h"

@interface YSDBasicWebViewController ()<WKNavigationDelegate>
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *closeItem;
@end

@implementation YSDBasicWebViewController
#pragma mark - 懒加载
- (WKWebView *)webView
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, CGFloatNavi, SCREEN_WIDTH, SCREEN_HEIGHT-CGFloatNavi)];
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.navigationDelegate = self;
        [_webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
        [_webView addObserver:self
                  forKeyPath:@"title"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
        [self.view insertSubview:_webView belowSubview:self.progressView];
    }
    return _webView;
}
- (UIProgressView *)progressView
{
    if(!_progressView)
    {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, CGFloatNavi, SCREEN_WIDTH, 2)];
        self.progressView.tintColor = UIColorTheme;
        self.progressView.trackTintColor = UIColorWhite;
        [self.view addSubview:self.progressView];
    }
    return _progressView;
}
- (UIBarButtonItem *)backItem
{
    if (!_backItem) {
        //返回按钮
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 44)];
        [button setImage:[UIImage imageNamed:@"nav_back_gray"]
                forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(backItemAction:)
         forControlEvents:UIControlEventTouchUpInside];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(2, -8, -2, 0);
        _backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _backItem;
}
- (UIBarButtonItem *)closeItem
{
    if (!_closeItem) {
        UIButton *button = [UIButton buttonWithFrame:CGRectZero
                                               title:@"关闭"
                                                font:UIFont(14)
                                          titleColor:RGB(74, 74, 74)];
        [button addTarget:self
                   action:@selector(closeItemAction:)
         forControlEvents:UIControlEventTouchUpInside];
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [button sizeToFit];

        _closeItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _closeItem;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*************** 加载URL ***************/
    NSURLRequest* request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 按钮的响应事件
- (void)backItemAction:(UIButton *)backItem
{
    [self.webView goBack];
}
- (void)closeItemAction:(UIButton *)closeItem
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - KVO观察web加载进度
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"])
    {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1)
        {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }
        else
        {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
    else if (object == _webView && [keyPath isEqualToString:@"title"])
    {
        self.title = _webView.title;
    }
}


// 页面加载完毕时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    // 禁用用户选择
    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';"completionHandler:nil];
    // 禁用长按弹出框
    [webView evaluateJavaScript:@"document.body.style.webkitTouchCallout='none';" completionHandler:nil];

    //导航栏右滑返回
    self.navigationController.interactivePopGestureRecognizer.enabled = !self.webView.canGoBack;
    if (self.webView.canGoBack)
    {
        [self.navigationItem setLeftBarButtonItems:@[self.backItem,self.closeItem] animated:NO];
    }
    else
    {
        [self.navigationItem setLeftBarButtonItems:nil animated:NO];
    }
    
}



- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    // Unsure why WKWebView calls this controller - instead of it's own parent controller
    if (self.presentedViewController)
    {
        [self.presentedViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
    else
    {
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

#pragma mark - 销毁
- (void)dealloc {
    [self.webView removeObserver:self
                      forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];

}

@end
