//
//  DBBackUpViewController.m
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 08/05/14
//  Copyright (c) 2014 iRare Media. All rights reserved.
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2014 Daniel Bierwirth and iRare Media
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//

#import "DBBackUpViewController.h"
#import "DropboxCell.h"
#import "AttachmentPreviewVC.h"
#import <QuickLook/QuickLook.h>
#import "SSZipArchive.h"
#import "Utilities.h"
#import "WebService.h"

// Check for ARC
#if !__has_feature(objc_arc)
// Add the -fobjc-arc flag to enable ARC for only these files, as described in the ARC documentation: http://clang.llvm.org/docs/AutomaticReferenceCounting.html
#error DropboxBrowser is built with Objective-C ARC. You must enable ARC for DropboxBrowser.
#endif

// View tags to differeniate alert views
static NSUInteger const kDBSignInAlertViewTag = 1;
static NSUInteger const kFileExistsAlertViewTag = 2;
static NSUInteger const kDBSignOutAlertViewTag = 3;

@interface DBBackUpViewController () <DBRestClientDelegate>

@property (nonatomic, strong, readwrite) UIProgressView *downloadProgressView;

@property (nonatomic, strong, readwrite) NSString *currentFileName;
@property (nonatomic, strong, readwrite) NSString *currentPath;

@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) DBMetadata *selectedFile;

@property (nonatomic, assign) BOOL isLocalFileOverwritten;
@property (nonatomic, assign) BOOL isSearching;

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundProcess;

@property (nonatomic, strong) DBBackUpViewController *subdirectoryController;

@property (nonatomic, assign) BOOL isShowingLoginAlertView;

@property (nonatomic, strong) NSMutableArray *arrayOfDownloadedFiles;


- (DBRestClient *)restClient;

- (void)updateTableData;

- (void)downloadedFile;
- (void)startDownloadFile;
- (void)downloadedFileFailed;
- (void)updateDownloadProgressTo:(CGFloat)progress;

- (BOOL)listDirectoryAtPath:(NSString *)path;

-(void)DBupload:(id)sender;


@end

@implementation DBBackUpViewController

//------------------------------------------------------------------------------------------------------------//
//------- View Lifecycle -------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark  - View Lifecycle

- (instancetype)init {
    self = [super init];
    if (self)  {
        // Custom initialization
        // [self basicSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom Init
        // [self basicSetup];
    }
    return self;
}

