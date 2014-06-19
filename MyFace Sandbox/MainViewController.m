//
//  ViewController.m
//  MyFace Sandbox
//
//  Created by tbredemeier on 6/13/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import "MainViewController.h"
#import "TopCollectionView.h"
#import "TopCollectionViewCell.h"
#import "MiddleCollectionView.h"
#import "MiddleCollectionViewCell.h"
#import "BottomCollectionView.h"
#import "BottomCollectionViewCell.h"
#import "AppDelegate.h"
#import "Photos.h"

#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 410

@interface MainViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet TopCollectionView *topCollectionView;
@property (strong, nonatomic) IBOutlet MiddleCollectionView *middleCollectionView;
@property (strong, nonatomic) IBOutlet BottomCollectionView *bottomCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *buttonShuffle;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property NSMutableArray *splitPhotoArray;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    self.buttonShuffle.alpha = 0;
    [super viewDidLoad];
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

    [UIView animateWithDuration:3.0 animations:^{
        self.nameLabel.alpha = 0;
        self.nameLabel.alpha = 1;
    }];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.nameLabel.frame = CGRectMake(0, 0, 320, self.nameLabel.frame.size.height);
        self.nameLabel.frame = CGRectMake(0, 0, 320, 30);
    }];
    [UIView animateWithDuration:3.0 delay:3.0 options:0 animations:^{
        self.nameLabel.alpha = 1;
           self.nameLabel.alpha = 0;
        self.buttonShuffle.alpha = 0;
                self.buttonShuffle.alpha = 1;
    } completion:nil];

    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(randomizeViews)
                                   userInfo:nil
                                    repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0f
                                     target:self
                                   selector:@selector(randomizeViews)
                                   userInfo:nil
                                    repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:3.0f
                                     target:self
                                   selector:@selector(randomizeViews)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"TestNotification"
                                               object:nil];

    [self load];
    [self dupliateFirstAndLastElements];
    [self randomizeViews];
}

- (void)receiveTestNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    if ([[notification name] isEqualToString:@"TestNotification"]) {
        NSLog (@"Successfully received the test notification!");
    [self randomizeViews];
    [self checkForWinner];
    }
}

