//
//  SiteScreenSaverView.m
//  Site ScreenSaver 2.0
//
//  Dashboard rotation screensaver implementation
//

#import "SiteScreenSaverView.h"

// MARK: - Constants

/// Timing constants for dashboard rotation
static const NSTimeInterval kMinPageLoadDelay = 0.5;
static const NSTimeInterval kMaxPageLoadDelay = 10.0;
static const NSTimeInterval kDefaultPageLoadDelay = 2.0;
static const NSTimeInterval kMinPostScrollDelay = 1.0;
static const NSTimeInterval kMaxPostScrollDelay = 60.0;
static const NSTimeInterval kDefaultPostScrollDelay = 20.0;
static const double kMinScrollDuration = 5.0;
static const double kMaxScrollDuration = 30.0;
static const double kDefaultScrollDuration = 10.0;

/// UserDefaults keys for persistent storage
static NSString *const kStoredURLsKey = @"SiteScreenSaver_StoredURLs";
static NSString *const kScrollDurationKey = @"SiteScreenSaver_ScrollDuration";
static NSString *const kPageLoadDelayKey = @"SiteScreenSaver_PageLoadDelay";
static NSString *const kPostScrollDelayKey = @"SiteScreenSaver_PostScrollDelay";
static NSString *const kConfigURLKey = @"SiteScreenSaver_ConfigURL";

// MARK: - Interface

@interface SiteScreenSaverView () <WKNavigationDelegate>

// UI Components
@property (strong, nonatomic) WKWebView *webView;

// Data
@property (strong, nonatomic) NSArray<NSURL *> *dashboardURLs;
@property (copy, nonatomic) NSString *configURL;
@property (strong, nonatomic) NSMutableArray<NSString *> *storedURLStrings;

// State
@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) BOOL isRotating;
@property (assign, nonatomic) double scrollDuration;
@property (assign, nonatomic) NSTimeInterval pageLoadDelay;
@property (assign, nonatomic) NSTimeInterval postScrollDelay;

// Tasks
@property (strong, nonatomic) NSURLSessionDataTask *configTask;

// Monitor tracking for independent content
@property (assign, nonatomic) NSInteger monitorIndex;

@end

// MARK: - Implementation

@implementation SiteScreenSaverView

// MARK: - Lifecycle

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        // Initialize state
        self.isRotating = NO;
        self.currentIndex = 0;
        self.dashboardURLs = @[];

        // Assign monitor index based on screen position for independent content
        self.monitorIndex = [self calculateMonitorIndex];

        // Load settings
        [self loadSettings];
        [self loadStoredURLs];

        // Create WebView
        [self setupWebView];

        // Load URLs
        if (self.storedURLStrings.count > 0) {
            [self loadURLsFromStoredStrings];
        } else if (self.configURL.length > 0) {
            [self readDashboardConfig];
        }

        // Set animation time interval
        [self setAnimationTimeInterval:1.0];

        NSLog(@"✅ SiteScreenSaverView initialized (monitor: %ld, preview: %d)",
              (long)self.monitorIndex, isPreview);
    }
    return self;
}

- (void)dealloc {
    self.isRotating = NO;
    [self.configTask cancel];
    self.webView.navigationDelegate = nil;
    NSLog(@"✅ SiteScreenSaverView deallocated");
}

/// Calculate monitor index based on frame origin for independent content
- (NSInteger)calculateMonitorIndex {
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;

    // Simple hash based on position to determine monitor index
    NSInteger index = ((NSInteger)x / 1000 + (NSInteger)y / 1000) % 100;
    return ABS(index);
}

/// Setup WebView for dashboard display
- (void)setupWebView {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // JavaScript is enabled by default in modern WebKit

    self.webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self addSubview:self.webView];
}

// MARK: - ScreenSaver Methods

- (void)startAnimation {
    [super startAnimation];

    if (self.dashboardURLs.count > 0 && !self.isRotating) {
        self.isRotating = YES;

        // Offset start index by monitor index for independent content
        self.currentIndex = self.monitorIndex % self.dashboardURLs.count;

        [self rotateToNextDashboard];
        NSLog(@"▶️ Starting rotation on monitor %ld with %ld dashboards",
              (long)self.monitorIndex, (long)self.dashboardURLs.count);
    }
}

- (void)stopAnimation {
    [super stopAnimation];
    self.isRotating = NO;
    NSLog(@"⏹ Stopping rotation on monitor %ld", (long)self.monitorIndex);
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    // WebView handles all drawing
}

- (void)animateOneFrame {
    // Animation handled by rotation logic
    return;
}

