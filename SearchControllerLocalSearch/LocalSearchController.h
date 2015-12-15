//
//  LocalSearchController.h
//  SearchControllerLocalSearch
//
//  Created by Sebastian Stadtlich on 15.12.15.
//  Copyright © 2015 Sebastian Stadtlich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol LocalSearchControllerDelegate <NSObject>
@optional
- (void) didSelectCoordinate:(CLLocationCoordinate2D) coordinate;
- (void) didSelectMKMapItem:(MKMapItem*) item;
@end

@interface LocalSearchController : UITableViewController <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

    // @property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic,weak) id <LocalSearchControllerDelegate> delegate;
@end
