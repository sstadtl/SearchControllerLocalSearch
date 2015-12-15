//
//  ViewController.m
//  SearchControllerLocalSearch
//
//  Created by Sebastian Stadtlich on 15.12.15.
//  Copyright © 2015 Sebastian Stadtlich. All rights reserved.
//

#import "ViewController.h"
#import "LocalSearchController.h"

@interface ViewController () <LocalSearchControllerDelegate>
@property (nonatomic, strong) UISearchController *searchController;
    // our secondary search results table view UISearchControllerMKLocalSearch
@property (nonatomic, strong) LocalSearchController *resultsTableController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    _resultsTableController = [[LocalSearchController alloc] init];
    _resultsTableController.delegate = self;
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
        //     _resultsTableController.searchController = _searchController;
    self.searchController.searchResultsUpdater = _resultsTableController;
    [self.searchController.searchBar sizeToFit];
    
    self.resultsTableController.tableView.delegate = _resultsTableController;
    self.searchController.delegate = _resultsTableController;
    self.searchController.dimsBackgroundDuringPresentation = YES; // default is YES
    self.searchController.searchBar.delegate = _resultsTableController; // so we can monitor text changes + others
    
    
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    
    
    UIView *viewTemp = [[UIView alloc] initWithFrame:CGRectMake(0, 64, width, 44)];
    viewTemp.backgroundColor = [UIColor greenColor];
    [viewTemp addSubview:_searchController.searchBar];
    [self.view addSubview:viewTemp];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}
#pragma GeoSearchHelperProtocol
- (void) didSelectCoordinate:(CLLocationCoordinate2D) coordinate {
    NSLog(@"did send back coodinate latitude:%f longitude:%f",coordinate.latitude,coordinate.longitude);
    if (_searchController.active) {
        _searchController.active = NO;
    }
}
- (void) didSelectMKMapItem:(MKMapItem*) item {
    NSLog(@"didSelectMKMapItem:%@",item);
    if (_searchController.active) {
        _searchController.active = NO;
    }
}

@end
