//
//  SiteScreenSaverConfigController.m
//  Site ScreenSaver 2.0
//
//  Configuration window controller implementation
//

#import "SiteScreenSaverConfigController.h"
#import "SiteScreenSaverView.h"
#import <ScreenSaver/ScreenSaver.h>
#import <WebKit/WebKit.h>
@import UniformTypeIdentifiers;

// UserDefaults keys (must match SiteScreenSaverView)
static NSString *const kStoredURLsKey = @"SiteScreenSaver_StoredURLs";
static NSString *const kScrollDurationKey = @"SiteScreenSaver_ScrollDuration";
static NSString *const kPageLoadDelayKey = @"SiteScreenSaver_PageLoadDelay";
static NSString *const kPostScrollDelayKey = @"SiteScreenSaver_PostScrollDelay";
static NSString *const kConfigURLKey = @"SiteScreenSaver_ConfigURL";

// Timing constants
static const NSTimeInterval kMinPageLoadDelay = 0.5;
static const NSTimeInterval kMaxPageLoadDelay = 10.0;
static const NSTimeInterval kDefaultPageLoadDelay = 2.0;
static const NSTimeInterval kMinPostScrollDelay = 1.0;
static const NSTimeInterval kMaxPostScrollDelay = 60.0;
static const NSTimeInterval kDefaultPostScrollDelay = 20.0;
static const double kMinScrollDuration = 5.0;
static const double kMaxScrollDuration = 30.0;
static const double kDefaultScrollDuration = 10.0;

@interface SiteScreenSaverConfigController () <NSTableViewDataSource, NSTableViewDelegate>

// UI Components
@property (strong, nonatomic) NSButton *addURLButton;
@property (strong, nonatomic) NSButton *removeURLButton;
@property (strong, nonatomic) NSButton *loadCSVButton;
@property (strong, nonatomic) NSButton *loadRemoteButton;
@property (strong, nonatomic) NSButton *clearAllButton;
@property (strong, nonatomic) NSButton *timingButton;
@property (strong, nonatomic) NSScrollView *tableScrollView;
@property (strong, nonatomic) NSTableView *tableView;
@property (strong, nonatomic) NSTextField *statusLabel;
@property (strong, nonatomic) NSButton *okButton;

// Preview
@property (strong, nonatomic) SiteScreenSaverView *previewView;

// Data
@property (strong, nonatomic) NSMutableArray<NSString *> *urls;
@property (assign, nonatomic) double scrollDuration;
@property (assign, nonatomic) NSTimeInterval pageLoadDelay;
@property (assign, nonatomic) NSTimeInterval postScrollDelay;
@property (copy, nonatomic) NSString *configURL;

@end

@implementation SiteScreenSaverConfigController

