//
//  TDMapSelectorViewController.m
//  CoopTD
//
//  Created by Rémy Bardou on 24/10/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDMapSelectorViewController.h"
#import "TDViewController.h"

@interface TDMapSelectorViewController ()

@end

@implementation TDMapSelectorViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self.maps = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self) {
		self.maps = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		self.maps = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Map list";
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	[self loadMaps];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadMaps {
	[self.maps removeAllObjects];
	
	NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
	
	NSError * error;
	NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:&error];
	
	if (!error) {
		for (NSString *file in directoryContents) {
			if ([file hasSuffix:@".tmx"]) {
				[self.maps addObject:file];
			}
		}
	}
	
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.maps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	NSString *map = self.maps[indexPath.row];
	cell.textLabel.text = [map stringByDeletingPathExtension];
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSIndexPath *path = [self.tableView indexPathForSelectedRow];
	
	if (path.row >= self.maps.count) {
		return;
	}
	
	NSString *mapName = self.maps[path.row];
	if ([segue.destinationViewController isKindOfClass:[TDViewController class]]) {
		TDViewController *vc = segue.destinationViewController;
		vc.mapFilename = mapName;
	}
}

@end
