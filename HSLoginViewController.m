//
//  HSLoginViewController.m
//  HavellsSmart
//
//  Created by Vikas M K on 24/05/16.
//  Copyright © 2016 Havells. All rights reserved.
//

// Define the maximum number of allowed failed attempts
#define MAX_FAILED_ATTEMPTS 2


// Define the duration of the user invalidation in seconds (24 hours = 24 * 60 * 60 seconds)
#define INVALIDATION_DURATION 30   // 86400

#import "HSLoginViewController.h"
#import "UIView+Toast.h"
#import "AppDelegate.h"
#import "HSApplicationConstants.h"
#import "HSSlideMenuNavigationController.h"
#import "HSCoreDataManager.h"
#import "UserInformationEntity+CoreDataProperties.h"
#import "HSHomeScreenViewController.h"
#import "HSCustomSpinner.h"

@interface HSLoginViewController ()<UITextFieldDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate,NSURLSessionDelegate>
{
    AppDelegate *appDelegate;
    HSCustomSpinner *spinner;
    ////////////////////

    
    BOOL iconClick;
}

@end

@implementation HSLoginViewController

int failedAttempts = 0;
NSDate *lastFailedAttemptTime = nil;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    iconClick = true;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITEXTFIELD DELEGATE -

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return NO; 
}

#pragma mark - PRIVATE METHODS -

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validatePassword:(NSString*)password {
    NSString *passwordRegex = @"^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{8,20}$";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    return [passwordTest evaluateWithObject:password];
   
}



#pragma mark - ACTION METHODS -

-(void)faildattempt{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastFailedAttempt = [userDefaults objectForKey:@"LastFailedAttempt"];
    
    // Get the current time
    NSDate *currentTime = [NSDate date];
    
}

// Check if the user is currently invalidated
- (BOOL)isUserInvalidated {
    NSLog(@"failedAttempts%d",failedAttempts);
    NSDate *invalidationExpirationTime = [self retrieveInvalidationExpirationTime];

    if (invalidationExpirationTime != nil) {
        NSDate *currentTime = [NSDate date];
        if ([invalidationExpirationTime compare:currentTime] == NSOrderedDescending) {
            // The invalidation expiration time is in the future, indicating the user is still invalidated
            return YES;
        }
        else {
            // The invalidation expiration time has passed, indicating the user is no longer invalidated
            [self clearInvalidationExpirationTime]; // Clear the stored invalidation expiration time
        }
    }
    return NO;
}

// Save the invalidation expiration time in user defaults or any other suitable storage
- (void)saveInvalidationExpirationTime:(NSDate *)expirationTime {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:expirationTime forKey:@"InvalidationExpirationTime"];
    [userDefaults synchronize];
}

// Retrieve the invalidation expiration time from user defaults or any other suitable storage
- (NSDate *)retrieveInvalidationExpirationTime {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"InvalidationExpirationTime"];
}

// Clear the stored invalidation expiration time
- (void)clearInvalidationExpirationTime {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"InvalidationExpirationTime"];
    [userDefaults synchronize];
}

- (IBAction)getStartedActionMethod:(id)sender
{
    //221
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSDate *lastFailedAttempt = [userDefaults objectForKey:@"LastFailedAttempt"];
//
//    // Get the current time
//    NSDate *currentTime = [NSDate date];
    //221
    if ([self isUserInvalidated]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Your account is temporarily locked. Please try again after 24 hours." message:@"" preferredStyle:UIAlertControllerStyleAlert];

       UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {//
                               //button click event
           //[self.]
                                   
                           }];
//
       [alertController addAction:defaultAction];
       [self presentViewController:alertController animated:YES completion:nil];
        
        // show alert for the same 
          NSLog(@"Your account is temporarily locked. Please try again after 24 hours.");
          return;
      }
    
    
    /////////////////////////////////////////////////////////
    [self.emailIDTextFiled resignFirstResponder];
    [self.passwordTextFiled resignFirstResponder];
    
//221
    