- (instancetype)init {
    // Create window
    NSRect frame = NSMakeRect(0, 0, 600, 500);
    NSWindow *window = [[NSWindow alloc] initWithContentRect:frame
                                                    styleMask:(NSWindowStyleMaskTitled |
                                                             NSWindowStyleMaskClosable)
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO];
    window.title = @"Site ScreenSaver Options";

    self = [super initWithWindow:window];
    if (self) {
        [self loadSettings];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    NSView *contentView = [[NSView alloc] initWithFrame:self.window.contentView.bounds];

    CGFloat margin = 20;
    CGFloat buttonHeight = 28;
    CGFloat yPos = self.window.frame.size.height - margin - buttonHeight;

    // Title label
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(margin, yPos, 560, 24)];
    titleLabel.stringValue = @"Dashboard URLs";
    titleLabel.editable = NO;
    titleLabel.bordered = NO;
    titleLabel.drawsBackground = NO;
    titleLabel.font = [NSFont systemFontOfSize:14 weight:NSFontWeightBold];
    [contentView addSubview:titleLabel];
    yPos -= 30;

    // Table view for URLs
    self.tableScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(margin, yPos - 200, 560, 200)];
    self.tableView = [[NSTableView alloc] initWithFrame:self.tableScrollView.bounds];
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.gridStyleMask = NSTableViewSolidHorizontalGridLineMask;

    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"url"];
    column.title = @"URL";
    column.width = 540;
    [self.tableView addTableColumn:column];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableScrollView.documentView = self.tableView;
    self.tableScrollView.hasVerticalScroller = YES;
    [contentView addSubview:self.tableScrollView];
    yPos -= 210;

    // Buttons row 1
    CGFloat xPos = margin;
    self.addURLButton = [[NSButton alloc] initWithFrame:NSMakeRect(xPos, yPos, 100, buttonHeight)];
    self.addURLButton.title = @"Add URL...";
    self.addURLButton.bezelStyle = NSBezelStyleRounded;
    self.addURLButton.target = self;
    self.addURLButton.action = @selector(addURL:);
    [contentView addSubview:self.addURLButton];
    xPos += 110;

    self.removeURLButton = [[NSButton alloc] initWithFrame:NSMakeRect(xPos, yPos, 100, buttonHeight)];
    self.removeURLButton.title = @"Remove";
    self.removeURLButton.bezelStyle = NSBezelStyleRounded;
    self.removeURLButton.target = self;
    self.removeURLButton.action = @selector(removeURL:);
    [contentView addSubview:self.removeURLButton];
    xPos += 110;

    self.loadCSVButton = [[NSButton alloc] initWithFrame:NSMakeRect(xPos, yPos, 120, buttonHeight)];
    self.loadCSVButton.title = @"Load CSV...";
    self.loadCSVButton.bezelStyle = NSBezelStyleRounded;
    self.loadCSVButton.target = self;
    self.loadCSVButton.action = @selector(loadCSV:);
    [contentView addSubview:self.loadCSVButton];
    xPos += 130;

    self.loadRemoteButton = [[NSButton alloc] initWithFrame:NSMakeRect(xPos, yPos, 120, buttonHeight)];
    self.loadRemoteButton.title = @"Load Remote...";
    self.loadRemoteButton.bezelStyle = NSBezelStyleRounded;
    self.loadRemoteButton.target = self;
    self.loadRemoteButton.action = @selector(loadRemote:);
    [contentView addSubview:self.loadRemoteButton];
    yPos -= 40;

    // Buttons row 2
    xPos = margin;
    self.clearAllButton = [[NSButton alloc] initWithFrame:NSMakeRect(xPos, yPos, 100, buttonHeight)];
    self.clearAllButton.title = @"Clear All";
    self.clearAllButton.bezelStyle = NSBezelStyleRounded;
    self.clearAllButton.target = self;
    self.clearAllButton.action = @selector(clearAll:);
    [contentView addSubview:self.clearAllButton];
    xPos += 110;

    self.timingButton = [[NSButton alloc] initWithFrame:NSMakeRect(xPos, yPos, 140, buttonHeight)];
    self.timingButton.title = @"Timing Settings...";
    self.timingButton.bezelStyle = NSBezelStyleRounded;
    self.timingButton.target = self;
    self.timingButton.action = @selector(showTimingSettings:);
    [contentView addSubview:self.timingButton];
    yPos -= 40;

    // Status label
    self.statusLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(margin, yPos, 560, 20)];
    self.statusLabel.editable = NO;
    self.statusLabel.bordered = NO;
    self.statusLabel.drawsBackground = NO;
    self.statusLabel.font = [NSFont systemFontOfSize:11];
    self.statusLabel.textColor = [NSColor secondaryLabelColor];
    [self updateStatusLabel];
    [contentView addSubview:self.statusLabel];
    yPos -= 40;

    // OK button
    self.okButton = [[NSButton alloc] initWithFrame:NSMakeRect(480, 20, 100, buttonHeight)];
    self.okButton.title = @"OK";
    self.okButton.bezelStyle = NSBezelStyleRounded;
    self.okButton.target = self;
    self.okButton.action = @selector(closeWindow:);
    self.okButton.keyEquivalent = @"\r";
    [contentView addSubview:self.okButton];

    self.window.contentView = contentView;
    [self.tableView reloadData];
}

// MARK: - Settings

- (void)loadSettings {
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"SiteScreenSaver"];

    // Load URLs
    NSArray *stored = [defaults arrayForKey:kStoredURLsKey];
    self.urls = stored ? [stored mutableCopy] : [NSMutableArray array];

    // Load timing settings
    self.scrollDuration = [defaults doubleForKey:kScrollDurationKey];
    if (self.scrollDuration < kMinScrollDuration || self.scrollDuration > kMaxScrollDuration) {
        self.scrollDuration = kDefaultScrollDuration;
    }

    self.pageLoadDelay = [defaults doubleForKey:kPageLoadDelayKey];
    if (self.pageLoadDelay < kMinPageLoadDelay || self.pageLoadDelay > kMaxPageLoadDelay) {
        self.pageLoadDelay = kDefaultPageLoadDelay;
    }

    self.postScrollDelay = [defaults doubleForKey:kPostScrollDelayKey];
    if (self.postScrollDelay < kMinPostScrollDelay || self.postScrollDelay > kMaxPostScrollDelay) {
        self.postScrollDelay = kDefaultPostScrollDelay;
    }

    self.configURL = [defaults stringForKey:kConfigURLKey] ?: @"";

    NSLog(@"✅ Config loaded: %ld URLs", (long)self.urls.count);
}