- (void)basicSetup {
    _currentPath = @"/";
    _isLocalFileOverwritten = NO;
    NSString *dropboxPath = [DBBackUpViewController dropboxPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dropboxPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dropboxPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *thumbnailFolder = [dropboxPath stringByAppendingPathComponent:@"thumbnail"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:thumbnailFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (self.arrayOfSelectedFiles == nil) {
        self.arrayOfSelectedFiles = [NSMutableArray array];
    }
    
    if (self.arrayOfDownloadedFiles == nil) {
        self.arrayOfDownloadedFiles = [NSMutableArray array];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.hidden = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.leftBarButtonItem = nil;
    // [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // [self.tableView registerNib:[UINib nibWithNibName:@"DropboxCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    // Set Title and Path
    if (self.title == nil || [self.title isEqualToString:@""]) self.title = @"Dropbox";
    if (self.currentPath == nil || [self.currentPath isEqualToString:@""]) self.currentPath = @"/";
    
    /* if (self.isSubDirectory == NO) {
     UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closePage)];
     // UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutDropbox)];
     self.navigationItem.leftBarButtonItem = cancelButton;
     }
     
     [self setNavBarRightDoneButton];
     
     if (self.shouldDisplaySearchBar == YES) {
     // Create Search Bar
     UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -44, 320, 44)];
     searchBar.delegate = self;
     searchBar.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Search %@", @"DropboxBrowser: Search Field Placeholder Text. Search 'CURRENT FOLDER NAME'"), self.title];
     self.tableView.tableHeaderView = searchBar;
     
     // Setup Search Controller
     UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
     searchController.searchResultsDataSource = self;
     searchController.searchResultsDelegate = self;
     searchController.delegate = self;
     self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
     }
     
     // Add Download Progress View to Navigation Bar
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
     // The user is on an iPad - Add progressview
     UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
     CGFloat yOrigin = self.navigationController.navigationBar.bounds.size.height-newProgressView.bounds.size.height;
     CGFloat widthBoundary = self.navigationController.navigationBar.bounds.size.width;
     CGFloat heigthBoundary = newProgressView.bounds.size.height;
     newProgressView.frame = CGRectMake(0, yOrigin, widthBoundary, heigthBoundary);
     
     newProgressView.alpha = 0.0;
     newProgressView.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
     newProgressView.trackTintColor = [UIColor lightGrayColor];
     
     [self.navigationController.navigationBar addSubview:newProgressView];
     [self setDownloadProgressView:newProgressView];
     } else {
     // The user is on an iPhone / iPod Touch - Add progressview
     UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
     CGFloat yOrigin = self.navigationController.navigationBar.bounds.size.height-newProgressView.bounds.size.height;
     CGFloat widthBoundary = self.navigationController.navigationBar.bounds.size.width;
     CGFloat heigthBoundary = newProgressView.bounds.size.height;
     newProgressView.frame = CGRectMake(0, yOrigin, widthBoundary, heigthBoundary);
     
     newProgressView.alpha = 0.0;
     newProgressView.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
     newProgressView.trackTintColor = [UIColor lightGrayColor];
     
     [self.navigationController.navigationBar addSubview:newProgressView];
     [self setDownloadProgressView:newProgressView];
     }
     
     // Add a refresh control, pull down to refresh
     if ([UIRefreshControl class]) {
     UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
     refreshControl.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
     [refreshControl addTarget:self action:@selector(updateContent) forControlEvents:UIControlEventValueChanged];
     self.refreshControl = refreshControl;
     }
     */
    
    // Initialize Directory Content
    
    if ([self.currentPath isEqualToString:@"/"]) {
        [self listDirectoryAtPath:@"/"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    if (![self isDropboxLinked]) {
        [self loginOfDropbox];
        return;
    }
    else{
        //[self updateContent];
    }
    if ([self isDropboxLinked])
    {
        self.tableView.hidden = NO;
        self.navigationController.navigationBarHidden = YES;
        UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(40, 70, 300, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter; // UITextAlignmentCenter, UITextAlignmentLeft
        label.textColor=[UIColor blackColor];
        [self.tableView addSubview:label];
        self.tableView.separatorColor =[UIColor clearColor];
        label.center = self.tableView.center;
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.tableView addSubview:spinner];
        spinner.center = label.center;
        [spinner startAnimating];
        if (self.isChatBackup) {
            
            label.text = @"Backup Data...";
            [self DBupload:nil];
        }
        if (self.isRestoreBackup) {
            label.text = @"Restore Data...";
            [self DBdownload:nil];
        }
    }    //[self setNavBarRightDoneButton];
    
}
-(void)DBOperation
{
    //    if (![self isDropboxLinked]) {
    //        [self loginOfDropbox];
    //        return;
    //    }
    //    else{
    //        //[self updateContent];
    //    }
    //     if ([self isDropboxLinked])
    //     {
    //         if (self.isChatBackup) {
    //             self.tableView.hidden = YES;
    //             [self DBupload:nil];
    //         }
    //         if (self.isRestoreBackup) {
    //             self.tableView.hidden = YES;
    //             [self DBdownload:nil];
    //         }
    //     }
    
    
}
- (void)loginOfDropbox
{
    if (self.isShowingLoginAlertView == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login to Dropbox", @"DropboxBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"%@ is not linked to your Dropbox. Would you like to login now and allow access?", @"DropboxBrowser: Alert Message. 'APP NAME' is not linked to Dropbox..."), [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"DropboxBrowser: Alert Button") otherButtonTitles:NSLocalizedString(@"Login", @"DropboxBrowser: Alert Button"), nil];
        alertView.tag = kDBSignInAlertViewTag;
        [alertView show];
        self.isShowingLoginAlertView = YES;
    }
}

- (void)logoutOfDropbox {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Logout of Dropbox", @"DropboxBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to logout of Dropbox and revoke Dropbox access for %@?", @"DropboxBrowser: Alert Message. ...revoke Dropbox access for 'APP NAME'"), [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"DropboxBrowser: Alert Button") otherButtonTitles:NSLocalizedString(@"Logout", @"DropboxBrowser: Alert Button"), nil];
    alertView.tag = kDBSignInAlertViewTag;
    [alertView show];
}

//------------------------------------------------------------------------------------------------------------//
//------- Table View -----------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.fileList count] == 0) {
        // There are no files in the directory - let the user know
        if (indexPath.row == 1) {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            
            if (self.isSearching == YES) {
                cell.textLabel.text = NSLocalizedString(@"No Search Results", @"DropboxBrowser: Empty Search Results Text");
            } else {
                cell.textLabel.text = NSLocalizedString(@"Folder is Empty", @"DropboxBroswer: Empty Folder Text");
            }
            
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor darkGrayColor];
            
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
    } else {
        // Check if the table cell ID has been set, otherwise create one
        if (!self.tableCellID || [self.tableCellID isEqualToString:@""]) {
            self.tableCellID = @"cell";
        }
        
        // Create the table view cell
        DropboxCell *cell = [tableView dequeueReusableCellWithIdentifier:self.tableCellID];
        
        // Configure the Dropbox Data for the cell
        DBMetadata *file = (DBMetadata *)(self.fileList)[indexPath.row];
        [cell setCellData:file];
        if ([self.arrayOfSelectedFiles containsObject:file]) {
            cell.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
        }
        else{
            cell.backgroundColor = [UIColor clearColor];
        }
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == nil)
        return;
    if ([self.fileList count] == 0) {
        // Do nothing, there are no items in the list. We don't want to download a file that doesn't exist (that'd cause a crash)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        self.selectedFile = (DBMetadata *)(self.fileList)[indexPath.row];
        if ([self.selectedFile isDirectory]) {
            // Create new UITableViewController
            self.subdirectoryController = [[DBBackUpViewController alloc] init];
            self.subdirectoryController.rootViewDelegate = self.rootViewDelegate;
            NSString *subpath = [self.currentPath stringByAppendingPathComponent:self.selectedFile.filename];
            self.subdirectoryController.currentPath = subpath;
            self.subdirectoryController.title = [subpath lastPathComponent];
            self.subdirectoryController.shouldDisplaySearchBar = self.shouldDisplaySearchBar;
            self.subdirectoryController.deliverDownloadNotifications = self.deliverDownloadNotifications;
            self.subdirectoryController.allowedFileTypes = self.allowedFileTypes;
            self.subdirectoryController.tableCellID = self.tableCellID;
            self.subdirectoryController.arrayOfSelectedFiles = self.arrayOfSelectedFiles;
            [self.subdirectoryController listDirectoryAtPath:subpath];
            self.subdirectoryController.isSubDirectory = YES;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [self.navigationController pushViewController:self.subdirectoryController animated:YES];
        } else {
            
            if ([self.arrayOfSelectedFiles containsObject:self.selectedFile] == YES) {
                [self.arrayOfSelectedFiles removeObject:self.selectedFile];
            }
            else{
                [self.arrayOfSelectedFiles addObject:self.selectedFile];
            }
            
            [self.tableView reloadData];
            [self setNavBarRightDoneButton];
            
            /*
             self.currentFileName = self.selectedFile.filename;
             
             // Check if our delegate handles file selection
             if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didSelectFile:)]) {
             [self.rootViewDelegate dropboxBrowser:self didSelectFile:self.selectedFile];
             } else if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:selectedFile:)]) {
             #pragma clang diagnostic push
             #pragma clang diagnostic ignored "-Wdeprecated-declarations"
             [self.rootViewDelegate dropboxBrowser:self selectedFile:self.selectedFile];
             #pragma clang diagnostic pop
             } else {
             // Download file
             [self downloadFile:self.selectedFile replaceLocalVersion:NO];
             }
             */
        }
        
    }
}

//------------------------------------------------------------------------------------------------------------//
//------- SearchBar Delegate ---------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - SearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [[self restClient] searchPath:self.currentPath forKeyword:searchBar.text];
    [searchBar resignFirstResponder];
    
    // We are no longer searching the directory
    self.isSearching = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // We are no longer searching the directory
    self.isSearching = NO;
    
    // Dismiss the Keyboard
    [searchBar resignFirstResponder];
    
    // Reset the data and reload the table
    [self listDirectoryAtPath:self.currentPath];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // We are searching the directory
    self.isSearching = YES;
    
    if ([searchBar.text isEqualToString:@""] || searchBar.text == nil) {
        // [searchBar resignFirstResponder];
        [self listDirectoryAtPath:self.currentPath];
    } else if (![searchBar.text isEqualToString:@" "] || ![searchBar.text isEqualToString:@""]) {
        [[self restClient] searchPath:self.currentPath forKeyword:searchBar.text];
    }
}

