//
//  AUIAutoGrowingTextView.h
//
//  Created by Adam on 10/10/13.
//

#import <UIKit/UIKit.h>

@interface AUIAutoGrowingTextView : UITextView

@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) CGFloat minHeight;

@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *maxHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *minHeightConstraint;

// TODO:
//@property(nonatomic) UIControlContentVerticalAlignment verticalAlignment;

@end