- (void)saveSettings {
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"SiteScreenSaver"];

    [defaults setObject:self.urls forKey:kStoredURLsKey];
    [defaults setDouble:self.scrollDuration forKey:kScrollDurationKey];
    [defaults setDouble:self.pageLoadDelay forKey:kPageLoadDelayKey];
    [defaults setDouble:self.postScrollDelay forKey:kPostScrollDelayKey];
    if (self.configURL) {
        [defaults setObject:self.configURL forKey:kConfigURLKey];
    }
    [defaults synchronize];

    NSLog(@"💾 Config saved: %ld URLs", (long)self.urls.count);
}

- (void)updateStatusLabel {
    self.statusLabel.stringValue = [NSString stringWithFormat:@"%ld dashboard URL%@ configured | Scroll: %.1fs | Load delay: %.1fs | Post delay: %.1fs",
                                    (long)self.urls.count,
                                    self.urls.count == 1 ? @"" : @"s",
                                    self.scrollDuration,
                                    self.pageLoadDelay,
                                    self.postScrollDelay];
}

// MARK: - Actions

- (void)addURL:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Add Dashboard URL";
    alert.informativeText = @"Enter the complete URL of the dashboard:";
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"Add"];
    [alert addButtonWithTitle:@"Cancel"];

    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 350, 24)];
    input.placeholderString = @"https://example.com/dashboard";
    alert.accessoryView = input;
    [alert.window setInitialFirstResponder:input];

    if ([alert runModal] == NSAlertFirstButtonReturn) {
        NSString *urlString = [input.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (urlString.length == 0) {
            [self showAlert:@"Empty URL" message:@"Please enter a URL"];
            return;
        }

        NSURL *url = [NSURL URLWithString:urlString];
        if (url && url.scheme && ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])) {
            if ([self.urls containsObject:urlString]) {
                [self showAlert:@"Duplicate URL" message:@"This URL is already in your list"];
                return;
            }

            [self.urls addObject:urlString];
            [self saveSettings];
            [self.tableView reloadData];
            [self updateStatusLabel];
            NSLog(@"✅ Added URL: %@", urlString);
        } else {
            [self showAlert:@"Invalid URL" message:@"Please enter a valid HTTP or HTTPS URL"];
        }
    }
}

- (void)removeURL:(id)sender {
    NSInteger selectedRow = self.tableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < self.urls.count) {
        NSString *url = self.urls[selectedRow];
        [self.urls removeObjectAtIndex:selectedRow];
        [self saveSettings];
        [self.tableView reloadData];
        [self updateStatusLabel];
        NSLog(@"🗑 Removed URL: %@", url);
    } else {
        [self showAlert:@"No Selection" message:@"Please select a URL to remove"];
    }
}

- (void)loadCSV:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    if (@available(macOS 11.0, *)) {
        openPanel.allowedContentTypes = @[[UTType typeWithFilenameExtension:@"csv"], [UTType typeWithFilenameExtension:@"txt"]];
    } else {
        openPanel.allowedFileTypes = @[@"csv", @"txt"];
    }
    openPanel.message = @"Select a CSV file with dashboard URLs (one per line)";

    if ([openPanel runModal] == NSModalResponseOK) {
        [self parseCSVFile:openPanel.URL];
    }
}

