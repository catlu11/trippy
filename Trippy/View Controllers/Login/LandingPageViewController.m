//
//  LandingPageViewController.m
//  Trippy
//
//  Created by Catherine Lu on 8/9/22.
//

#import "LandingPageViewController.h"

@interface LandingPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (strong, nonatomic) NSArray *orderedViewControllers;
@end

@implementation LandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.orderedViewControllers = @[[self newViewController:@"page1"], [self newViewController:@"page2"], [self newViewController:@"page3"]];
    self.dataSource = self;
    self.delegate = self;
    [self setViewControllers:@[self.orderedViewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (UIViewController *)newViewController:(NSString *)vcName {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:vcName];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

# pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int viewControllerIndex = [self.orderedViewControllers indexOfObject:viewController];
    int previousIndex = viewControllerIndex - 1;
    NSArray *orderedViewControllers = [self orderedViewControllers];
    if (previousIndex < 0) {
        return nil;
    }
    if (orderedViewControllers.count <= previousIndex) {
        return nil;
    }
    return orderedViewControllers[previousIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    int viewControllerIndex = [self.orderedViewControllers indexOfObject:viewController];
    int nextIndex = viewControllerIndex + 1;
    if (self.orderedViewControllers.count == nextIndex) {
        return nil;
    }
    if (self.orderedViewControllers.count <= nextIndex) {
        return nil;
    }
    return self.orderedViewControllers[nextIndex];
}

@end