//------------------------------------------------------------------------------------------------------------//
//------- AlertView Delegate ---------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kDBSignInAlertViewTag) {
        switch (buttonIndex) {
            case 0:
                [self removeDropboxBrowser];
                break;
            case 1:
                [[DBSession sharedSession] linkFromController:self];
                break;
            default:
                break;
        }
        self.isShowingLoginAlertView = NO;
    } else if (alertView.tag == kFileExistsAlertViewTag) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                // User selected overwrite
                [self downloadFile:self.selectedFile replaceLocalVersion:YES];
                break;
            default:
                break;
        }
    } else if (alertView.tag == kDBSignOutAlertViewTag) {
        switch (buttonIndex) {
            case 0: break;
            case 1: {
                [[DBSession sharedSession] unlinkAll];
                [self removeDropboxBrowser];
            } break;
            default:
                break;
        }
    }
    else
    {
        [self closePage];
    }
}

//------------------------------------------------------------------------------------------------------------//
//------- Content Refresh ------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Content Refresh

- (void)updateTableData {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)updateContent {
    [self listDirectoryAtPath:self.currentPath];
}

//------------------------------------------------------------------------------------------------------------//
//------- DataController Delegate ----------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - DataController Delegate

- (void)removeDropboxBrowser {
    
    if(self.arrayOfSelectedFiles.count)
    {
        [self processSelectedFiles];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:^{
            if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowserDismissed:)])
                [[self rootViewDelegate] dropboxBrowserDismissed:self];
        }];
    }
    
}

