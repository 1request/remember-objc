//
//  HomeViewController.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HomeViewController.h"
#import "LocationsTableViewCell.h"
#import "MessagesTableViewCell.h"
#import "DevicesTableViewController.h"
#import "HUD.h"
#import "LocationManager.h"
#import <CoreData/CoreData.h>
#import "Location.h"
#import "Message.h"
#import <AVFoundation/AVFoundation.h>

static NSString *const kSlideUpToCancel = @"Slide up to cancel";
static NSString *const kReleaseToCancel = @"Release to cancel";
static CGFloat const kMinimumRecordLength = 1.0f;

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, MessagesTableViewCellDelegate, NSFetchedResultsControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *clickHereImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) NSManagedObjectID *selectedLocationObjectId;
@property (nonatomic) NSInteger activePlayerRowNumber;
@property (nonatomic) NSInteger editingCellRowNumber;
@property (strong, nonatomic) HUD *hudView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultController;
@property (strong, nonatomic) NSMutableArray *objectsInTable;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startTime;
@property (nonatomic) NSTimeInterval timeInterval;

@end

@implementation HomeViewController

#pragma mark - Lazy instantiation

- (NSMutableArray *)objectsInTable
{
    if (!_objectsInTable) {
        _objectsInTable = [NSMutableArray new];
    }
    return _objectsInTable;
}

- (NSManagedObjectID *)selectedLocationObjectId
{
    if (!_selectedLocationObjectId) {
        Location *location = self.objectsInTable.firstObject;
        if (location) {
            _selectedLocationObjectId = location.objectID;
        }
    }
    return _selectedLocationObjectId;
}

- (AVAudioRecorder *)recorder
{
    if (!_recorder) {
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   @"memo.m4a",
                                   nil];
        
        NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        
        
        // Define the recorder setting
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        // Initiate and prepare the recorder
        _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
    }
    return _recorder;
}

#pragma mark - UI elements

- (void)setClickHereImageView:(UIImageView *)clickHereImageView
{
    _clickHereImageView = clickHereImageView;
//    _clickHereImageView.hidden = YES;
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.predicate = nil;
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]];
    
    [request setRelationshipKeyPathsForPrefetching:@[@"messages"]];
    
    self.fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                       managedObjectContext:self.managedObjectContext
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
    self.fetchedResultController.delegate = self;
    NSError *error;
    BOOL success = [self.fetchedResultController performFetch:&error];
    if (!success) NSLog(@"[%@ %@] performFetch: failed", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    [self setObjectsInTable];
    [self.tableView reloadData];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *rememberLogo = [UIImage imageNamed:@"Remember-logo"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:rememberLogo];
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.navigationItem.titleView = logoImageView;
    
    if (![[self.fetchedResultController fetchedObjects] count]) {
        self.tableView.hidden = YES;
        self.recordButton.hidden = YES;
    }
    
    [self configureAVAudioSession];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enteredRegion:)
                                                 name:kEnteredBeaconNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exitedRegion:)
                                                 name:kExitedBeaconNotificationName
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:kEnteredBeaconNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:kExitedBeaconNotificationName
                                               object:nil];
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objectsInTable.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *locationCellIdentifier = @"locationCell";
    static NSString *messageCellIdentifier = @"messageCell";
    CGRect cellRect = CGRectMake(0, 0, tableView.frame.size.width, 60);
    if ([[self.objectsInTable objectAtIndex:indexPath.row] isKindOfClass:[Location class]]) {
        LocationsTableViewCell *locationCell = (LocationsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:locationCellIdentifier];
        if (locationCell == nil) {
            locationCell = [[LocationsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:locationCellIdentifier];
        }
        locationCell.frame = cellRect;
        Location *location = [self.objectsInTable objectAtIndex:indexPath.row];
        locationCell.locationNameLabel.text = location.name;
        locationCell.active = (location.objectID == self.selectedLocationObjectId) ? YES : NO;
        
        return locationCell;
    }
    else {
        MessagesTableViewCell *messageCell = (MessagesTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:messageCellIdentifier];
        if (messageCell == nil) {
            messageCell = [[MessagesTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:messageCellIdentifier];
            messageCell.delegate = self;
        }
        Message *message = [self.objectsInTable objectAtIndex:indexPath.row];
        messageCell.frame = cellRect;
        messageCell.read = [message.read boolValue];
        messageCell.messageNameLabel.text = message.name;
        messageCell.playerStatus = (self.activePlayerRowNumber && self.activePlayerRowNumber == indexPath.row) ? Play : Pause;
        messageCell.playerButton.tag = indexPath.row;
        [messageCell.playerButton addTarget:self action:@selector(playerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (indexPath.row == self.editingCellRowNumber) [messageCell openCell];
        
        return messageCell;
    }
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.objectsInTable objectAtIndex:indexPath.row] isKindOfClass:[Location class]]) {
        Location *location = [self.objectsInTable objectAtIndex:indexPath.row];
        if (location.objectID == self.selectedLocationObjectId) return;
        else {
            self.selectedLocationObjectId = location.objectID;
            [self.tableView reloadData];
        }
    }
}