- (void)parseCSVFile:(NSURL *)fileURL {
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        [self showAlert:@"Error Reading File" message:[NSString stringWithFormat:@"Failed to read CSV: %@", error.localizedDescription]];
        return;
    }

    if (content.length == 0) {
        [self showAlert:@"Empty File" message:@"The selected file is empty"];
        return;
    }

    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray<NSString *> *newURLs = [NSMutableArray array];
    NSInteger skippedCount = 0;

    for (NSString *line in lines) {
        NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (trimmed.length == 0 || [trimmed hasPrefix:@"#"]) {
            continue;
        }

        // Remove quotes
        if (([trimmed hasPrefix:@"\""] && [trimmed hasSuffix:@"\""]) ||
            ([trimmed hasPrefix:@"'"] && [trimmed hasSuffix:@"'"])) {
            if (trimmed.length >= 2) {
                trimmed = [trimmed substringWithRange:NSMakeRange(1, trimmed.length - 2)];
            }
        }

        trimmed = [trimmed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        NSURL *url = [NSURL URLWithString:trimmed];
        if (url && url.scheme && ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])) {
            if (![newURLs containsObject:trimmed]) {
                [newURLs addObject:trimmed];
            }
        } else {
            skippedCount++;
        }
    }

    if (newURLs.count > 0) {
        self.urls = newURLs;
        [self saveSettings];
        [self.tableView reloadData];
        [self updateStatusLabel];

        NSString *message = [NSString stringWithFormat:@"Successfully loaded %ld URL%@", (long)newURLs.count, newURLs.count == 1 ? @"" : @"s"];
        if (skippedCount > 0) {
            message = [message stringByAppendingFormat:@"\n\n%ld line%@ skipped (invalid URLs)", (long)skippedCount, skippedCount == 1 ? @"" : @"s"];
        }
        [self showAlert:@"CSV Loaded" message:message];
        NSLog(@"✅ Loaded %ld URLs from CSV (%ld skipped)", (long)newURLs.count, (long)skippedCount);
    } else {
        [self showAlert:@"No Valid URLs" message:@"The CSV file did not contain any valid URLs"];
    }
}

- (void)loadRemote:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Load from Remote URL";
    alert.informativeText = @"Enter the HTTPS URL of a remote configuration file:";
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"Load"];
    [alert addButtonWithTitle:@"Cancel"];

    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 400, 24)];
    input.placeholderString = @"https://example.com/dashboards.txt";
    input.stringValue = self.configURL;
    alert.accessoryView = input;
    [alert.window setInitialFirstResponder:input];

    if ([alert runModal] == NSAlertFirstButtonReturn) {
        NSString *urlString = [input.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (urlString.length == 0) {
            [self showAlert:@"Empty URL" message:@"Please enter a remote configuration URL"];
            return;
        }

        NSURL *url = [NSURL URLWithString:urlString];
        if (!url || ![url.scheme isEqualToString:@"https"]) {
            [self showAlert:@"Invalid URL" message:@"Remote configuration URL must use HTTPS"];
            return;
        }

        self.configURL = urlString;
        [self fetchRemoteConfig:url];
    }
}

- (void)fetchRemoteConfig:(NSURL *)url {
    NSLog(@"🌐 Fetching remote config from: %@", url);

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleRemoteConfigResponse:data response:response error:error];
        });
    }];
    [task resume];
}

- (void)handleRemoteConfigResponse:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    if (error) {
        [self showAlert:@"Network Error" message:[NSString stringWithFormat:@"Failed to load config: %@", error.localizedDescription]];
        return;
    }

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            [self showAlert:@"HTTP Error" message:[NSString stringWithFormat:@"HTTP %ld: Failed to load config", (long)httpResponse.statusCode]];
            return;
        }
    }

    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!content || content.length == 0) {
        [self showAlert:@"Empty Config" message:@"The configuration file is empty"];
        return;
    }

    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray<NSString *> *newURLs = [NSMutableArray array];

    for (NSString *line in lines) {
        NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (trimmed.length == 0 || [trimmed hasPrefix:@"#"]) {
            continue;
        }

        NSURL *url = [NSURL URLWithString:trimmed];
        if (url && url.scheme && url.host) {
            [newURLs addObject:trimmed];
        }
    }

    if (newURLs.count > 0) {
        self.urls = newURLs;
        [self saveSettings];
        [self.tableView reloadData];
        [self updateStatusLabel];
        [self showAlert:@"Remote Config Loaded" message:[NSString stringWithFormat:@"Successfully loaded %ld URL%@ from remote configuration", (long)newURLs.count, newURLs.count == 1 ? @"" : @"s"]];
        NSLog(@"✅ Loaded %ld URLs from remote config", (long)newURLs.count);
    } else {
        [self showAlert:@"No Valid URLs" message:@"No valid URLs found in remote configuration"];
    }
}

- (void)clearAll:(id)sender {
    if (self.urls.count == 0) {
        [self showAlert:@"No URLs" message:@"There are no URLs to clear"];
        return;
    }

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Clear All URLs?";
    alert.informativeText = [NSString stringWithFormat:@"This will delete all %ld stored URLs. This action cannot be undone.", (long)self.urls.count];
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"Clear All"];
    [alert addButtonWithTitle:@"Cancel"];

    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self.urls removeAllObjects];
        [self saveSettings];
        [self.tableView reloadData];
        [self updateStatusLabel];
        NSLog(@"🗑 Cleared all URLs");
    }
}