- (BOOL)hasConfigureSheet {
    return YES;
}

- (NSWindow *)configureSheet {
    // Load the preferences window controller
    Class prefClass = NSClassFromString(@"SiteScreenSaverConfigController");
    if (prefClass) {
        id controller = [[prefClass alloc] init];
        if ([controller respondsToSelector:@selector(window)]) {
            return [controller performSelector:@selector(window)];
        }
    }

    // Fallback: create basic alert
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Configuration";
    alert.informativeText = @"Use 'URLs > Add URL' in the app menu to add dashboard URLs.";
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];

    return nil;
}

// MARK: - Settings Management

- (void)loadSettings {
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"SiteScreenSaver"];

    // Load scroll duration
    self.scrollDuration = [defaults doubleForKey:kScrollDurationKey];
    if (self.scrollDuration < kMinScrollDuration || self.scrollDuration > kMaxScrollDuration) {
        self.scrollDuration = kDefaultScrollDuration;
    }

    // Load page load delay
    self.pageLoadDelay = [defaults doubleForKey:kPageLoadDelayKey];
    if (self.pageLoadDelay < kMinPageLoadDelay || self.pageLoadDelay > kMaxPageLoadDelay) {
        self.pageLoadDelay = kDefaultPageLoadDelay;
    }

    // Load post-scroll delay
    self.postScrollDelay = [defaults doubleForKey:kPostScrollDelayKey];
    if (self.postScrollDelay < kMinPostScrollDelay || self.postScrollDelay > kMaxPostScrollDelay) {
        self.postScrollDelay = kDefaultPostScrollDelay;
    }

    // Load config URL
    self.configURL = [defaults stringForKey:kConfigURLKey];
    if (!self.configURL) {
        self.configURL = @"";
    }

    NSLog(@"✅ Loaded settings - scroll: %.1fs, load: %.1fs, post: %.1fs",
          self.scrollDuration, self.pageLoadDelay, self.postScrollDelay);
}

- (void)saveSettings {
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"SiteScreenSaver"];
    [defaults setDouble:self.scrollDuration forKey:kScrollDurationKey];
    [defaults setDouble:self.pageLoadDelay forKey:kPageLoadDelayKey];
    [defaults setDouble:self.postScrollDelay forKey:kPostScrollDelayKey];
    if (self.configURL) {
        [defaults setObject:self.configURL forKey:kConfigURLKey];
    }
    [defaults synchronize];
    NSLog(@"💾 Settings saved");
}

// MARK: - URL Storage Management

- (void)loadStoredURLs {
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"SiteScreenSaver"];
    NSArray *stored = [defaults arrayForKey:kStoredURLsKey];

    if (stored) {
        self.storedURLStrings = [stored mutableCopy];
    } else {
        self.storedURLStrings = [NSMutableArray array];
    }

    NSLog(@"✅ Loaded %ld stored URLs", (long)self.storedURLStrings.count);
}

- (void)saveStoredURLs {
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"SiteScreenSaver"];
    [defaults setObject:self.storedURLStrings forKey:kStoredURLsKey];
    [defaults synchronize];
    NSLog(@"💾 Saved %ld URLs", (long)self.storedURLStrings.count);
}

- (void)loadURLsFromStoredStrings {
    NSMutableArray<NSURL *> *urls = [NSMutableArray array];

    for (NSString *urlString in self.storedURLStrings) {
        NSURL *url = [NSURL URLWithString:urlString];
        if (url && url.scheme && ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])) {
            [urls addObject:url];
        } else {
            NSLog(@"⚠️ Skipping invalid stored URL: %@", urlString);
        }
    }

    self.dashboardURLs = [urls copy];
    NSLog(@"✅ Loaded %ld valid URLs from storage", (long)self.dashboardURLs.count);
}

// MARK: - Configuration Loading

- (void)readDashboardConfig {
    [self.configTask cancel];

    NSURL *url = [NSURL URLWithString:self.configURL];
    if (!url || ![url.scheme isEqualToString:@"https"]) {
        NSLog(@"❌ Invalid or non-HTTPS config URL: %@", self.configURL);
        return;
    }

    NSLog(@"🌐 Fetching config from: %@", url);

    self.configTask = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleConfigResponse:data response:response error:error];
        });
    }];
    [self.configTask resume];
}

