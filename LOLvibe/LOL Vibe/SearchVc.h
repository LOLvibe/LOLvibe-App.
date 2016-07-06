//
//  SearchVc.h
//  LOLvibe
//
//  Created by Paras Navadiya on 26/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchVc : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITableView *tablePeoples;
    
    IBOutlet UITextField *txtSearchPeople;

    IBOutlet UICollectionView *collectionViewGrid;
    
    IBOutlet UIView *viewPeople;
    
    IBOutlet UIView *viewPost;
}
- (IBAction)btnFilter:(id)sender;

- (IBAction)btnSearch:(id)sender;

@end
