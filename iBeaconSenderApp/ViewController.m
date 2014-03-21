//
//  ViewController.m
//  iBeaconSenderApp
//
//  Created by Atsushi Ito on 2014/03/20.
//  Copyright (c) 2014年 atsu666. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) CLBeaconRegion        *region;
@property (nonatomic) CBPeripheralManager   *manager;

@property (nonatomic) UITextField           *currentField;
@property (nonatomic) UITextField           *uuidField;
@property (nonatomic) UITextField           *identifierField;
@property (nonatomic) UITextField           *majorField;
@property (nonatomic) UITextField           *minorField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // keyboard event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillShowNotification object:nil];
    
    // CBPeripheralManagerを作成
    self.manager    = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.manager stopAdvertising];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)beaconSwitchAction:(id)sender
{
    if ( [self.beaconSwitch isOn] ) {
        [self beginAdvertising];
    } else {
        [self.manager stopAdvertising];
    }
}

- (void)beginAdvertising
{
    NSUUID      *uuid  = [[NSUUID alloc]initWithUUIDString:self.uuidField.text];
    uint16_t    major  = (uint16_t)[self.majorField.text integerValue];
    uint16_t    manor  = (uint16_t)[self.minorField.text integerValue];
    
    CLBeaconRegion *beacon      = [[CLBeaconRegion alloc]initWithProximityUUID:uuid
                                                                         major:major
                                                                         minor:manor
                                                                    identifier:self.identifierField.text];
    
    NSDictionary *beaconData    = [beacon peripheralDataWithMeasuredPower:nil];
    
    [self.manager stopAdvertising];
    [self.manager startAdvertising:beaconData];
}

- (void)chageUUID
{
    _uuidField.text = [[NSUUID UUID] UUIDString];
}

#pragma mark - CBPeripheraManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            self.statusLabel.text = @"CBPeripheralManagerStatePoweredOn";
            break;
        case CBPeripheralManagerStatePoweredOff:
            self.statusLabel.text = @"CBPeripheralManagerStatePoweredOff";
            break;
        case CBPeripheralManagerStateResetting:
            self.statusLabel.text = @"CBPeripheralManagerStateResetting";
            break;
        case CBPeripheralManagerStateUnauthorized:
            self.statusLabel.text = @"CBPeripheralManagerStateUnauthorized";
            break;
        case CBPeripheralManagerStateUnknown:
            self.statusLabel.text = @"CBPeripheralManagerStateUnknown";
            break;
        case CBPeripheralManagerStateUnsupported:
            self.statusLabel.text = @"CBPeripheralManagerStateUnsupported";
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"%@", characteristic);
}

#pragma mark - UITextFieldDelegate
- (void)keyboardChanged:(NSNotification*)notification
{
    //キーボードのフレームを取得
    NSDictionary *info  = [notification userInfo];
    NSValue *keyValue   = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [keyValue CGRectValue].size;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float screenHeight  = screenBounds.size.height;
    
    CGRect fieldRect    = [self.currentField convertRect:self.currentField.bounds toView:self.view];
    
    if ( fieldRect.origin.y + self.currentField.frame.size.height
        > screenHeight - keyboardSize.height - 20
        ) {
        [UIView animateWithDuration:0.35
                         animations:^{
                             self.scrollView.frame = CGRectMake(0, screenHeight - fieldRect.origin.y - self.currentField.frame.size.height - keyboardSize.height - 20, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                         }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [UIView animateWithDuration:0.35
                     animations:^{
                         self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                     }];
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.currentField = textField;
    
    return YES;
}

#pragma mark - UITableViewDelegate
// セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

// 各セクションのセル数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// セルの高さを指定
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40.0f;
}

// セクションタイトル
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}


// UITableViewCell Style
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
	// return UITableViewCellEditingStyleDelete;
	// return UITableViewCellEditingStyleInsert;
}

// 編集モード
- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

// 編集モード時インデント
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    
    if ( indexPath.section == 0 ) {
        self.uuidField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width - 50, 40)];
        self.uuidField.keyboardType             = UIKeyboardTypeDefault;
        self.uuidField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.uuidField.delegate                 = self;
        self.uuidField.placeholder              = NSLocalizedString(@"proximity UUID", nil);
        self.uuidField.keyboardType             = UIKeyboardTypeNumbersAndPunctuation;
        self.uuidField.text                     = [[NSUUID UUID] UUIDString];
        self.uuidField.text                     = @"4DF4F424-546E-429C-8E3F-CE4319A9251A";
        self.uuidField.font                     = [UIFont systemFontOfSize:12.0f];
        
        UIButton *reload = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 40, 0, 40, 40)];
        [reload setBackgroundImage:[UIImage imageNamed:@"refresh.jpeg"] forState:UIControlStateNormal];
        [reload addTarget:self action:@selector(chageUUID) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:self.uuidField];
        [cell.contentView addSubview:reload];
    } else if ( indexPath.section == 1 ) {
        self.identifierField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width - 50, 40)];
        self.identifierField.keyboardType               = UIKeyboardTypeDefault;
        self.identifierField.contentVerticalAlignment   = UIControlContentHorizontalAlignmentCenter;
        self.identifierField.delegate                   = self;
        self.identifierField.placeholder                = NSLocalizedString(@"identifier", nil);
        self.identifierField.keyboardType               = UIKeyboardTypeNumbersAndPunctuation;
        self.identifierField.text                       = @"com.atsu666";
        self.identifierField.font                       = [UIFont systemFontOfSize:12.0f];
        
        [cell.contentView addSubview:self.identifierField];
    } else if ( indexPath.section == 2 ) {
        self.majorField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width - 50, 40)];
        self.majorField.keyboardType                = UIKeyboardTypeDefault;
        self.majorField.contentVerticalAlignment    = UIControlContentHorizontalAlignmentCenter;
        self.majorField.delegate                    = self;
        self.majorField.placeholder                 = NSLocalizedString(@"major", nil);
        self.majorField.keyboardType                = UIKeyboardTypeNumbersAndPunctuation;
        self.majorField.text                        = @"1";
        self.majorField.font                        = [UIFont systemFontOfSize:12.0f];
        
        [cell.contentView addSubview:self.majorField];
    } else if ( indexPath.section == 3 ) {
        self.minorField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width - 50, 40)];
        self.minorField.keyboardType                = UIKeyboardTypeDefault;
        self.minorField.contentVerticalAlignment    = UIControlContentHorizontalAlignmentCenter;
        self.minorField.delegate                    = self;
        self.minorField.placeholder                 = NSLocalizedString(@"minor", nil);
        self.minorField.keyboardType                = UIKeyboardTypeNumbersAndPunctuation;
        self.minorField.text                        = @"1";
        self.minorField.font                        = [UIFont systemFontOfSize:12.0f];
        
        [cell.contentView addSubview:self.minorField];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

// UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //選択行の解除
    NSIndexPath* selection = [tableView indexPathForSelectedRow];
    if ( selection ) [tableView deselectRowAtIndexPath:selection animated:YES];
}

@end