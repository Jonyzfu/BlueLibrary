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


// This is how to make your delegateion conform to protocol
@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *dataTable;
    NSArray *allAlbums;
    NSDictionary *currentAlbumData;
    int currentAlbumIndex;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Change the background color to a nice navy blue color.
    self.view.backgroundColor = [UIColor colorWithRed:0.76f green:0.81f blue:0.87f alpha:1];
    currentAlbumIndex = 0;
    
    // Get a list of all the albums via the API. You don’t use PersistencyManager directly!
    allAlbums = [[LibraryAPI sharedInstance] getAlbums];
    
    // This is where you create the UITableView.
    // The UITableView that presents the ablum data.
    dataTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height - 120) style:UITableViewStyleGrouped];
    dataTable.delegate = self;
    dataTable.dataSource = self;
    dataTable.backgroundView = nil;
    [self.view addSubview:dataTable];
    [self showDataForAlbumAtIndex:currentAlbumIndex];
    
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

@end