- (void)downloadedFile:(NSString*)filePath {
    self.tableView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.75 animations:^{
        self.tableView.alpha = 1.0;
        self.downloadProgressView.alpha = 0.0;
    }];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    if (filePath) { // check if file exists - if so load it:
        [SSZipArchive unzipFileAtPath:filePath toDestination:documentsDirectory delegate:self];
    }
       // End the background task
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundProcess];

    [self closePage];
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
}

- (void)startDownloadFile {
    [self.downloadProgressView setProgress:0.0];
    [UIView animateWithDuration:0.75 animations:^{
        self.downloadProgressView.alpha = 1.0;
    }];
}

- (void)downloadedFileFailed {
    //  self.tableView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.75 animations:^{
        self.tableView.alpha = 1.0;
        self.downloadProgressView.alpha = 0.0;
    }];
    
    // End the background task
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundProcess];
    [self closePage];
}

- (void)updateDownloadProgressTo:(CGFloat)progress {
    [self.downloadProgressView setProgress:progress];
}

//------------------------------------------------------------------------------------------------------------//
//------- Files and Directories ------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Dropbox File and Directory Functions

- (BOOL)listDirectoryAtPath:(NSString *)path {
    if ([self isDropboxLinked]) {
        
        [[self restClient] loadMetadata:path];
        return YES;
    } else return NO;
}

- (BOOL)isDropboxLinked {
    return [[DBSession sharedSession] isLinked];
}

//------------------------------------------------------------------------------------------------------------//
//------- Dropbox Delegate -----------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - DBRestClientDelegate Methods

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {

}

- (void)restClient:(DBRestClient *)client loadedSearchResults:(NSArray *)results forPath:(NSString *)path keyword:(NSString *)keyword {

}

- (void)restClient:(DBRestClient *)restClient searchFailedWithError:(NSError *)error {
    // [self updateTableData];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    //[self updateTableData];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath {
    [self downloadedFile:localPath];
    NSLog(@"localPath--%@",localPath);
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    [self downloadedFileFailed];
}

- (void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath {
    [self updateDownloadProgressTo:progress];
}

- (void)restClient:(DBRestClient *)client loadedSharableLink:(NSString *)link forFile:(NSString *)path {
    //    if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didLoadShareLink:)]) {
    //        [self.rootViewDelegate dropboxBrowser:self didLoadShareLink:link];
    //    }
}

- (void)restClient:(DBRestClient *)client loadSharableLinkFailedWithError:(NSError *)error {
    //    if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didFailToLoadShareLinkWithError:)]) {
    //        [self.rootViewDelegate dropboxBrowser:self didFailToLoadShareLinkWithError:error];
    //    } else if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:failedLoadingShareLinkWithError:)]) {
    //#pragma clang diagnostic push
    //#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //        [self.rootViewDelegate dropboxBrowser:self failedLoadingShareLinkWithError:error];
    //#pragma clang diagnostic pop
    //    }
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)localPath
{
    [self.tableView reloadData];
    
}
//------------------------------------------------------------------------------------------------------------//
//------- Deprecated Methods ---------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Deprecated Methods

- (NSString *)fileName {
    for (int i = 0; i <= 5; i++)
        NSLog(@"[DropboxBrowser] WARNING: The fileName method is deprecated. Use the currentFileName property instead. This method will become unavailable in a future version.");
    return self.currentFileName;
}

+ (NSString*)dropboxPath
{
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    documentsPath = [documentsPath stringByAppendingPathComponent:@"dropbox"];
    return documentsPath;
}

+(NSString*)dropboxFilePath:(NSString*)fileName
{
    return [[DBBackUpViewController dropboxPath] stringByAppendingPathComponent:fileName];
}


+(NSString*)localThumbnailPathForFile:(NSString*)fileName
{
    return [[[DBBackUpViewController dropboxPath] stringByAppendingPathComponent:@"thumbnail"] stringByAppendingPathComponent:fileName];
}

- (void)setNavBarRightDoneButton
{
    // Setup Navigation Bar, use different styles for iOS 7 and higher
    
    NSString *strDone = @"Done";
    if (self.arrayOfSelectedFiles.count > 0) {
        strDone = [NSString stringWithFormat:@"Send(%lu)",(unsigned long)self.arrayOfSelectedFiles.count];
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:strDone style:UIBarButtonItemStyleDone target:self action:@selector(removeDropboxBrowser)];
        // UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutDropbox)];
        self.navigationItem.rightBarButtonItem = rightButton;
        // self.navigationItem.leftBarButtonItem = leftButton;
    }
    else{
        self.navigationItem.rightBarButtonItem = nil;
    }
    
}

