//
//  HomeViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "HomeViewController.h"
#import "ParseUtils.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@. Happy traveling!", [ParseUtils getLoggedInUsername]];
}

@end
