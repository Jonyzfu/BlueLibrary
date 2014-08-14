//
//  ViewController.m
//  BlueLibrary
//
//  Created by Eli Ganem on 31/7/13.
//  Copyright (c) 2013 Eli Ganem. All rights reserved.
//

#import "ViewController.h"
#import "LibraryAPI.h"
#import "Album+TableRepresentation.h"
#import "HorizontalScroller.h"
#import "AlbumView.h"


// This is how to make your delegateion conform to protocol
@interface ViewController () <UITableViewDataSource, UITableViewDelegate, HorizontalScollerDelegate>
{
    UITableView *dataTable;
    NSArray *allAlbums;
    NSDictionary *currentAlbumData;
    int currentAlbumIndex;
    HorizontalScroller *scoller;
    
    UIToolbar *toolbar;
    // We will use this array as a stack to push and pop operation for the undo option
    NSMutableArray *undoStack;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Change the background color to a nice navy blue color.
    self.view.backgroundColor = [UIColor colorWithRed:0.76f green:0.81f blue:0.87f alpha:1];
    currentAlbumIndex = 0;
    
    toolbar = [[UIToolbar alloc] init];
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoAction)];
    undoItem.enabled = NO;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAlbum)];
    [toolbar setItems:@[undoItem, space, delete]];
    [self.view addSubview:toolbar];
    undoStack = [[NSMutableArray alloc] init];
    
    
    // Get a list of all the albums via the API. You don’t use PersistencyManager directly!
    allAlbums = [[LibraryAPI sharedInstance] getAlbums];
    
    // This is where you create the UITableView.
    // The UITableView that presents the ablum data.
    dataTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height - 120) style:UITableViewStyleGrouped];
    dataTable.delegate = self;
    dataTable.dataSource = self;
    dataTable.backgroundView = nil;
    [self.view addSubview:dataTable];
    
    [self loadPreviousState];
    
    // initialize the scroller
    scoller = [[HorizontalScroller alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120)];
    scoller.backgroundColor = [UIColor colorWithRed:0.24f green:0.35f blue:0.49f alpha:1];
    scoller.delegate = self;
    [self.view addSubview:scoller];
    [self reloadScroller];
    
    [self showDataForAlbumAtIndex:0];
    
    // when the app is about to enter the background, the ViewController will automatically save the current state by calling saveCurrentState.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCurrentState) name:UIApplicationDidEnterBackgroundNotification object:nil];
}


- (void)viewWillLayoutSubviews
{
    toolbar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    dataTable.frame = CGRectMake(0, 130, self.view.frame.size.width, self.view.frame.size.height - 200);
}

- (void)addAlbum:(Album *)album atIndex:(int)index
{
    [[LibraryAPI sharedInstance] addAlbum:album atIndex:index];
    currentAlbumIndex = index;
    [self reloadScroller];
}

- (void)deleteAlbum
{
    // Get the album to delete.
    Album *deleteAlbum = allAlbums[currentAlbumIndex];
    
    // Define an object of type NSMethodSignature to create the NSInvocation, which will be used to reverse the delete action if the user later decides to undo a deletion.
    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(addAlbum:atIndex:)];
    NSInvocation *undoAction = [NSInvocation invocationWithMethodSignature:sig];
    [undoAction setTarget:self];
    [undoAction setSelector:@selector(addAlbum:atIndex:)];
    [undoAction setArgument:&deleteAlbum atIndex:2];
    [undoAction setArgument:&currentAlbumIndex atIndex:3];
    [undoAction retainArguments];
    
    // This action will be added to the end of the array, just as in a normal stack.
    [undoStack addObject:undoAction];
    
    // Use LibraryAPI to delete the album from the data structure and reload the scroller.
    [[LibraryAPI sharedInstance] deleteAlbumAtIndex:currentAlbumIndex];
    [self reloadScroller];
    
    // Since there’s an action in the undo stack, you need to enable the undo button.
    [toolbar.items[0] setEnabled:YES];
}

- (void)undoAction
{
    // This is also a good place to test out whether changes to your album data is retained between sessions.
    if (undoStack.count > 0) {
        NSInvocation *invocation = [undoStack lastObject];
        [undoStack removeLastObject];
        [invocation invoke];
    }
    
    if (undoStack.count == 0) {
        [toolbar.items[0] setEnabled:NO];
    }
}

// returns the number of rows to display in the table view, which matches the number of titles in the data structure.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [currentAlbumData[@"titles"] count];
}

// creates and returns a cell with the title and its value.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = currentAlbumData[@"titles"][indexPath.row];
    cell.detailTextLabel.text = currentAlbumData[@"values"][indexPath.row];
    
    return cell;
}


// fetches the required album data from the array of albums.
- (void)showDataForAlbumAtIndex:(int)albumAtIndex
{
    // defensive code: make sure the requested index is lower than the amount of albums.
    if (albumAtIndex < allAlbums.count) {
        // fetch the album
        Album *album = allAlbums[albumAtIndex];
        // save the albums data to present it later in the tableview.
        currentAlbumData = [album tr_tableRepresentation];
    } else {
        currentAlbumData = nil;
    }
    
    // refresh the tableview.
    [dataTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// saves the current album index to NSUserDefaults – NSUserDefaults is a standard data store provided by iOS for saving application specific settings and data.
- (void)saveCurrentState
{
    // When the user leaves the app and then comes back again, he wants it to be in the exact same state
    // he left it. In order to do this we need to save the currently displayed album.
    // Since it's only one piece of information we can use NSUserDefaults.
    [[NSUserDefaults standardUserDefaults] setInteger:currentAlbumIndex forKey:@"currentAlbumIndex"];
    
    [[LibraryAPI sharedInstance] saveAlbums];
}

// loads the previously saved index.
- (void)loadPreviousState
{
    currentAlbumIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentAlbumIndex"];
    [self showDataForAlbumAtIndex:currentAlbumIndex];
}

// It’s common practice to place methods that fit together after a #pragma mark directive.
#pragma mark - HorizontalScrollerDelegate methods
- (void)horizontalScroller:(HorizontalScroller *)scroller clickedViewAtIndex:(int)index
{
    currentAlbumIndex = index;
    [self showDataForAlbumAtIndex:index];
}

- (NSInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller *)scroller
{
    // the protocol method returning the number of views for the scroll view.
    return allAlbums.count;
}

- (UIView *)horizontalScroller:(HorizontalScroller *)scroller viewAtIndex:(int)index
{
    Album *album = allAlbums[index];
    
    // create a new AlbumView and pass it to the HorizontalScroller.
    return [[AlbumView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) albumCover:album.coverUrl];
}

- (void)reloadScroller
{
    allAlbums = [[LibraryAPI sharedInstance] getAlbums];
    if (currentAlbumIndex < 0) {
        currentAlbumIndex = 0;
    } else if (currentAlbumIndex >= allAlbums.count) {
        currentAlbumIndex = allAlbums.count - 1;
    }
    [scoller reload];
    [self showDataForAlbumAtIndex:currentAlbumIndex];
}

- (NSInteger)initialViewIndexForHorizontalScroller:(HorizontalScroller *)scroller
{
    return currentAlbumIndex;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