//    NSInteger currentFailedAttempts = [userDefaults integerForKey:@"FailedAttempts"];
//    // Store the updated number of failed attempts
//    [userDefaults setInteger:currentFailedAttempts forKey:@"FailedAttempts"];
//
//    // Store the timestamp of the current failed attempt
//    [userDefaults setObject:currentTime forKey:@"LastFailedAttempt"];
//    [userDefaults synchronize];
    //221
    
    if (!appDelegate.isInternetAvailable)
        [self.view makeToast:@"Please check internet connection on device !" duration:3 position:CSToastPositionTop title:nil];
    
    else
    {
        BOOL isUsernameValid = [self validateEmailWithString:self.emailIDTextFiled.text];
        BOOL isValidPassword = [self validatePassword: self.passwordTextFiled.text];
        if([self.emailIDTextFiled.text length]==0 && [self.passwordTextFiled.text length]==0)
        {
            [self.view makeToast:@"Please enter your Sign in details" duration:3 position:CSToastPositionTop title:nil];
            return;
        }
        else  if([self.emailIDTextFiled.text length]==0 || !isUsernameValid)
        {
            [self.view makeToast:@"Please enter a valid username" duration:3 position:CSToastPositionTop title:nil];
           // currentFailedAttempts++;
            //failedAttempts++;
            return;
        }


        else if ([self.passwordTextFiled.text length]==0)
            //else if ([self.passwordTextFiled.text length]==0 || !isValidPassword)

        {
            [self.view makeToast:@"Please enter your password" duration:3 position:CSToastPositionTop title:nil];
            //currentFailedAttempts++;
           // failedAttempts++;
            return;
        }
        
        else
        {
            if (!appDelegate.isInternetAvailable)
                [self.view makeToast:@"Please check internet connection on device !" duration:3 position:CSToastPositionTop title:nil];
            else
            {
                spinner = [[HSCustomSpinner alloc] initWithSpinnerType:@"HSActivityIndicator"];
                [spinner setColor:[UIColor colorWithRed:17/255.00 green:181/255.00 blue:255.00/255.00 alpha:1.0]];
                [spinner setStrokeWidth:20];
                [spinner setInnerRadius:8];
                [spinner setOuterRadius:30];
                [spinner setNumberOfStrokes:8];
                spinner.hidesWhenStopped = NO;
                [spinner setPatternStyle:HSActivityIndicatorPatternStylePetal];
                [spinner startAnimating];
                [spinner setCenter:self.view.center];
                [self.view addSubview:spinner];
                [self.view setUserInteractionEnabled:NO];
                
                
                

                
                NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:SERVER_URL_LOGIN]];
                
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
                
                NSString *bodyData = [NSString stringWithFormat:@"{\"email\":\"%@\",\"pass\":\"%@\"}", self.emailIDTextFiled.text, self.passwordTextFiled.text];
               // NSLog(@"Havells Smart JSON Request For Login - \n%@", bodyData);
                NSData *data = [bodyData dataUsingEncoding:NSUTF8StringEncoding];
                [urlRequest setHTTPBody:data];
                
                NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
                
                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                [NSURLConnection sendAsynchronousRequest:urlRequest queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error)
                 {
                     if (responseData)
                     {
                         id responseJSONObject=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
                         
                        // NSLog(@"Havells Smart JSON Response Form Login - \n%@", responseJSONObject);
                         if (responseJSONObject != nil && error == nil)
                         {
                             if([responseJSONObject isKindOfClass:[NSDictionary class]])
                             {
                                 NSDictionary *responseDictionary = (NSDictionary *)responseJSONObject;
                                 [self performSelectorOnMainThread:@selector(loginDetailsWithDictionary:) withObject:responseDictionary waitUntilDone:NO];
                                 //221
                                 // Reset the failed attempts counter if the login is successful
//                                 [userDefaults setInteger:0 forKey:@"FailedAttempts"];
//                                 [userDefaults removeObjectForKey:@"LastFailedAttempt"];
//                                 [userDefaults synchronize];
//                                 failedAttempts = 0;
                                 //221
//                                 failedAttempts = 0;
//                                 NSLog(@"Login successful!");
                                 //221
                                 
                             }
                         }
                         else
                         {
                             [self performSelectorOnMainThread:@selector(loginFailed) withObject:nil waitUntilDone:NO];
                             NSLog(@"123.");
                             //Please enter valid Sign in details
                             
                             
                         }
                     }
                     else
                     {
                         [self performSelectorOnMainThread:@selector(loginFailed) withObject:nil waitUntilDone:NO];
                         NSLog(@"1233.");
                     }
                 }];
            }
            //221
            
