//
//  AddDeviceViewController.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "AddDeviceViewController.h"
#import "Location.h"

@interface AddDeviceViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *deviceNameTextField;

@end

@implementation AddDeviceViewController

- (IBAction)saveBarButtonItemPressed:(UIBarButtonItem *)sender
{
    Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    location.name = self.deviceNameTextField.text;
    location.uuid = self.beacon.proximityUUID.UUIDString;
    location.major = self.beacon.major;
    location.minor = self.beacon.minor;
    location.createdAt = [NSDate date];
    location.updatedAt = [NSDate date];
    
    NSError *error = nil;
    
    [self.managedObjectContext save:&error];
    
    if (!error) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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