#pragma mark - helper methods

- (void)configureAVAudioSession
{
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *error;
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) NSLog(@"AVAudioSession error setting category: %@", error.localizedDescription);
    
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    
    if (error) NSLog(@"AVAudioSession error activating: %@", error.localizedDescription);
}

- (void)setObjectsInTable
{
    [self.objectsInTable removeAllObjects];
    NSArray *fetchedLocations = [self.fetchedResultController fetchedObjects];
    for (Location *location in fetchedLocations) {
        [self.objectsInTable addObject:location];
        NSSortDescriptor *sortUnread = [NSSortDescriptor sortDescriptorWithKey:@"read" ascending:YES];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
        NSArray *sortedMessages = [location.messages sortedArrayUsingDescriptors:@[sortUnread, sortDescriptor]];
        for (Message *message in sortedMessages) {
            [self.objectsInTable addObject:message];
        }
    }
}

- (void)enteredRegion:(NSNotification *)notification
{
    CLBeaconRegion *region = [notification.userInfo objectForKey:@"region"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@ AND major == %@ AND minor == %@", region.proximityUUID.UUIDString, region.major, region.minor];
    NSArray *filteredLocations = [[self.fetchedResultController fetchedObjects] filteredArrayUsingPredicate:predicate];
    if (filteredLocations.count) {
        Location *location = filteredLocations.firstObject;
        location.updatedAt = [NSDate date];
        self.selectedLocationObjectId = location.objectID;
        [self.managedObjectContext save:NULL];
        [self.tableView reloadData];
    }
}

- (void)exitedRegion:(NSNotification *)notification
{
    NSLog(@"exited region: %@", notification.userInfo);
}

- (void)recordAudio
{
    if (self.player.playing) {
        [self.player stop];
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:NULL];
    [self.recorder record];
    
    self.startTime = [NSDate date];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateTimer
{
    self.timeInterval = [[NSDate date] timeIntervalSinceDate:self.startTime];
}

- (void)finishRecordingAudio
{
    [self stopRecordingAudio];
    
    if (self.timeInterval > kMinimumRecordLength) {
        if ([self fileExistsAtSystemWithFilePathString:@"memo.m4a"]) {
            NSDate *createTime = [NSDate date];
            NSArray *pathComponents = [NSArray arrayWithObjects:
                                       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                       [NSString stringWithFormat:@"%.0f.m4a", [createTime timeIntervalSince1970]],
                                       nil];
            
            NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
            
            [[NSFileManager defaultManager] copyItemAtURL:self.recorder.url toURL:outputFileURL error:nil];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
            Message *message = [[Message alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
            message.createdAt = createTime;
            message.updatedAt = createTime;
            message.location = (Location *)[self.managedObjectContext objectWithID:self.selectedLocationObjectId];
            NSInteger count = [message.location.recordCounter integerValue] + 1;
            message.name = [NSString stringWithFormat:@"Record %zd", count];
            message.location.recordCounter = [NSNumber numberWithInteger:count];
            
            [self.managedObjectContext save:NULL];
            
            [self setObjectsInTable];
            [self.tableView reloadData];
        }
    }
    else {
        NSLog(@"Record is too short");
    }
    
    self.timeInterval = 0;
}

- (void)stopRecordingAudio
{
    [self.recorder stop];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)playAudio
{
    Message *message = [self.objectsInTable objectAtIndex:self.activePlayerRowNumber];
    NSString *fileName = [NSString stringWithFormat:@"%.0f.m4a", [message.createdAt timeIntervalSince1970]];
    NSString *path = [self filePathWithString:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
        if (!error) {
            if (![message.read boolValue]) {
                message.read = [NSNumber numberWithBool:YES];
                [self.managedObjectContext save:&error];
                if (error) NSLog(@"message read property update error: %@", error.localizedDescription);
                [self.tableView reloadData];
            }
            self.player.delegate = self;
            [self.player play];
        }
        else {
            NSLog(@"play audio error: %@", error.localizedDescription);
        }
    }
}

- (BOOL)fileExistsAtSystemWithFilePathString:(NSString *)pathString
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self filePathWithString:pathString];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    return fileExists;
}

- (NSString *)filePathWithString:(NSString *)pathString
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsPath stringByAppendingPathComponent:pathString];
}

