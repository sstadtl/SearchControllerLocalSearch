//
//  LocalSearchController.m
//  SearchControllerLocalSearch
//
//  Created by Sebastian Stadtlich on 15.12.15.
//  Copyright © 2015 Sebastian Stadtlich. All rights reserved.
//

#import "LocalSearchController.h"

@interface LocalSearchController ()

@property (nonatomic,strong) MKLocalSearch *localSearch;
@property (nonatomic,strong) MKLocalSearchResponse *results;
@property (nonatomic,strong) NSTimer *gpstimer;
@property (nonatomic,strong) NSMutableDictionary *cache;
@property BOOL isSearching;

@end

@implementation LocalSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    _cache = [[NSMutableDictionary alloc] initWithCapacity:20];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return 1;
    }
    return [_results.mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isSearching) {
        static NSString *IDENTIFIER2 = @"SearchResultsCellLoading";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDENTIFIER2];
            
        }
        cell.textLabel.text = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect frame = act.frame;
        frame.origin.x = ([UIScreen mainScreen].bounds.size.width / 2.0f) - (frame.size.width/2.0);
        frame.origin.y = 10.0;
        act.frame = frame;
        [cell addSubview:act];
        [act startAnimating];
        return cell;
    }
    
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = _results.mapItems[indexPath.row];
    NSString *stadtteil = item.placemark.addressDictionary[@"SubLocality"];
    if ((stadtteil!=nil) && (![stadtteil isEqualToString:@""]) && (![stadtteil isEqualToString:item.name]) ) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",item.name,stadtteil];
    } else {
        cell.textLabel.text = item.name;
    }
    
        // cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
        // cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"]; // FormattedAddressLines
    NSArray *placezeilen =item.placemark.addressDictionary[@"FormattedAddressLines"];
    cell.detailTextLabel.text = [placezeilen componentsJoinedByString:@", "];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"didSelectRowAtIndexPath:%@",_results.mapItems[indexPath.row]);
    
    MKMapItem *item = _results.mapItems[indexPath.row];
    
    if ([_delegate respondsToSelector:@selector(didSelectMKMapItem:)]) {
        [_delegate didSelectMKMapItem:item];
    }
    
    if ([_delegate respondsToSelector:@selector(didSelectCoordinate:)]) {
        [_delegate didSelectCoordinate:item.placemark.coordinate];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
}


#pragma mark - my local search
- (void) doLocalSearch:(NSString*)suche {
    [_localSearch cancel];
    MKLocalSearchResponse *cached = [_cache objectForKey:suche];
    if (cached!=nil) {
        _results = cached;
        _isSearching = NO;
            // [self searchControllerReload];
        [self.tableView reloadData];
        NSLog(@"Daten aus dem Cache");
        return;
    } else {
        _isSearching = YES;
    }
    
    _results = nil;
    [self.tableView reloadData];
    
    if (_gpstimer!=nil) {
        [_gpstimer invalidate];
        _gpstimer = nil;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _gpstimer = [NSTimer scheduledTimerWithTimeInterval: 0.9f
                                                 target: self
                                               selector:@selector(doLocalSearchStep2:)
                                               userInfo:suche
                                                repeats:NO];
}

- (void) doLocalSearchStep2:(NSTimer*) timer {
    NSLog(@"doLocalSearchStep2:%@",timer.userInfo);
    [self doLocalSearchStep3:timer.userInfo];
}

- (void) doLocalSearchStep3:(NSString*)suche {
    NSLog(@"doLocalSearchStep3:%@",suche);
    if ([suche isEqualToString:@""]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return;
    }
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = suche;
    _localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [_localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil) {
            NSLog(@"error:%@",error);
            return;
        }
        if ([response.mapItems count] == 0) {
            NSLog(@"No Results:%@",error);
            return;
        }
        [_cache setObject:response forKey:[NSString stringWithString:suche]];
        _results = response;
        self.isSearching = NO;
        [self.tableView reloadData];
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - UISearchControllerDelegate

- (void)presentSearchController:(UISearchController *)searchController {
    NSLog(@"presentSearchController");
}
- (void)willPresentSearchController:(UISearchController *)searchController {
        // do something before the search controller is presented
    NSLog(@"willPresentSearchController");
}

- (void)didPresentSearchController:(UISearchController *)searchController {
        // do something after the search controller is presented
    NSLog(@"didPresentSearchController");
}

- (void)willDismissSearchController:(UISearchController *)searchController {
        // do something before the search controller is dismissed
    NSLog(@"willDismissSearchController");
}

- (void)didDismissSearchController:(UISearchController *)searchController {
        // do something after the search controller is dismissed
    NSLog(@"didDismissSearchController");
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    NSLog(@"updateSearchResultsForSearchController");
    NSString *searchText = searchController.searchBar.text;
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [self doLocalSearch:strippedString];
    
}

@end