//            failedAttempts++;
//
//            // Store the timestamp of the current failed attempt
//            lastFailedAttemptTime = [NSDate date];
//
//            // Display an error message or perform any other necessary actions
//            NSLog(@"Login failed. Please try again.");
//
//            // Check if the maximum failed attempts threshold has been reached
//            if (failedAttempts >= MAX_FAILED_ATTEMPTS) {
//                // Calculate the invalidation expiration time as the current time plus the duration
//                NSDate *invalidationExpirationTime = [lastFailedAttemptTime dateByAddingTimeInterval:INVALIDATION_DURATION];
//
//                // Store the invalidation expiration time in user defaults or any other suitable storage
//                [self saveInvalidationExpirationTime:invalidationExpirationTime];
//
//                // Perform any additional actions such as locking the account or notifying the user
//                NSLog(@"Too many failed login attempts. Your account is temporarily locked for 24 hours.");
            
            //221
            ///}
            
        }
        
//        if (failedAttempts >= MAX_FAILED_ATTEMPTS) {
//            // Perform any additional actions such as locking the account or notifying the user
//            NSLog(@"Too many failed login attempts. Your account is temporarily locked.");
//        }
    }
}


-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSLog(@"P121 ");
    // get the public key offered by the server
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    SecKeyRef actualKey = SecTrustCopyPublicKey(serverTrust);

    // load the reference certificate
    NSString *certFile = [[NSBundle mainBundle] pathForResource:@"sSSL" ofType:@"der"];
    NSData* certData = [NSData dataWithContentsOfFile:certFile];
    SecCertificateRef expectedCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
    

    // extract the expected public key
    SecKeyRef expectedKey = NULL;
    SecCertificateRef certRefs[1] = { expectedCertificate };
    CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, (void *) certRefs, 1, NULL);
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef expTrust = NULL;
    OSStatus status = SecTrustCreateWithCertificates(certArray, policy, &expTrust);
    if (status == errSecSuccess) {
      expectedKey = SecTrustCopyPublicKey(expTrust);
    }
    CFRelease(expTrust);
    CFRelease(policy);
    CFRelease(certArray);

    // check a match
    if (actualKey != NULL && expectedKey != NULL && [(__bridge id) actualKey isEqual:(__bridge id)expectedKey]) {
      // public keys match, continue with other checks
      [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
    } else {
      // public keys do not match
      [challenge.sender cancelAuthenticationChallenge:challenge];
    }
    if(actualKey) {
      CFRelease(actualKey);
    }
    if(expectedKey) {
      CFRelease(expectedKey);
    }
    
    //SSL Pinning code
    
    // TODO
    
//    ///////////////////////////////////////
//
//    //SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
//    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
//    NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
//    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"sSSL" ofType:@"der"];
//
//    //NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"MyLocalCertificate" ofType:@"cer"];
//    NSData *localCertData = [NSData dataWithContentsOfFile:cerPath];
//    if ([remoteCertificateData isEqualToData:localCertData]) {
//    NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
//    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
//    }
//    else {
//        [[challenge sender] cancelAuthenticationChallenge:challenge];
//    }
//
//    // Perform SSL pinning verification
//    if ([self validateServerTrust:serverTrust]) {
//        // Trust the server
//        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
//        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//    } else {
//        // Reject the connection
//        [challenge.sender cancelAuthenticationChallenge:challenge];
//    }

 }




