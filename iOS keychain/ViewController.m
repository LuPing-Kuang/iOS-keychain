//
//  ViewController.m
//  iOS keychain
//
//  Created by luo_Mac on 2017/8/3.
//  Copyright © 2017年 luo_Mac. All rights reserved.
//

#import "ViewController.h"
#import "SSKeychain.h"

#define kKeyChainSaveAccountService @"kKeyChainSaveAccountService"
#define kKeyChainSaveAccount        @"kKeyChainSaveAccount"
#define kKeyChainSaveAccount1       @"kKeyChainSaveAccount1"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

//    [SSKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlocked];  //设置访问权限，不设置则按照默认权限（这个我看源码没有显示默认的是什么，不知道keychain默认保存的权限是不是kSecAttrAccessibleAlways）
    
    [SSKeychain setPassword:@"123456" forService:kKeyChainSaveAccountService account:kKeyChainSaveAccount];   //设置密钥
    [SSKeychain setPassword:@"12345678" forService:kKeyChainSaveAccountService account:kKeyChainSaveAccount1];  //设置密钥
    NSError *error;
    NSString *password = [SSKeychain passwordForService:kKeyChainSaveAccountService account:kKeyChainSaveAccount error:&error];  //获取密钥
    NSLog(@"password:%@,error:%@",password,error);
    
    NSArray *counts = [SSKeychain accountsForService:kKeyChainSaveAccountService error:&error];
    NSLog(@"counts:%@",counts); //获取服务下相关账户所有的属性
    NSError *error1;
    [SSKeychain deletePasswordForService:kKeyChainSaveAccountService account:kKeyChainSaveAccount error:&error1];
    if (error1) {
        NSLog(@"删除失败:%@",error1);
    }else{
        NSLog(@"删除成功");
    }
    
    
    //    [self changeKeychainPassword];
    //    [self queryKeychainPassword];
    //    [self addSharingItems];
    //    [self queryMoreAttribute];
    //    [self querySharingItems];
}

//新增keychain
- (void)addKeychainPassword{
    NSDictionary *query = @{(__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleWhenUnlocked,(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecValueData:[@"123456" dataUsingEncoding:NSUTF8StringEncoding],(__bridge id)kSecAttrAccount:@"account name",(__bridge id)kSecAttrService:@"loginPassword"};
    /*
     参数一:
     kSecAttrAccessibleWhenUnlocked 表示获取当前密钥只要屏幕处于解锁状态就可以了
     kSecAttrAccessibleAfterFirstUnlock 表示手机第一次解锁就可以获取当前密钥
     kSecAttrAccessibleAlways 表示任何时候都可以获取当前密钥
     kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly 表示获取密钥只能在当前设备，把手机数据恢复到新的手机中是不可用的
     kSecAttrAccessibleWhenUnlockedThisDeviceOnly 非锁定状态，且设备唯一指定，同上
     kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly 第一次解锁，且设备唯一指定，同上
     kSecAttrAccessibleAlwaysThisDeviceOnly  总是可以获取，当然也是设备唯一指定，同上
     参数二:
     kSecClassGenericPassword 为keychain类型
     参数三:
     kSecValueData 存储的数据，就是密码、token存储的地方，要转化为NSData类型
     参数四:
     kSecAttrAccount 为账户名   作为账户密码的唯一索引
     参数五:
     kSecAttrService 为服务名   作为账户密码的唯一索引
     */

    CFTypeRef result;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, &result);
    
    if (status == errSecSuccess) {
        NSLog(@"添加成功");
    }else{
        NSLog(@"添加失败");
    }
}


//查询keychain
- (void)queryKeychainPassword{
    NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecReturnData:@YES,
                            (__bridge id)kSecMatchLimit:(__bridge id)kSecMatchLimitOne,
                            (__bridge id)kSecAttrAccount:@"account name",
                            (__bridge id)kSecAttrService:@"loginPassword"};
    //kSecMatchLimitOne 表示查询返回一条记录，有可能查到多条记录，一般默认返回一条记录
    //kSecMatchLimitAll 表示返回所有记录
    //SecItemCopyMatching函数会根据query里面的查询条件查找对应符合要求的记录，另外根据不同的keychain类型dataTypeRef会返回对应的不同类型如NSArray、NSDictionary、NSData
    
    CFTypeRef dataTypeRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataTypeRef);
    if (status == errSecSuccess) {
        NSString *pwd = [[NSString alloc]initWithData:(__bridge NSData*)dataTypeRef encoding:NSUTF8StringEncoding];
        NSLog(@"pwd:%@",pwd);
    }
}


