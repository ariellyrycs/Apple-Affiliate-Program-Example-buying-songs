//
//  ViewController.m
//  appleAffilieteProgram
//
//  Created by Ariel Robles on 4/12/15.
//  Copyright (c) 2015 Ariel Robles. All rights reserved.
//
#import "ViewController.h"
#import "AFNetworking.h"
#import "SongModel.h"
#import "NSString+Track.h"
#import "SongTableViewCell.h"
#import <Foundation/Foundation.h>


static NSString *simpleTableIdentifier = @"SongCell";
static NSString *PHGAffiliateToken = @"1010lqc";

@interface ViewController ()
- (IBAction)search:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray* songs;
@property NSMutableArray *responseObject;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    SongModel * song = [SongModel new];
    self.songs =  [NSMutableArray new];
    song.artistName = @"Green Day";
    song.songName = @"American Idiot";
    song.albumName = @"American Idiot";
    [self.songs addObject:song];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)search:(id)sender {
    [self.searchBar resignFirstResponder];
    NSString *URIEncodeSearch = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager new];
    [manager GET:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&limit=25&media=music&entity=song", URIEncodeSearch] parameters:nil success:^(AFHTTPRequestOperation *operation, id result) {
        self.responseObject = [result objectForKey:@"results"];
        if ([self.responseObject count] > 0) {
            NSLog(@"[%lu] unfiltered songs retrieved from apple search api", (unsigned long)[self.responseObject count]);
            /*NSDictionary *filteredResult = [[self class] filterResults:self.responseObject ToMatchTrack:self.songs[0]];
            if (!filteredResult) {
                NSLog(@"Filtering may be too strict, we got [%lu] results from apple search api but none past our filter", (unsigned long)[self.responseObject count]);
                return;
            } */
            [self.table reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@, %@", error, error.localizedDescription);
    }];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.responseObject.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = (SongTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NSDictionary * songInfo = [self.responseObject objectAtIndex:indexPath.row];
    cell.songName.text = [songInfo objectForKey:@"trackName"];
    cell.artistName.text = [songInfo objectForKey:@"artistName"];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary * songInfo = [self.responseObject objectAtIndex:indexPath.row];
    NSLog(@"%@", songInfo);
    [self presentAppStoreForID:[songInfo objectForKey:@"trackId"] withDelegate:self];
}

- (void)presentAppStoreForID:(NSString *)appStoreID withDelegate:(id<SKStoreProductViewControllerDelegate>)delegate{
    SKStoreProductViewController *storeController = [SKStoreProductViewController new];
    storeController.delegate = delegate;
    [storeController loadProductWithParameters:@{
                                                 SKStoreProductParameterITunesItemIdentifier: appStoreID,
                                                 SKStoreProductParameterAffiliateToken: PHGAffiliateToken
                                                }
                               completionBlock:^(BOOL result, NSError *error) {
                                    if (result) {
                                        [self presentViewController:storeController animated:YES completion:nil];
                                    } else {
                                        [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"There was a problem opening the app store" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                                    }
                                }];
}

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:viewController completion:nil];
}














+ (NSDictionary *)filterResults:(NSArray *)results ToMatchTrack:(SongModel *)track
{
    NSLog(@"%@", results[0]);
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedTrack, NSDictionary *bindings){
        BOOL result =
        ([track.songName isLooselyEqualToString:evaluatedTrack[@"trackName"]] &&
         [track.artistName isLooselyEqualToString:evaluatedTrack[@"artistName"]] &&
         [track.albumName isLooselyEqualToString:evaluatedTrack[@"collectionName"]]);
        NSLog(@"match?[%d]", result);
        return result;
    }];
    return [[results filteredArrayUsingPredicate:predicate] firstObject];
}
@end
