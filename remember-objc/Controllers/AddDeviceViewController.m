//
//  AddDeviceViewController.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "AddDeviceViewController.h"

@interface AddDeviceViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *deviceNameTextField;

@end

@implementation AddDeviceViewController

- (IBAction)saveBarButtonItemPressed:(UIBarButtonItem *)sender {
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)setDeviceNameTextField:(UITextField *)deviceNameTextField
{
    _deviceNameTextField = deviceNameTextField;
    _deviceNameTextField.delegate = self;
}

@end