//修改keychain
- (void)changeKeychainPassword{
    NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService:@"loginPassword",
                            (__bridge id)kSecAttrAccount:@"account name"};
    NSDictionary *update = @{(__bridge id)kSecValueData:[@"654321" dataUsingEncoding:NSUTF8StringEncoding]};
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
    
    if (status == errSecSuccess) {
        NSLog(@"更新成功");
    }
}

//删除keychain
- (void)deleteKeychainPassword{
    NSDictionary *query = @{
                            (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService : @"loginPassword",
                            (__bridge id)kSecAttrAccount : @"account name"
                            };
    
    //尽量详细的添加多个属性，避免误删其他keychain
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status == errSecSuccess) {
        NSLog(@"成功删除");
    }
}

//另外可以通过kSecReturnRef查询其他属性，相对于前面的返回密钥的引用，kSecReturnRef返回的是keychain所有的属性
- (void)queryMoreAttribute{
    NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecReturnRef:@YES,
                            (__bridge id)kSecReturnData:@YES,
                            (__bridge id)kSecMatchLimit:(__bridge id)kSecMatchLimitOne,
                            (__bridge id)kSecAttrAccount:@"account name",
                            (__bridge id)kSecAttrService:@"loginPassword"};
    CFTypeRef dataTypeRef = NULL;
    //重点是(__bridge id)kSecReturnRef:@YES,声明返回的数据是整个keychain的所有属性
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataTypeRef);
    
    if (status == errSecSuccess) {
        NSDictionary *dict = (__bridge NSDictionary *)dataTypeRef;
        NSString *acccount = dict[(id)kSecAttrAccount];
        NSLog(@"acccount:%@",acccount);
        NSData *data = dict[(id)kSecValueData];
        NSString *pwd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"pwd:%@",pwd);
        NSString *service = dict[(id)kSecAttrService];
        NSLog(@"service==result:%@", service);
    }
}

//sharing Items
//添加sharing Items
- (void)addSharingItems{
    NSDictionary *query = @{(__bridge id)kSecAttrAccessible : (__bridge id)kSecAttrAccessibleWhenUnlocked,
                            (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecValueData : [@"88888888" dataUsingEncoding:NSUTF8StringEncoding],
                            (__bridge id)kSecAttrAccount : @"account name",
                            (__bridge id)kSecAttrAccessGroup : @"5Q8QKERR7H.com.mycom.iOS-keychain",
                            (__bridge id)kSecAttrService : @"loginPassword",
                            (__bridge id)kSecAttrSynchronizable : @YES,
                            };
    /*
     (__bridge id)kSecAttrSynchronizable : @YES 表示可以同步到icloud，如果要同步到其他设备，请注意避免使用DeviceOnly设置等其他和设备唯一性相关的设置
     */
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, nil);
    
    if (status == errSecSuccess) {
        NSLog(@"sharing Items添加成功");
    }else{
        NSLog(@"sharing Items添加失败");
    }
}


//查询sharing Items
- (void)querySharingItems{
    NSDictionary *query = @{(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecReturnRef : @YES,
                            (__bridge id)kSecReturnData : @YES,
                            (__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitAll,
                            (__bridge id)kSecAttrAccount : @"account name",
                            (__bridge id)kSecAttrAccessGroup : @"5Q8QKERR7H.com.mycom.iOS-keychain",
                            (__bridge id)kSecAttrService : @"loginPassword",
                            };
    
    CFTypeRef dataTypeRef = NULL;
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataTypeRef);
    
    if (status == errSecSuccess) {
        NSLog(@"sharing Items查询成功");
    }else{
        NSLog(@"sharing Items查询失败");
    }
}







@end
