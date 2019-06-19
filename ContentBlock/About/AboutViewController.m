//
//  AboutViewController.m
//  AdBlock
//
//  Created by Tommy on 2019/5/21.
//  Copyright © 2019 Tommy. All rights reserved.
//

#import "AboutViewController.h"
#import "AboutTableViewCell.h"

@interface AboutViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation AboutViewController{
    NSArray *titArr,*selArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    titArr = @[@{@"title":@"What is AdBlock?",@"word":@"AdBlock is a free extension that lets you customize your web experience. You can block annoying ads, prevent tracking, and more."},
                     @{@"title":@"How does AdBlock work?",@"word":@"Select what you want to see while browsing the web, and use filters to block elements you don't want to see, such as ads or tracking."},
                     @{@"title":@"What is a filter list?",@"word":@"A filter list is a set of rules that tell your browser which elements to block. You can mask a small or most of the elements as needed. You can choose from a pre-made external maintenance filter list or create your own filter list. Almost all pre-made filter lists are created, published, and maintained by users based on open source licenses.\nMany ads have built-in tracking programs, and some even contain malware. Therefore, AdBlock provides a certain level of tracking and malware protection by default. If needed, you can add additional tracking and malware filtering lists to increase the level of protection."},
                     @{@"title":@"Blacklist ad",@"word":@"This filter list can block ads based on your browser language settings (such as EasyList)."},
                     @{@"title":@"Who is behind the AdBlock?",@"word":@"We are a small team of developers and support staff, relying entirely on your support for AdBlock maintenance and development. We are proud of what we produce and we thank every user. We continue to listen to user feedback and continue to roll out new versions of AdBlock. We are committed to making it the best tool for web content blocking."},
                     @{@"title":@"Is our information safe?",@"word":@"Your browser may require AdBlock to request access to your browsing data so that it can work in all tabs in the browser. AdBlock will not save or retrieve your personal browsing habits for any reason other than to make the program work. Or information. AdBlock relies entirely on donations and support to users like you, and does not collect any information for advertising or promotional purposes."},
                     @{@"title":@"How can I help AdBlock?",@"word":@"You can support our work by donating. You can also introduce others to use AdBlock."}];
    
    selArr = @[@"0",@"0",@"0",@"0",@"0",@"0",@"0"];
    
    [self CreatTableView];

}

//返回
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark --TableView
- (void)CreatTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kDeviceStatusHeight+44, kDeviceWidth, kDeviceHeight-(kDeviceStatusHeight+44)) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.backgroundColor = [UIColor colorWithHexString:@"24384A"];
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AboutTableViewCell class])
                                           bundle:nil]forCellReuseIdentifier:@"AboutTableViewCell"];
}

#pragma mark --TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return titArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [selArr[section] integerValue];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = titArr[indexPath.section];
    return [self heightForString:[dic objectForKey:@"word"] fontSize:17 andWidth:kDeviceWidth-30];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSDictionary *dic = titArr[section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, 60)];
    view.backgroundColor = [UIColor colorWithHexString:@"24384A"];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kDeviceWidth, 60)];
    lab.text = [dic objectForKey:@"title"];
    lab.textColor = [UIColor whiteColor];
    [view addSubview:lab];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, 60)];
    [view addSubview:btn];
    [btn addTarget:self action:@selector(selectorTitView:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 100+section;
    return view;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    AboutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AboutTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dic = titArr[indexPath.section];
    cell.word = [dic objectForKey:@"word"];
    return cell;
}

#pragma mark --点击title
- (void)selectorTitView:(UIButton *)btn{
    
    NSInteger index = btn.tag-100;
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:selArr];
    if([mArr[index] integerValue]==0){
        [mArr replaceObjectAtIndex:index withObject:@"1"];
    }else{
        [mArr replaceObjectAtIndex:index withObject:@"0"];
    }
    selArr = mArr;
    
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:index];
    [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
}

//计算文字高度
- (float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize]
                         constrainedToSize:CGSizeMake(width -16.0, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
    //此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    return sizeToFit.height + 16.0;
}
@end