-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    ////////////////////////////////////////
    NSString *authMethod = [[challenge protectionSpace] authenticationMethod];
    
    if ([authMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    } else {
        //////////////////////////////////
        // Get remote certificate
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
        
        // Set SSL policies for domain name check
        NSMutableArray *policies = [NSMutableArray array];
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)challenge.protectionSpace.host)];
        SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
        
        // Evaluate server certificate
        SecTrustResultType result;
        SecTrustEvaluate(serverTrust, &result);
        BOOL certificateIsValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
        
        // Get local and remote cert data
        NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
        //NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"github.com" ofType:@"cer"];
        NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"sSSL" ofType:@"der"];
        NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
        // NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"sSSL" ofType:@"der"];
        
        //NSString *certFile = [[NSBundle mainBundle] pathForResource:@"sSSL" ofType:@"der"];
        //    NSData* certData = [NSData dataWithContentsOfFile:certFile];
        //    SecCertificateRef expectedCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
        
        // The pinnning check
        if ([remoteCertificateData isEqualToData:localCertificate] && certificateIsValid) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            NSLog(@"Pinning Check is working ");
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
            NSLog(@"Pinning Check is not working ");
        }
    }
}

////////////////////////////////////////////////


//- (BOOL)validateServerTrust:(SecTrustRef)serverTrust {
//    // Load your pinned public key or certificate
//    NSData *pinnedCertificateData = SecTrustGetCertificateAtIndex(serverTrust, 0); // Load the pinned public key or certificate
//
//    // Get local and remote cert data
//    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
//    NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
//    //NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"github.com" ofType:@"cer"];
//    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"sSSL" ofType:@"der"];
//    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
//
//
//    // Convert the pinned public key or certificate to SecCertificateRef
//    SecCertificateRef pinnedCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)pinnedCertificateData);
//
//    // Add the pinned certificate to the server trust
//    SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)@[(__bridge id)pinnedCertificate]);
//
//    // Evaluate the server trust
//    SecTrustResultType trustResult;
//    SecTrustEvaluate(serverTrust, &trustResult);
//
//    // Clean up
//    CFRelease(pinnedCertificate);
//
//    // Return the evaluation result
//    return (trustResult == kSecTrustResultUnspecified || trustResult == kSecTrustResultProceed);
//}

////////////////////////////////////////////////


//func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
//
//    // Adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS
//
//    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
//        if let serverTrust = challenge.protectionSpace.serverTrust {
//            let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
//
//            if(isServerTrusted) {
//                if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
//                    let serverCertificateData = SecCertificateCopyData(serverCertificate)
//                    let data = CFDataGetBytePtr(serverCertificateData);
//                    let size = CFDataGetLength(serverCertificateData);
//                    let cert1 = NSData(bytes: data, length: size)
//                    let file_der = Bundle.main.path(forResource: "certificateFile", ofType: "der")
//
//                    if let file = file_der {
//                        if let cert2 = NSData(contentsOfFile: file) {
//                            if cert1.isEqual(to: cert2 as Data) {
//                                completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
//                                return
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // Pinning failed
//    completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
//}

- (IBAction)newRegistrationActionMethod:(id)sender
{
    UIStoryboard *mainStoryboard;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        mainStoryboard = [UIStoryboard storyboardWithName:@"iPhoneMain" bundle: nil];
    else
        mainStoryboard = [UIStoryboard storyboardWithName:@"iPADMain" bundle: nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"HSRegistrationSTBID"];
    [[HSSlideMenuNavigationController sharedInstance] pushViewController:viewController animated:YES];
}

- (IBAction)forgotPasswordActionMethod:(id)sender
{
    UIStoryboard *mainStoryboard;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        mainStoryboard = [UIStoryboard storyboardWithName:@"iPhoneMain" bundle: nil];
    else
        mainStoryboard = [UIStoryboard storyboardWithName:@"iPADMain" bundle: nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"HSForgotPasswordSTBID"];
    [[HSSlideMenuNavigationController sharedInstance] pushViewController:viewController animated:YES];
}

