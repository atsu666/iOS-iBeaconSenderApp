                //
//  ViewController.h
//  iBeaconSenderApp
//
//  Created by Atsushi Ito on 2014/03/20.
//  Copyright (c) 2014年 atsu666. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CBPeripheralManagerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (weak, nonatomic) IBOutlet UILabel        *statusLabel;
@property (weak, nonatomic) IBOutlet UISwitch       *beaconSwitch;

- (IBAction)beaconSwitchAction:(id)sender;

@end
