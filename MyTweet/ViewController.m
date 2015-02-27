//
//  ViewController.m
//  MyTweet
//
//  Created by yukihiro moriyama on 2015/02/27.
//  Copyright (c) 2015年 YukihiroMoriyama. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(IBAction)tweetButton {
    SLComposeViewController *twitterPostViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [self presentViewController:twitterPostViewController animated:YES completion:nil];
}

-(void)twitterTimeline {
    // iOS内部に保存されているTwitterのアカウント情報を取得
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //ユーザにTwitterの認証情報を使うことを確認
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
        //ユーザが許可した場合
        if (granted == YES) {
            //デバイス内部に保存されているtwitterアカウントをすべて取得
            NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
            
            //アカウントが１つ以上登録されている場合
            if ([arrayOfAccounts count] > 0) {
                //0番目のアカウントを使用
                ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                
                //NSURLでtwitterAPIを取得
                NSURL *requestAPI = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
                
                //認証が必要な要求に関する設定
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                [parameters setObject:@"100" forKey:@"count"];
                [parameters setObject:@"1" forKey:@"include_entities"];
                
                //リクエストを生成
                SLRequest *posts =[SLRequest requestForServiceType:SLServiceTypeTwitter
                                                     requestMethod:SLRequestMethodGET
                                                               URL:requestAPI
                                                        parameters:parameters
                                   ];
                
                //リクエストに認証情報を付加
                posts.account = twitterAccount;
                
                //ステータスバーのActivity Indicatorを開始
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                //リクエストを発行
                [posts performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                {
                    //JSON配列を解析し，tweetをNSArrayの配列に入れる
                    array = [NSJSONSerialization JSONObjectWithData:responseData
                                                            options:NSJSONReadingMutableLeaves
                                                              error:&error];
                    if (array.count != 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [timelineTableView reloadData];
                        });
                    }
                }];
                
                //tweet取得完了したらActivity Indicatorを終了
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
            }
        } else {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self twitterTimeline];
}

-(IBAction)refreshButton {
    [self twitterTimeline];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [array count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //セルのIdentifierを指定
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    //カスタムセル上の部品
    UITextView *tweetTextView = (UITextView *)[cell viewWithTag:3];
    UILabel *userLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *userIDLabel = (UILabel *)[cell viewWithTag:2];
    UIImageView *userImageView = (UIImageView *)[cell viewWithTag:4];
    
    //セルに表示するtweetのJSONを解析し，NSDictionaryに
    NSDictionary *tweet = array[indexPath.row];
    NSDictionary *userInfo = tweet[@"user"];
    
    //セルにTweetの内容とユーザ名を表示
    tweetTextView.text = [NSString stringWithFormat:@"%@", tweet[@"text"]];
    userLabel.text = [NSString stringWithFormat:@"%@", userInfo[@"name"]];
    userIDLabel.text = [NSString stringWithFormat:@"@%@", userInfo[@"screen_name"]];
    
    //セルにユーザのimageを表示
    NSString *userImagePath = userInfo[@"profile_image_url"];
    NSURL *userImagePathUrl = [[NSURL alloc] initWithString:userImagePath];
    NSData *userImagePathData = [[NSData alloc] initWithContentsOfURL:userImagePathUrl];
    userImageView.image = [[UIImage alloc] initWithData:userImagePathData];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