- (void)loginDetailsWithDictionary : (NSDictionary *)responseDictionary
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    
    NSString *message = [responseDictionary objectForKey:@"message"];
    NSString *networkPassPhrase = [responseDictionary objectForKey:@"networkpassphrase"];
    NSString *token = [responseDictionary objectForKey:@"token"];
    NSString *userName = [responseDictionary objectForKey:@"name"];
    NSString *userEmailID = [responseDictionary objectForKey:@"email"];
    BOOL isAdminUser = [[responseDictionary objectForKey:@"isadmin"] boolValue];
    BOOL isMasterUser = [[responseDictionary objectForKey:@"ismaster"] boolValue];
    if ([message isEqualToString:@"true"])
    {
        HSCoreDataManager *databaseManager = [HSCoreDataManager sharedInstance];
        
        UserInformationEntity *userInformation = [NSEntityDescription insertNewObjectForEntityForName:@"UserInformationEntity" inManagedObjectContext:databaseManager.managedObjectContext];
        [userInformation setServerToken:token];
        [userInformation setNetwokPassphrase:networkPassPhrase];
        [userInformation setEmailID:userEmailID];
        [userInformation setUserName:userName];
        
        NSError *userInformationSavingError = nil;
        if ([databaseManager.managedObjectContext save:&userInformationSavingError] == NO)
        {
            NSLog(@"Havells Smart Unable to save UserInformation object context From LoginViewcontroller.");
            NSLog(@"%@, %@", userInformationSavingError, userInformationSavingError.localizedDescription);
        }
        
        if (isMasterUser)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_IS_MASTER_USER];
        else
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:USERDEFAULTS_IS_MASTER_USER];
        
        if (isAdminUser)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_IS_ADMIN_USER];
        else
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:USERDEFAULTS_IS_ADMIN_USER];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:USERDEFAULTS_CONFIG_VERSION];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_IS_USER_LOGGED_IN];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        failedAttempts = 0;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"InvalidationExpirationTime"];
        
        UIStoryboard *mainStoryboard;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            mainStoryboard = [UIStoryboard storyboardWithName:@"iPhoneMain" bundle: nil];
        else
            mainStoryboard = [UIStoryboard storyboardWithName:@"iPADMain" bundle: nil];
        HSHomeScreenViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"HSHomeScreenSTBID"];
        [[HSSlideMenuNavigationController sharedInstance]popToRootAndSwitchToViewController:viewController withSlideOutAnimation:YES andCompletion:nil];
        
        
        
    }
    else
    {
        if ([message isEqualToString:@"false"])
            
            [self.view makeToast:@"Please enter valid Sign in details" duration:3 position:CSToastPositionTop title:nil];
        failedAttempts++;

        // Store the timestamp of the current failed attempt
        lastFailedAttemptTime = [NSDate date];

        // Display an error message or perform any other necessary actions
        NSLog(@"Login failed. Please try again.");

        // Check if the maximum failed attempts threshold has been reached
        if (failedAttempts >= MAX_FAILED_ATTEMPTS) {
            // Calculate the invalidation expiration time as the current time plus the duration
            NSDate *invalidationExpirationTime = [lastFailedAttemptTime dateByAddingTimeInterval:INVALIDATION_DURATION];

            // Store the invalidation expiration time in user defaults or any other suitable storage
            [self saveInvalidationExpirationTime:invalidationExpirationTime];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Too many failed login attempts. Your account is temporarily locked for 24 hours" message:@"" preferredStyle:UIAlertControllerStyleAlert];

           UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {//
                                   //button click event
                                       
                               }];
//
           [alertController addAction:defaultAction];
           [self presentViewController:alertController animated:YES completion:nil];
            // Perform any additional actions such as locking the account or notifying the user
            NSLog(@"Too many failed login attempts. Your account is temporarily locked for 24 hours.");
        }
        else
            [self.view makeToast:message duration:3 position:CSToastPositionTop title:nil];
        
        NSLog(@"Login successful!");
    }
}
- (IBAction)hideAndShowPassword:(UIButton *)sender {
    
    
    if(iconClick == true) {
        self.passwordTextFiled.secureTextEntry = false;
        iconClick = false;
    } else {
        self.passwordTextFiled.secureTextEntry = true;
        iconClick = true;
    }
}



- (void)loginFailed
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    [self.view makeToast:@"Login failed. Please try again !" duration:3 position:CSToastPositionTop title:nil];
    
}

@end
