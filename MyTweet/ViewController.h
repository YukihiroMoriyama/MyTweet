//
//  ViewController.h
//  MyTweet
//
//  Created by yukihiro moriyama on 2015/02/27.
//  Copyright (c) 2015年 YukihiroMoriyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface ViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *array;
    IBOutlet UITableView *timelineTableView;
}
-(void)twitterTimeline;

-(IBAction)tweetButton;
-(IBAction)refreshButton;
@end

