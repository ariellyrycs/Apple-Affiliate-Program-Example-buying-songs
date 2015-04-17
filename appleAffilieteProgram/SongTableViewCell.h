//
//  SongTableViewCell.h
//  appleAffilieteProgram
//
//  Created by Ariel Robles on 4/15/15.
//  Copyright (c) 2015 Ariel Robles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (weak, nonatomic) IBOutlet UILabel *artistName;

@end
