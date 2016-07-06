//
//  CommentController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 01/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "CommentController.h"
#import "ServiceConstant.h"
#import "UIView+SuperView.h"

@interface CommentController ()<WebServiceDelegate>
{
    UILabel *lbl;
    NSArray *arrComment;
    BOOL isReply;
    NSDictionary *dictReply;
}

@property (nonatomic) NSMutableArray * readMoreCells;

@end

@implementation CommentController
@synthesize dictPost;

- (void)viewDidLoad
{
    [super viewDidLoad];
    isReply = NO;
    [tblComment registerNib:[UINib nibWithNibName:@"CommentCell" bundle:nil] forCellReuseIdentifier:@"CommentCell"];
    [tblComment registerNib:[UINib nibWithNibName:@"replyCommentCell" bundle:nil] forCellReuseIdentifier:@"replyCommentCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    txtAddComment.layer.cornerRadius = 3.0;
    txtAddComment.layer.masksToBounds = YES;
    btnSendOut.layer.cornerRadius = 3.0;
    btnSendOut.layer.masksToBounds = YES;
    
    self.title = @"Comments";
    [self getComment:YES page:@"1"];
}

-(void)getComment:(BOOL)isLoading page:(NSString *)pageNo
{
    NSMutableDictionary *dictParametr = [[NSMutableDictionary alloc] init];
    [dictParametr setValue:[dictPost valueForKey:@"feed_id"] forKey:@"parent_id"];
    [dictParametr setValue:@"post" forKey:@"comment_type"];
    [dictParametr setValue:pageNo forKey:@"page"];
    
    WebService *serViewComment = [[WebService alloc] initWithView:self.view andDelegate:self];
    [serViewComment callWebServiceWithURLDict:VIEW_COMMENT
                                andHTTPMethod:@"POST"
                                  andDictData:dictParametr
                                  withLoading:isLoading
                             andWebServiceTag:@"viewComment" setToken:YES];
}
#pragma mark Tableview Delegate Method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrComment.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arrReply = [[arrComment objectAtIndex:section] valueForKey:@"reply"];
    if(arrReply.count > 0)
    {
        return arrReply.count;
    }
    return 0.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"replyCommentCell"];
    
    UIImageView *imgProfile     = (UIImageView *)[cell viewWithTag:101];
    UILabel *lblName            = (UILabel *)[cell viewWithTag:102];
    UITextView *txtComment      = (UITextView *)[cell viewWithTag:103];
    
    UILabel *lblTime            = (UILabel *)[cell viewWithTag:108];

    NSDictionary *dictComment = [[[arrComment objectAtIndex:indexPath.section] valueForKey:@"reply"] objectAtIndex:indexPath.row];
    
    imgProfile.layer.cornerRadius = imgProfile.frame.size.height/2;
    imgProfile.layer.masksToBounds = YES;

    lblName.text = [NSString stringWithFormat:@"%@",[dictComment valueForKey:@"vibe_name"]];
    txtComment.text = [NSString stringWithFormat:@"%@",[dictComment valueForKey:@"comment_text"]];
    
    lblTime.text = [NSString stringWithFormat:@"%@",[dictComment valueForKey:@"created_at"]];
    
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:[dictComment valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgProfile.image = image;
    }];
    cell.selectionStyle = UITableViewCellAccessoryNone;
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    
    UIImageView *imgProfile     = (UIImageView *)[cell viewWithTag:101];
    UILabel *lblName            = (UILabel *)[cell viewWithTag:102];
    UITextView *txtComment      = (UITextView *)[cell viewWithTag:103];
    UIButton *btnAddFriend      = (UIButton *)[cell viewWithTag:104];
    UIButton *btnLike           = (UIButton *)[cell viewWithTag:105];
    UIButton *btnReply          = (UIButton *)[cell viewWithTag:106];
    UILabel *lblLikeCounter     = (UILabel *)[cell viewWithTag:107];
    UILabel *lblTime            = (UILabel *)[cell viewWithTag:108];
    
    NSDictionary *dictComment = [arrComment objectAtIndex:section];
    
    imgProfile.layer.cornerRadius = imgProfile.frame.size.height/2;
    imgProfile.layer.masksToBounds = YES;
    
    
    if([[dictComment valueForKey:@"is_like"] intValue] == 1)
    {
        btnLike.selected = YES;
    }
    
    if([[dictComment valueForKey:@"user_id"] intValue] == [[LoggedInUser sharedUser].userId intValue])
    {
        btnAddFriend.hidden = true;
    }
    
    if([[dictComment valueForKey:@"is_friend"] intValue] == 1)
    {
        btnAddFriend.hidden = true;
    }
    else if ([[dictComment valueForKey:@"is_friend"] intValue] == 0)
    {
        btnAddFriend.selected = NO;
    }
    else if ([[dictComment valueForKey:@"is_friend"] intValue] == 2)
    {
        btnAddFriend.selected = YES;
    }
    
    
    lblName.text = [NSString stringWithFormat:@"%@",[dictComment valueForKey:@"vibe_name"]];
    txtComment.text = [NSString stringWithFormat:@"%@",[dictComment valueForKey:@"comment_text"]];
    lblLikeCounter.text = [NSString stringWithFormat:@"%@",[dictComment valueForKey:@"like"]];
    lblTime.text = [NSString stringWithFormat:@"%@",[dictComment valueForKey:@"created_at"]];
    
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:[dictComment valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgProfile.image = image;
    }];
    
    btnReply.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)section];
    
    [btnReply addTarget: self action:@selector(btnRReplySend:) forControlEvents:UIControlEventTouchUpInside];
    [btnLike addTarget: self action:@selector(likeUnLikeComment:) forControlEvents:UIControlEventTouchUpInside];
    [btnAddFriend addTarget:self action:@selector(btnSendReuest:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80.0;
}

- (NSMutableArray *) readMoreCells
{
    if (!_readMoreCells)
    {
        _readMoreCells = [@[] mutableCopy];
    }
    return _readMoreCells;
}

-(void)btnRReplySend:(UIButton *)sender
{
    NSLog(@"%ld",[sender.accessibilityLabel integerValue]);
    isReply = YES;
    dictReply = [arrComment objectAtIndex:[sender.accessibilityLabel intValue]];
    [txtAddComment becomeFirstResponder];
}



#pragma mark --Comment Like and Unlike --

-(void)likeUnLikeComment:(UIButton *)sender
{
    sender.selected = !sender.selected;
    UITableViewCell *cell = (UITableViewCell *)[sender findSuperViewWithClass:[UITableViewCell class]];
    NSIndexPath *indexPath = [tblComment indexPathForCell:cell];
    
    
    NSMutableDictionary *dictLike= [[NSMutableDictionary alloc] init];
    [dictLike setValue:[[arrComment objectAtIndex:indexPath.section] valueForKey:@"comment_id"] forKey:@"parent_id"];
    [dictLike setValue:@"comment" forKey:@"like_type"];
    
    
    WebService *serLikeUnLike = [[WebService alloc]initWithView:self.view andDelegate:self];
    
    if(sender.selected)
    {
        [serLikeUnLike callWebServiceWithURLDict:LIKE_POST andHTTPMethod:@"POST" andDictData:dictLike withLoading:NO andWebServiceTag:@"likeUnLike" setToken:YES];
    }
    else
    {
        [serLikeUnLike callWebServiceWithURLDict:UNLIKE_POST andHTTPMethod:@"POST" andDictData:dictLike withLoading:NO andWebServiceTag:@"likeUnLike" setToken:YES];
    }
}

#pragma mark --Send Request--
-(void)btnSendReuest:(UIButton *)sender
{
    if(!sender.selected)
    {
        sender.selected = !sender.selected;
        UITableViewCell *cell = (UITableViewCell *)[sender findSuperViewWithClass:[UITableViewCell class]];
        NSIndexPath *indexPath = [tblComment indexPathForCell:cell];
        
        WebService *serSendRequest = [[WebService alloc] initWithView:self.view andDelegate:self];
        NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
        [dictRequest setValue:[[arrComment objectAtIndex:indexPath.section] valueForKey:@"user_id"] forKey:@"other_user_id"];
        
        [serSendRequest callWebServiceWithURLDict:SEND_REQUEST andHTTPMethod:@"POST" andDictData:dictRequest withLoading:NO andWebServiceTag:@"sendRequest" setToken:YES];
    }
}

#pragma mark Send Button Action
- (IBAction)btnSend:(UIButton *)sender
{
    if(txtAddComment.text.length > 0)
    {
        if(!isReply)
        {
            NSMutableDictionary *dictParametr = [[NSMutableDictionary alloc] init];
            [dictParametr setValue:[dictPost valueForKey:@"feed_id"] forKey:@"parent_id"];
            [dictParametr setValue:@"post" forKey:@"comment_type"];
            [dictParametr setValue:txtAddComment.text forKey:@"comment_text"];
            
            WebService *serViewComment = [[WebService alloc] initWithView:self.view andDelegate:self];
            [serViewComment callWebServiceWithURLDict:ADD_COMMENT
                                        andHTTPMethod:@"POST"
                                          andDictData:dictParametr
                                          withLoading:YES
                                     andWebServiceTag:@"addComment" setToken:YES];
        }
        else if (isReply)
        {
            NSMutableDictionary *dictParametr = [[NSMutableDictionary alloc] init];
            [dictParametr setValue:[dictReply valueForKey:@"comment_id"] forKey:@"parent_id"];
            [dictParametr setValue:@"comment" forKey:@"comment_type"];
            [dictParametr setValue:txtAddComment.text forKey:@"comment_text"];
            
            WebService *serViewComment = [[WebService alloc] initWithView:self.view andDelegate:self];
            [serViewComment callWebServiceWithURLDict:ADD_COMMENT
                                        andHTTPMethod:@"POST"
                                          andDictData:dictParametr
                                          withLoading:YES
                                     andWebServiceTag:@"addComment" setToken:YES];
        }
    }
}



#pragma mark Webservice Delegate Method
-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"viewComment"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                arrComment = [dictResult valueForKey:@"data"];
                [tblComment reloadData];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"addComment"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                isReply = NO;
                txtAddComment.text = @"";
                [self getComment:YES page:@"1"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefressHomeFeed object:nil];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"likeUnLike"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [self getComment:NO page:@"1"];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"sendRequest"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Your request send successfully."];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}



#pragma mark Textfield Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    
    int total = (int)proposedNewString.length;
    
    int remaining =100-total;
    
    if (remaining <= 0 )
    {
        lblCount.text = @"0";
    }
    else
    {
        lblCount.text = [NSString stringWithFormat:@"%d",remaining];
    }
    
    
    return textField.text.length + (string.length - range.length) <= 100;
    
}
#pragma mark --Keyboard show/hide notifications--

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note
{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    commentBottomSpaceConstraint.constant = keyboardBounds.size.height - 49;
    
    // commit animations
    [UIView commitAnimations];
    
    [self.view layoutIfNeeded];
    
    
    if (tblComment.contentSize.height > tblComment.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, tblComment.contentSize.height - tblComment.frame.size.height);
        [tblComment setContentOffset:offset animated:YES];
    }
    
}

-(void) keyboardWillHide:(NSNotification *)note
{
    isReply = NO;
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    commentBottomSpaceConstraint.constant = 0;
    
    // commit animations
    [UIView commitAnimations];
}

-(void)pushBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end