-(IBAction)shuffleButton:(id)sender {
    [self randomizeViews];
    [self checkForWinner];

}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)load {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Photos"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObjects:sort,nil];
    request.predicate = [NSPredicate predicateWithFormat:@"selected > 0"];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Cache"];
    [self.fetchedResultsController performFetch:nil];


    if (self.fetchedResultsController.fetchedObjects.count  < 3) {
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Photos"];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObjects:sort,nil];
//        request.predicate = [NSPredicate predicateWithFormat:@"selected > 0"];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Cache"];
        [self.fetchedResultsController performFetch:nil];

        for (NSManagedObject *face in self.fetchedResultsController.fetchedObjects) {
            [self.managedObjectContext deleteObject:face];
            [self.managedObjectContext save:nil];
        }

        self.splitPhotoArray = [NSMutableArray array];
        NSDictionary *photoItem;
        photoItem = @{@"name":@"Frank" ,@"photos":[UIImage imageNamed:@"sample1.png"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Tom" ,@"photos":[UIImage imageNamed:@"sample2"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Brian" ,@"photos":[UIImage imageNamed:@"sample3"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Sally" ,@"photos":[UIImage imageNamed:@"sample4"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Ben" ,@"photos":[UIImage imageNamed:@"sample5"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Max" ,@"photos":[UIImage imageNamed:@"sample6"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Don" ,@"photos":[UIImage imageNamed:@"sample7"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Tim" ,@"photos":[UIImage imageNamed:@"sample8"]};
        [self.splitPhotoArray addObject:photoItem];
        
        for (NSDictionary *person in self.splitPhotoArray) {
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContext];
            [newManagedObject setValue:UIImagePNGRepresentation(person[@"photos"]) forKey:@"image"];
            [newManagedObject setValue:person[@"name"] forKey:@"name"];
            [newManagedObject setValue:@YES forKey:@"selected"];
            [self.managedObjectContext save:nil];
        }
        [self load];
    }
            self.splitPhotoArray = [NSMutableArray array];
            for (Photos *face in self.fetchedResultsController.fetchedObjects)
        {
            NSDictionary *photoItem = @{@"name": face.name ,@"photos":[self slicePhotos:[UIImage imageWithData:face.image]]};
            [self.splitPhotoArray addObject:photoItem];
        }
    [self.middleCollectionView reloadData];
    [self.topCollectionView reloadData];
    [self.bottomCollectionView reloadData];
}


// automatically split the photos into three horizontal sections
- (NSArray *)slicePhotos:(UIImage *)masterImage
{
    CGRect cropRect;
    CGImageRef imageRef;

    // first, determine vertical scaling factor
    float vfactor = (masterImage.size.height / IMAGE_HEIGHT);

    // divide the size by the vertical scaling factor
    float newWidth = masterImage.size.width / vfactor;
    float newHeight = masterImage.size.height / vfactor;

    // scale the image to fit vertically
    CGSize scaleSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContextWithOptions(scaleSize, NO, 0.0);
    [masterImage drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // crop for the top image
    cropRect = CGRectMake(0, 0, newWidth * 2, 400);
    imageRef = CGImageCreateWithImageInRect([resizedImage CGImage], cropRect);
    UIImage *image0 = [UIImage imageWithCGImage:imageRef];

    // crop for the middle image
    cropRect = CGRectMake(0, 400, newWidth * 2, 150);
    imageRef = CGImageCreateWithImageInRect([resizedImage CGImage], cropRect);
    UIImage *image1 = [UIImage imageWithCGImage:imageRef];

    // crop for the bottom image
    cropRect = CGRectMake(0, 550, newWidth * 2, 270);
    imageRef = CGImageCreateWithImageInRect([resizedImage CGImage], cropRect);
    UIImage *image2 = [UIImage imageWithCGImage:imageRef];

    // finally return the three (sliced) images
    return [NSArray arrayWithObjects:image0, image1, image2, nil];
}

// to enable the illusion of a circular array of photos
- (void)dupliateFirstAndLastElements
{
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject:[self.splitPhotoArray lastObject]];
    [temp addObjectsFromArray:self.splitPhotoArray];
    [temp addObject:[self.splitPhotoArray firstObject]];
    self.splitPhotoArray = temp;
}

// show (animate) the random shuffling of sliced images
- (void)randomizeViews
{
    // topCollectionView
    NSUInteger index = arc4random_uniform(self.splitPhotoArray.count);
    NSUInteger index1 = arc4random_uniform(self.splitPhotoArray.count);
    NSUInteger index2 = arc4random_uniform(self.splitPhotoArray.count);
    [self scrollView:self.topCollectionView toIndex:index animated:YES];
    [self scrollView:self.middleCollectionView toIndex:index1 animated:YES];
    [self scrollView:self.bottomCollectionView toIndex:index2 animated:YES];
}

// check if a match has occured, and if so, display the photo name
- (void)checkForWinner
{
    if([self didWin])
    {
        NSDictionary *photo = [self.splitPhotoArray objectAtIndex:[self displayedPhotoIndex:self.topCollectionView]];
        NSString *name = [photo objectForKey:@"name"];
        self.nameLabel.text = name;
        self.nameLabel.alpha = 0;
        [UIView animateWithDuration:3.0f animations:^{
        self.view.backgroundColor = [[UIColor alloc] initWithRed:244/255.0f green:120/255.0f blue:58/255.0f alpha:1.0f];
//            self.nameLabel.alpha = 0;
//            self.nameLabel.alpha = 1;
        }];
        [UIView animateWithDuration:2.0 delay:1.0 options:0 animations:^{
            self.view.backgroundColor = [[UIColor alloc] initWithRed:0/255.0f green:169/255.0f blue:162/255.0f alpha:1.0f];
//            self.nameLabel.alpha = 1;
//            self.nameLabel.alpha = 0;
        } completion:nil];
    }
}

// determine if a photo is properly alligned
- (BOOL)didWin
{
    NSInteger topIndex = [self displayedPhotoIndex:self.topCollectionView];
    NSInteger middleIndex = [self displayedPhotoIndex:self.middleCollectionView];
    NSInteger bottomIndex = [self displayedPhotoIndex:self.bottomCollectionView];

    return topIndex == middleIndex && middleIndex == bottomIndex;
}

// helper method to return the array index position of the given sliced photo
- (NSInteger)displayedPhotoIndex:(UICollectionView *)collectionView
{
    return (int)((collectionView.contentOffset.x / collectionView.frame.size.width) + 0.5);
}

// shake gesture event handler that will then reshuffle photos
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self randomizeViews];
    }
}

# pragma mark - collection view delegate methods

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView
      numberOfItemsInSection:(NSInteger)section
{
   return [self.splitPhotoArray count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *photoItem = [self.splitPhotoArray objectAtIndex:indexPath.row];
    NSArray *photos = [NSArray new];
    photos = [photoItem objectForKey:@"photos"];

    if (collectionView == self.topCollectionView)
    {
        TopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TopCellID" forIndexPath:indexPath];
        cell.imageView.image = [photos objectAtIndex:0];
        return cell;
    }
    else if (collectionView == self.middleCollectionView)
    {
        MiddleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MiddleCellID" forIndexPath:indexPath];
        cell.imageView.image = [photos objectAtIndex:1];
        return cell;
    }
    else
    {
        BottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BottomCellID" forIndexPath:indexPath];
        cell.imageView.image = [photos objectAtIndex:2];
        return cell;
    }
}

#pragma mark - scroll control methods

// used to provide the impression of an infinite circular collection of photos
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index;

    // Calculate where the collection view should be at the right-hand end item
    float contentOffsetWhenFullyScrolledRight = self.middleCollectionView.frame.size.width * ([self.splitPhotoArray count] -1);

    if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight)
    {
        // user is scrolling to the right from the last item to the 'fake' item 1.
        // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
        index = 1;
    }
    else if (scrollView.contentOffset.x == 0)
    {
        // user is scrolling to the left from the first item to the fake 'item N'.
        // reposition offset to show the 'real' item N at the right end end of the collection view
        index = [self.splitPhotoArray count] - 2;
    }
    else
    {
        [self checkForWinner];
        return;
    }

    if (scrollView == self.topCollectionView)
    {
        [self scrollView:self.topCollectionView toIndex:index animated:NO];
    }
    else if (scrollView == self.middleCollectionView)
    {
        [self scrollView:self.middleCollectionView toIndex:index animated:NO];
    }
    else
    {
        [self scrollView:self.bottomCollectionView toIndex:index animated:NO];
    }
    [self checkForWinner];
}

// helper method to scroll the given sliced photo to a new position
- (void)scrollView:(UICollectionView *)collectionView toIndex:(NSInteger)index animated:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
}

@end