- (void)showTimingSettings:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Timing Settings";
    alert.informativeText = @"Adjust rotation timing parameters:";
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"Save"];
    [alert addButtonWithTitle:@"Cancel"];

    NSView *formView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 320, 120)];

    // Scroll Duration
    NSTextField *scrollLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 90, 180, 20)];
    scrollLabel.stringValue = @"Scroll Duration (5-30s):";
    scrollLabel.editable = NO;
    scrollLabel.bordered = NO;
    scrollLabel.drawsBackground = NO;
    [formView addSubview:scrollLabel];

    NSTextField *scrollField = [[NSTextField alloc] initWithFrame:NSMakeRect(185, 90, 135, 24)];
    scrollField.doubleValue = self.scrollDuration;
    scrollField.placeholderString = [NSString stringWithFormat:@"%.1f", kDefaultScrollDuration];
    [formView addSubview:scrollField];

    // Page Load Delay
    NSTextField *loadLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 60, 180, 20)];
    loadLabel.stringValue = @"Page Load Delay (0.5-10s):";
    loadLabel.editable = NO;
    loadLabel.bordered = NO;
    loadLabel.drawsBackground = NO;
    [formView addSubview:loadLabel];

    NSTextField *loadField = [[NSTextField alloc] initWithFrame:NSMakeRect(185, 60, 135, 24)];
    loadField.doubleValue = self.pageLoadDelay;
    loadField.placeholderString = [NSString stringWithFormat:@"%.1f", kDefaultPageLoadDelay];
    [formView addSubview:loadField];

    // Post-Scroll Delay
    NSTextField *postLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 30, 180, 20)];
    postLabel.stringValue = @"Post-Scroll Delay (1-60s):";
    postLabel.editable = NO;
    postLabel.bordered = NO;
    postLabel.drawsBackground = NO;
    [formView addSubview:postLabel];

    NSTextField *postField = [[NSTextField alloc] initWithFrame:NSMakeRect(185, 30, 135, 24)];
    postField.doubleValue = self.postScrollDelay;
    postField.placeholderString = [NSString stringWithFormat:@"%.1f", kDefaultPostScrollDelay];
    [formView addSubview:postField];

    alert.accessoryView = formView;

    if ([alert runModal] == NSAlertFirstButtonReturn) {
        double newScroll = scrollField.doubleValue;
        double newLoad = loadField.doubleValue;
        double newPost = postField.doubleValue;

        BOOL hasChanges = NO;
        NSMutableString *invalid = [NSMutableString string];

        if (newScroll >= kMinScrollDuration && newScroll <= kMaxScrollDuration) {
            if (fabs(self.scrollDuration - newScroll) > 0.01) {
                self.scrollDuration = newScroll;
                hasChanges = YES;
            }
        } else if (newScroll != 0) {
            [invalid appendFormat:@"Scroll Duration must be between %.1f and %.1f seconds\n", kMinScrollDuration, kMaxScrollDuration];
        }

        if (newLoad >= kMinPageLoadDelay && newLoad <= kMaxPageLoadDelay) {
            if (fabs(self.pageLoadDelay - newLoad) > 0.01) {
                self.pageLoadDelay = newLoad;
                hasChanges = YES;
            }
        } else if (newLoad != 0) {
            [invalid appendFormat:@"Page Load Delay must be between %.1f and %.1f seconds\n", kMinPageLoadDelay, kMaxPageLoadDelay];
        }

        if (newPost >= kMinPostScrollDelay && newPost <= kMaxPostScrollDelay) {
            if (fabs(self.postScrollDelay - newPost) > 0.01) {
                self.postScrollDelay = newPost;
                hasChanges = YES;
            }
        } else if (newPost != 0) {
            [invalid appendFormat:@"Post-Scroll Delay must be between %.1f and %.1f seconds", kMinPostScrollDelay, kMaxPostScrollDelay];
        }

        if (invalid.length > 0) {
            [self showAlert:@"Invalid Values" message:invalid];
        }

        if (hasChanges) {
            [self saveSettings];
            [self updateStatusLabel];
            NSLog(@"✅ Timing settings updated");
        }
    }
}

- (void)closeWindow:(id)sender {
    [self.window close];
    [[NSApplication sharedApplication] stopModal];
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = title;
    alert.informativeText = message;
    alert.alertStyle = NSAlertStyleInformational;
    [alert runModal];
}

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.urls.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < self.urls.count) {
        return self.urls[row];
    }
    return nil;
}

@end