- (void)closeEditingCell
{
    MessagesTableViewCell *previousEditingCell = (MessagesTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.editingCellRowNumber inSection:0]];
    if (previousEditingCell) [previousEditingCell closeCell:YES];
    self.editingCellRowNumber = 0;
}

- (void)tapView:(UITapGestureRecognizer *)recognizer
{
    // tap view (not table view)
    NSLog(@"tapped view (not table view)");
    [self closeEditingCell];
}

- (void)tappedMessageCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *rowsToBeReloaded = (self.activePlayerRowNumber && self.activePlayerRowNumber != indexPath.row) ? @[indexPath, [NSIndexPath indexPathForRow:self.activePlayerRowNumber inSection:0]] : @[indexPath];
    
    if (self.activePlayerRowNumber != indexPath.row) {
        if (self.player.isPlaying) {
            [self.player stop];
            self.player = nil;
        }
        self.activePlayerRowNumber = indexPath.row;
        [self playAudio];
        [self.tableView reloadRowsAtIndexPaths:rowsToBeReloaded withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        // stop player and update message cell player status to pause
        self.activePlayerRowNumber = 0;
        [self.tableView reloadRowsAtIndexPaths:rowsToBeReloaded withRowAnimation:UITableViewRowAnimationNone];
        [self.player stop];
    }
}

#pragma mark - View components actions

- (void)playerButtonClicked:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    [self tappedMessageCellAtIndexPath:indexPath];
}

- (IBAction)recordButtonTouchedDown:(id)sender
{
    if (self.editingCellRowNumber) {
        [self closeEditingCell];
    }
    else {
        self.hudView = [HUD hudInView:self.view];
        self.hudView.text = kSlideUpToCancel;
        
        [self recordAudio];
    }
}

- (IBAction)recordButtonTouchedUpInside:(id)sender
{
    [self.hudView removeFromSuperview];
    // save audio
    [self finishRecordingAudio];
}

- (IBAction)recordButtonTouchedUpOutside:(id)sender
{
    [self.hudView removeFromSuperview];
    // cancel audio
    
    [self stopRecordingAudio];
}

- (IBAction)recordButtonTouchedDragExit:(id)sender
{
    self.hudView.text = kReleaseToCancel;
    [self.hudView setNeedsDisplay];
}

- (IBAction)recordButtonTouchedDragEnter:(id)sender
{
    self.hudView.text = kSlideUpToCancel;
    [self.hudView setNeedsDisplay];
}

#pragma mark - MessagesTableViewCell Delegate

- (void)deleteButtonClicked:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Message *message = [self.objectsInTable objectAtIndex:indexPath.row];
    [self.managedObjectContext deleteObject:message];
    self.editingCellRowNumber = 0;
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

- (void)cellDidOpen:(UITableViewCell *)cell
{
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    self.editingCellRowNumber = currentEditingIndexPath.row;
}

- (void)cellDidClose:(UITableViewCell *)cell
{
    self.editingCellRowNumber = 0;
}

- (void)tappedTopView:(UITableViewCell *)cell
{
    NSLog(@"tapped cell top view");
    if (self.editingCellRowNumber) {
        [self closeEditingCell];
    }
    else {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        [self tappedMessageCellAtIndexPath:indexPath];
    }
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[DevicesTableViewController class]]) {
        DevicesTableViewController *deviceTableVC = segue.destinationViewController;
        deviceTableVC.managedObjectContext = self.managedObjectContext;
    }
}

#pragma mark - NSFetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (self.tableView.hidden) {
        self.tableView.hidden = NO;
        self.recordButton.hidden = NO;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.fetchedResultController performFetch:NULL];
    [self setObjectsInTable];
    [self.tableView reloadData];
}

#pragma mark - AVAudioPlayer Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.activePlayerRowNumber = 0;
    [self.tableView reloadData];
}

#pragma mark - UIGestureRecognizer Delegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.editingCellRowNumber) {
        return YES;
    }
    return NO;
}

@end
