//
//  ColorPicker.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/23/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "ColorPicker.h"
@interface ColorPicker()<UICollectionViewDataSource,UICollectionViewDelegate> 
@end


@implementation ColorPicker

- (void)viewDidLoad {
    [super viewDidLoad];
    self.colorArray = @[UIColorFromRGB(0x5A82FF),UIColorFromRGB(0x486D42),UIColorFromRGB(0xFF685E),UIColorFromRGB(0xD5B239)];

}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colorArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
    cell.backgroundColor =  self.colorArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate pickedColor:self.colorArray[indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