- (void)handleConfigResponse:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    if (error) {
        NSLog(@"❌ Config load failed: %@", error);
        return;
    }

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            NSLog(@"❌ Config HTTP error: %ld", (long)httpResponse.statusCode);
            return;
        }
    }

    NSString *fileContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!fileContent || fileContent.length == 0) {
        NSLog(@"❌ Config file is empty");
        return;
    }

    NSMutableArray *urls = [NSMutableArray array];
    NSArray *lines = [fileContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    for (NSString *line in lines) {
        NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (trimmed.length == 0 || [trimmed hasPrefix:@"#"]) {
            continue;
        }

        NSURL *url = [NSURL URLWithString:trimmed];
        if (url && url.scheme && url.host) {
            [urls addObject:url];
            NSLog(@"✅ Loaded dashboard: %@", url);
        } else {
            NSLog(@"⚠️ Skipping invalid URL: %@", trimmed);
        }
    }

    self.dashboardURLs = [urls copy];
    self.currentIndex = 0;

    if (self.dashboardURLs.count > 0) {
        NSMutableArray<NSString *> *urlStrings = [NSMutableArray arrayWithCapacity:urls.count];
        for (NSURL *url in urls) {
            [urlStrings addObject:url.absoluteString];
        }
        self.storedURLStrings = urlStrings;
        [self saveStoredURLs];

        NSLog(@"✅ Successfully loaded %ld dashboards from remote URL", (long)self.dashboardURLs.count);
    } else {
        NSLog(@"⚠️ No valid URLs found in config");
    }
}

// MARK: - Dashboard Rotation

- (void)loadCurrentDashboard {
    if (self.currentIndex < 0 || self.currentIndex >= self.dashboardURLs.count) {
        NSLog(@"❌ Invalid dashboard index: %ld", (long)self.currentIndex);
        return;
    }

    NSURL *url = self.dashboardURLs[self.currentIndex];
    NSLog(@"📄 Loading dashboard %ld: %@", (long)self.currentIndex, url);

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)rotateToNextDashboard {
    if (!self.isRotating || self.dashboardURLs.count == 0) {
        NSLog(@"⏹ Rotation stopped or no dashboards");
        return;
    }

    [self loadCurrentDashboard];

    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.pageLoadDelay * NSEC_PER_SEC)),
                  dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || !strongSelf.isRotating) return;

        [strongSelf scrollCurrentDashboard];

        NSTimeInterval totalDelay = strongSelf.scrollDuration + strongSelf.postScrollDelay;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalDelay * NSEC_PER_SEC)),
                      dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || !strongSelf.isRotating || strongSelf.dashboardURLs.count == 0) return;

            strongSelf.currentIndex = (strongSelf.currentIndex + 1) % strongSelf.dashboardURLs.count;
            [strongSelf rotateToNextDashboard];
        });
    });
}

- (void)scrollCurrentDashboard {
    if (!self.isRotating) return;

    NSLog(@"📜 Scrolling dashboard over %.1f seconds", self.scrollDuration);

    NSString *javascript = [NSString stringWithFormat:
        @"(function() {"
        "  try {"
        "    var totalHeight = Math.max("
        "      document.body.scrollHeight,"
        "      document.body.offsetHeight,"
        "      document.documentElement.clientHeight,"
        "      document.documentElement.scrollHeight,"
        "      document.documentElement.offsetHeight"
        "    ) - window.innerHeight;"
        "    "
        "    if (totalHeight <= 0) {"
        "      console.log('Page is not scrollable');"
        "      return;"
        "    }"
        "    "
        "    var duration = %.0f;"
        "    var start = window.scrollY || window.pageYOffset;"
        "    var startTime = performance.now();"
        "    "
        "    function easeInOutQuad(t) {"
        "      return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;"
        "    }"
        "    "
        "    function step(now) {"
        "      var elapsed = now - startTime;"
        "      var progress = Math.min(elapsed / duration, 1);"
        "      var eased = easeInOutQuad(progress);"
        "      window.scrollTo(0, start + totalHeight * eased);"
        "      "
        "      if (progress < 1) {"
        "        requestAnimationFrame(step);"
        "      } else {"
        "        console.log('Scroll complete');"
        "      }"
        "    }"
        "    "
        "    requestAnimationFrame(step);"
        "  } catch(e) {"
        "    console.error('Scroll error:', e);"
        "  }"
        "})();",
        self.scrollDuration * 1000.0
    ];

    [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
        if (error) {
            NSLog(@"⚠️ JavaScript error: %@", error.localizedDescription);
        }
    }];
}

// MARK: - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"✅ Page loaded successfully");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"❌ Page load failed: %@", error.localizedDescription);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"❌ Page load failed (provisional): %@", error.localizedDescription);
}

@end