- (void)closePage
{
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
    // [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)processSelectedFiles
{
    if (self.arrayOfSelectedFiles.count > 0) {
        [self.arrayOfSelectedFiles enumerateObjectsUsingBlock:^(DBMetadata* file, NSUInteger idx, BOOL *stop) {
            [self downloadFile:file replaceLocalVersion:YES];
        }];
        
    }
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId;
{
    [session unlinkUserId:userId];
    if (![self isDropboxLinked]) {
        [self loginOfDropbox];
    }
}

- (void)downloadCompleted
{
    
}

- (void)sendFiles:(NSArray*)files
{
    [self.rootViewDelegate performSelector:@selector(sendFiles:) withObject:files];
}

- (void)willCloseAttachmentPreview:(NSMutableArray*)arrayOfFiles
{
    //    self.arrayOfSelectedFiles = [arrayOfFiles copy];
    //    [self.tableView reloadData];
    [self closePage];
}
-(void)DBupload:(id)sender

{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
    NSLog(@"files array %@", filePathsArray);
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",
                          documentsDirectory,@"DropBox.zip"];
    NSLog(@"sender id---%@",[Utilities getSenderId]);
    [SSZipArchive createZipFileAtPath:fileName withContentsOfDirectory:documentsDirectory];
    NSString *folder_name = [NSString stringWithFormat:@"/%@_Wing_chatBackup",[Utilities getSenderId]];
    [[self restClient] uploadFile:@"dropboxbackup.zip" toPath:folder_name fromPath:fileName];
    
}

-(void) DBdownload:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"dropboxbackup1.zip"];
   // NSError *error;
    NSString *folder_name = [NSString stringWithFormat:@"/%@_Wing_chatBackup",[Utilities getSenderId]];
    NSString *fileName = @"dropboxbackup.zip";
    NSString *downloadFilePath = [NSString stringWithFormat:@"/%@/%@",folder_name,fileName];
    [self.restClient loadFile:downloadFilePath intoPath:filePath];
    
    
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
          metadata:(DBMetadata*)metadata
{
    NSLog(@"uploadedFile--%@",destPath);
    NSLog(@"uploadedFile--%@",destPath);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wing" message:@"chat backup Sucess" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self updateBackUpStatus:@"1"];
    // [self closePage];
    
    
}
- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress
           forFile:(NSString*)destPath from:(NSString*)srcPath
{
    
    NSLog(@"uploadProgress--%f",progress);
    
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSLog(@"uploadFileFailedWithError--%@",error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wing" message:@" Chat Backup failed, Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self updateBackUpStatus:@"0"];
    
    //[self closePage];
}

// Deprecated upload callback
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
{
    NSLog(@"uploadedFile--%@",destPath);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wing" message:@"Chat Backup Success" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self updateBackUpStatus:@"1"];
    //[self closePage];
    
}

- (void)restClient:(DBRestClient *)client uploadFromUploadIdFailedWithError:(NSError *)error;
{
    
    NSLog(@"uploadFromUploadIdFailedWithError--%@",error);
    
}

- (void)updateBackUpStatus:(NSString *)flag
{
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy/MM/dd hh:mm:ss"];
    NSString* dateString = [f stringFromDate:[NSDate date]];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dict setObject:flag forKey:@"enable_backup"];
    [dict setObject:dateString forKey:@"backup_date"];
    
    [WebService runCMDBackUp:dict completionBlock:^(NSObject *responseObject, NSInteger errorCode)
     {
         NSLog(@"responseObject---%@",responseObject);
     }];
    
}


@end
