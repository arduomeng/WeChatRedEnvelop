//
//  WBSettingViewController.m
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import "WBSettingViewController.h"
#import "WeChatRedEnvelop.h"
#import "WBRedEnvelopConfig.h"
#import <objc/runtime.h>

@interface WBSettingViewController ()

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@end

@implementation WBSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        Class tableViewInfoClass = NSClassFromString(@"MMTableViewInfo");
        
        _tableViewInfo = [[tableViewInfoClass alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadTableData];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    
    [self addBasicSettingSection];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}

#pragma mark - BasicSetting

- (void)addBasicSettingSection {
    Class SectionInfoClass = NSClassFromString(@"MMTableViewSectionInfo");
    
    MMTableViewSectionInfo *sectionInfo = [SectionInfoClass sectionInfoDefaut];
    
    [sectionInfo addCell:[self createAutoReceiveRedEnvelopCell]];
    
    if ([WBRedEnvelopConfig sharedConfig].autoReceiveEnable) {
        [sectionInfo addCell:[self createDelaySettingCell]];
    }
    
    [sectionInfo addCell:[self createPayingCell]];
    
    [self.tableViewInfo insertSection:sectionInfo At:0];
}

- (MMTableViewCellInfo *)createAutoReceiveRedEnvelopCell {
    Class CellInfoClass = NSClassFromString(@"MMTableViewCellInfo");
    return [CellInfoClass switchCellForSel:@selector(switchRedEnvelop:) target:self title:@"自动抢红包" on:[WBRedEnvelopConfig sharedConfig].autoReceiveEnable];
}

- (MMTableViewCellInfo *)createDelaySettingCell {
    Class CellInfoClass = NSClassFromString(@"MMTableViewCellInfo");
    
    NSInteger delaySeconds = [WBRedEnvelopConfig sharedConfig].delaySeconds;
    return [CellInfoClass normalCellForSel:@selector(settingDelay) target:self title:@"延迟抢红包" rightValue:[NSString stringWithFormat:@"%ld 秒", (long)delaySeconds] accessoryType:1];
}

- (MMTableViewCellInfo *)createPayingCell {
    Class CellInfoClass = NSClassFromString(@"MMTableViewCellInfo");
    
    return [CellInfoClass normalCellForSel:@selector(payingToAuthor) target:self title:@"打赏" rightValue:@"支持作者开发" accessoryType:1];
}

- (void)switchRedEnvelop:(UISwitch *)envelopSwitch {
    [WBRedEnvelopConfig sharedConfig].autoReceiveEnable = envelopSwitch.on;
    
    [self reloadTableData];
}

- (void)settingDelay {
    UIAlertView *alert = [UIAlertView new];
    alert.title = @"延迟抢红包(秒)";
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    
    [alert textFieldAtIndex:0].placeholder = @"延迟时长";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}

- (void)payingToAuthor {
    Class ScanQRCodeLogicControllerClass = NSClassFromString(@"ScanQRCodeLogicController");
    Class NewQRCodeScannerClass = NSClassFromString(@"NewQRCodeScanner");
    
    ScanQRCodeLogicController *scanQRCodeLogic = [[ScanQRCodeLogicControllerClass alloc] initWithViewController:self CodeType:3];
    scanQRCodeLogic.fromScene = 2;
    
    NewQRCodeScanner *qrCodeScanner = [[NewQRCodeScannerClass alloc] initWithDelegate:scanQRCodeLogic CodeType:3];
    [qrCodeScanner notifyResult:@"https://wx.tenpay.com/f2f?t=AQAAABxXiDaVyoYdR5F1zBNM5jI%3D" type:@"QR_CODE" version:6];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *delaySecondsString = [alertView textFieldAtIndex:0].text;
        NSInteger delaySeconds = [delaySecondsString integerValue];
        
        [WBRedEnvelopConfig sharedConfig].delaySeconds = delaySeconds;
        
        [self reloadTableData];
    }
}

#pragma mark - ProSetting

@end
