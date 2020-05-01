//
// ZXKeychain.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2020 Zhao Xin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ZXKeychain.h"

@interface ZXKeychain ()
@property (nonatomic, assign) OSStatus lastStatus;
@property (nonatomic, strong) NSError *lastError;

- (ZXKeychainItem *)createItem:(BOOL)addingItems;

@end

@implementation ZXKeychain

+ (instancetype)defaultKeychain {
    static ZXKeychain *keychain;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keychain = [[ZXKeychain alloc] init];
    });
    return keychain;
}

- (void)setLastStatus:(OSStatus)lastStatus {
    _lastStatus = lastStatus;
    // Update last error
    if (_lastStatus == noErr) {
        _lastError = nil;
    } else {
        _lastError = [ZXKeychain errerWithStatus:_lastStatus];
    }
}

- (ZXKeychainItem *)createItem:(BOOL)addingItems {
    ZXKeychainItem *item = [[ZXKeychainItem alloc] init];
    item.itemClass = ZXKeychainItemClassGenericPassword;
    item.accessGroup = _accessGroup;
    if (_synchronizable) {
        item.synchronizable = addingItems ? ZXKeychainItemAttrSyncTrue: ZXKeychainItemAttrSyncAny;
    }
    return item;
}

- (BOOL)setData:(NSData *)value forKey:(NSString *)key withAccessible:(ZXKeychainItemAttrAccessible)accessible {
    // Delete any existing key before saving it
    [self removeItemForKey:key];
    // Create an item
    ZXKeychainItem *item = [self createItem:YES];
    item.account = key;
    item.valueData = value;
    // Create an Add Query
    CFDictionaryRef query = (__bridge CFDictionaryRef)[item query];
    // Add the Item
    self.lastStatus = SecItemAdd(query, NULL);
    // Return
    return _lastStatus == noErr;
}

- (BOOL)setData:(NSData *)value forKey:(NSString *)key {
    return [self setData:value forKey:key withAccessible:ZXKeychainItemAttrAccessibleWhenUnlocked];
}

- (NSData *)dataForKey:(NSString *)key {
    // Create an item
    ZXKeychainItem *item = [self createItem:NO];
    item.account = key;
    item.matchLimit = ZXKeychainItemMatchLimitOne;
    item.returnData = YES;
    // Create a Search Query
    CFDictionaryRef query = (__bridge CFDictionaryRef)[item query];
    // Initiate the Search
    CFTypeRef result = NULL;
    self.lastStatus = SecItemCopyMatching(query, &result);
    // Extract the Result
    NSData *data = nil;
    if (_lastStatus == noErr) {
        if (result && CFGetTypeID(result) == CFDataGetTypeID()) {
            data = (__bridge_transfer NSData *)result;
        }
    }
    // Return
    return data;
}

- (BOOL)setString:(NSString *)value forKey:(NSString *)key withAccessible:(ZXKeychainItemAttrAccessible)accessible {
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [self setData:data forKey:key withAccessible:accessible];
}

- (BOOL)setString:(NSString *)value forKey:(NSString *)key {
    return [self setString:value forKey:key withAccessible:ZXKeychainItemAttrAccessibleWhenUnlocked];
}

- (NSString *)stringForKey:(NSString *)key {
    NSData *data = [self dataForKey:key];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSArray<NSString *> *)allKeys {
    // Create an item
    ZXKeychainItem *item = [self createItem:NO];
    item.matchLimit = ZXKeychainItemMatchLimitAll;
    item.returnData = YES;
    item.returnAttributes = YES;
    item.returnPersistentRef = YES;
    // Create a Search Query
    CFDictionaryRef query = (__bridge CFDictionaryRef)[item query];
    // Initiate the Search
    CFTypeRef result = NULL;
    self.lastStatus = SecItemCopyMatching(query, &result);
    // Extract the Result
    NSMutableArray *keys = nil;
    if (_lastStatus == noErr) {
        if (result && CFGetTypeID(result) == CFArrayGetTypeID()) {
            NSArray *items = (__bridge_transfer NSArray *)result;
            keys = [[NSMutableArray alloc] initWithCapacity:items.count];
            for (NSDictionary *data in items) {
                ZXKeychainItem *item = [[ZXKeychainItem alloc] initWithData:data];
                NSString *key = item.account;
                if (key) {
                    [keys addObject:key];
                }
            }
        }
    }
    // Return
    return [keys copy];
}

- (BOOL)removeItemForKey:(NSString *)key {
    // Create an item
    ZXKeychainItem *item = [self createItem:NO];
    item.account = key;
    // Create a Search Query
    CFDictionaryRef query = (__bridge CFDictionaryRef)[item query];
    // Delete Items
    self.lastStatus = SecItemDelete(query);
    // Return
    return _lastStatus == noErr;
}

- (BOOL)removeAllItems {
    // Create an item
    ZXKeychainItem *item = [self createItem:NO];
    // Create a Search Query
    CFDictionaryRef query = (__bridge CFDictionaryRef)[item query];
    // Delete Items
    self.lastStatus = SecItemDelete(query);
    // Return
    return _lastStatus == noErr;
}

@end

@implementation ZXKeychain (Error)

+ (NSError *)errerWithStatus:(OSStatus)status {
    NSString *msg = nil;
    switch (status) {
        case errSecSuccess                            : msg = @"No error."; break;
        case errSecUnimplemented                      : msg = @"Function or operation not implemented."; break;
        case errSecDiskFull                           : msg = @"The disk is full."; break;
        case errSecIO                                 : msg = @"I/O error."; break;
        case errSecOpWr                               : msg = @"File already open with write permission."; break;
        case errSecParam                              : msg = @"One or more parameters passed to a function were not valid."; break;
        case errSecWrPerm                             : msg = @"Write permissions error."; break;
        case errSecAllocate                           : msg = @"Failed to allocate memory."; break;
        case errSecUserCanceled                       : msg = @"User canceled the operation."; break;
        case errSecBadReq                             : msg = @"Bad parameter or invalid state for operation."; break;
        case errSecInternalComponent                  : msg = @"errSecInternalComponent"; break;
        case errSecCoreFoundationUnknown              : msg = @"errSecCoreFoundationUnknown"; break;
        case errSecMissingEntitlement                 : msg = @"A required entitlement isn't present."; break;
        case errSecNotAvailable                       : msg = @"No keychain is available. You may need to restart your computer."; break;
        case errSecReadOnly                           : msg = @"This keychain cannot be modified."; break;
        case errSecAuthFailed                         : msg = @"The user name or passphrase you entered is not correct."; break;
        case errSecNoSuchKeychain                     : msg = @"The specified keychain could not be found."; break;
        case errSecInvalidKeychain                    : msg = @"The specified keychain is not a valid keychain file."; break;
        case errSecDuplicateKeychain                  : msg = @"A keychain with the same name already exists."; break;
        case errSecDuplicateCallback                  : msg = @"The specified callback function is already installed."; break;
        case errSecInvalidCallback                    : msg = @"The specified callback function is not valid."; break;
        case errSecDuplicateItem                      : msg = @"The specified item already exists in the keychain."; break;
        case errSecItemNotFound                       : msg = @"The specified item could not be found in the keychain."; break;
        case errSecBufferTooSmall                     : msg = @"There is not enough memory available to use the specified item."; break;
        case errSecDataTooLarge                       : msg = @"This item contains information which is too large or in a format that cannot be displayed."; break;
        case errSecNoSuchAttr                         : msg = @"The specified attribute does not exist."; break;
        case errSecInvalidItemRef                     : msg = @"The specified item is no longer valid. It may have been deleted from the keychain."; break;
        case errSecInvalidSearchRef                   : msg = @"Unable to search the current keychain."; break;
        case errSecNoSuchClass                        : msg = @"The specified item does not appear to be a valid keychain item."; break;
        case errSecNoDefaultKeychain                  : msg = @"A default keychain could not be found."; break;
        case errSecInteractionNotAllowed              : msg = @"User interaction is not allowed."; break;
        case errSecReadOnlyAttr                       : msg = @"The specified attribute could not be modified."; break;
        case errSecWrongSecVersion                    : msg = @"This keychain was created by a different version of the system software and cannot be opened."; break;
        case errSecKeySizeNotAllowed                  : msg = @"This item specifies a key size which is too large or too small."; break;
        case errSecNoStorageModule                    : msg = @"A required component (data storage module) could not be loaded. You may need to restart your computer."; break;
        case errSecNoCertificateModule                : msg = @"A required component (certificate module) could not be loaded. You may need to restart your computer."; break;
        case errSecNoPolicyModule                     : msg = @"A required component (policy module) could not be loaded. You may need to restart your computer."; break;
        case errSecInteractionRequired                : msg = @"User interaction is required, but is currently not allowed."; break;
        case errSecDataNotAvailable                   : msg = @"The contents of this item cannot be retrieved."; break;
        case errSecDataNotModifiable                  : msg = @"The contents of this item cannot be modified."; break;
        case errSecCreateChainFailed                  : msg = @"One or more certificates required to validate this certificate cannot be found."; break;
        case errSecInvalidPrefsDomain                 : msg = @"The specified preferences domain is not valid."; break;
        case errSecInDarkWake                         : msg = @"In dark wake, no UI possible"; break;
        case errSecACLNotSimple                       : msg = @"The specified access control list is not in standard (simple) form."; break;
        case errSecPolicyNotFound                     : msg = @"The specified policy cannot be found."; break;
        case errSecInvalidTrustSetting                : msg = @"The specified trust setting is invalid."; break;
        case errSecNoAccessForItem                    : msg = @"The specified item has no access control."; break;
        case errSecInvalidOwnerEdit                   : msg = @"Invalid attempt to change the owner of this item."; break;
        case errSecTrustNotAvailable                  : msg = @"No trust results are available."; break;
        case errSecUnsupportedFormat                  : msg = @"Import/Export format unsupported."; break;
        case errSecUnknownFormat                      : msg = @"Unknown format in import."; break;
        case errSecKeyIsSensitive                     : msg = @"Key material must be wrapped for export."; break;
        case errSecMultiplePrivKeys                   : msg = @"An attempt was made to import multiple private keys."; break;
        case errSecPassphraseRequired                 : msg = @"Passphrase is required for import/export."; break;
        case errSecInvalidPasswordRef                 : msg = @"The password reference was invalid."; break;
        case errSecInvalidTrustSettings               : msg = @"The Trust Settings Record was corrupted."; break;
        case errSecNoTrustSettings                    : msg = @"No Trust Settings were found."; break;
        case errSecPkcs12VerifyFailure                : msg = @"MAC verification failed during PKCS12 import (wrong password?)"; break;
        case errSecNotSigner                          : msg = @"A certificate was not signed by its proposed parent."; break;
        case errSecDecode                             : msg = @"Unable to decode the provided data."; break;
        case errSecServiceNotAvailable                : msg = @"The required service is not available."; break;
        case errSecInsufficientClientID               : msg = @"The client ID is not correct."; break;
        case errSecDeviceReset                        : msg = @"A device reset has occurred."; break;
        case errSecDeviceFailed                       : msg = @"A device failure has occurred."; break;
        case errSecAppleAddAppACLSubject              : msg = @"Adding an application ACL subject failed."; break;
        case errSecApplePublicKeyIncomplete           : msg = @"The public key is incomplete."; break;
        case errSecAppleSignatureMismatch             : msg = @"A signature mismatch has occurred."; break;
        case errSecAppleInvalidKeyStartDate           : msg = @"The specified key has an invalid start date."; break;
        case errSecAppleInvalidKeyEndDate             : msg = @"The specified key has an invalid end date."; break;
        case errSecConversionError                    : msg = @"A conversion error has occurred."; break;
        case errSecAppleSSLv2Rollback                 : msg = @"A SSLv2 rollback error has occurred."; break;
        case errSecQuotaExceeded                      : msg = @"The quota was exceeded."; break;
        case errSecFileTooBig                         : msg = @"The file is too big."; break;
        case errSecInvalidDatabaseBlob                : msg = @"The specified database has an invalid blob."; break;
        case errSecInvalidKeyBlob                     : msg = @"The specified database has an invalid key blob."; break;
        case errSecIncompatibleDatabaseBlob           : msg = @"The specified database has an incompatible blob."; break;
        case errSecIncompatibleKeyBlob                : msg = @"The specified database has an incompatible key blob."; break;
        case errSecHostNameMismatch                   : msg = @"A host name mismatch has occurred."; break;
        case errSecUnknownCriticalExtensionFlag       : msg = @"There is an unknown critical extension flag."; break;
        case errSecNoBasicConstraints                 : msg = @"No basic constraints were found."; break;
        case errSecNoBasicConstraintsCA               : msg = @"No basic CA constraints were found."; break;
        case errSecInvalidAuthorityKeyID              : msg = @"The authority key ID is not valid."; break;
        case errSecInvalidSubjectKeyID                : msg = @"The subject key ID is not valid."; break;
        case errSecInvalidKeyUsageForPolicy           : msg = @"The key usage is not valid for the specified policy."; break;
        case errSecInvalidExtendedKeyUsage            : msg = @"The extended key usage is not valid."; break;
        case errSecInvalidIDLinkage                   : msg = @"The ID linkage is not valid."; break;
        case errSecPathLengthConstraintExceeded       : msg = @"The path length constraint was exceeded."; break;
        case errSecInvalidRoot                        : msg = @"The root or anchor certificate is not valid."; break;
        case errSecCRLExpired                         : msg = @"The CRL has expired."; break;
        case errSecCRLNotValidYet                     : msg = @"The CRL is not yet valid."; break;
        case errSecCRLNotFound                        : msg = @"The CRL was not found."; break;
        case errSecCRLServerDown                      : msg = @"The CRL server is down."; break;
        case errSecCRLBadURI                          : msg = @"The CRL has a bad Uniform Resource Identifier."; break;
        case errSecUnknownCertExtension               : msg = @"An unknown certificate extension was encountered."; break;
        case errSecUnknownCRLExtension                : msg = @"An unknown CRL extension was encountered."; break;
        case errSecCRLNotTrusted                      : msg = @"The CRL is not trusted."; break;
        case errSecCRLPolicyFailed                    : msg = @"The CRL policy failed."; break;
        case errSecIDPFailure                         : msg = @"The issuing distribution point was not valid."; break;
        case errSecSMIMEEmailAddressesNotFound        : msg = @"An email address mismatch was encountered."; break;
        case errSecSMIMEBadExtendedKeyUsage           : msg = @"The appropriate extended key usage for SMIME was not found."; break;
        case errSecSMIMEBadKeyUsage                   : msg = @"The key usage is not compatible with SMIME."; break;
        case errSecSMIMEKeyUsageNotCritical           : msg = @"The key usage extension is not marked as critical."; break;
        case errSecSMIMENoEmailAddress                : msg = @"No email address was found in the certificate."; break;
        case errSecSMIMESubjAltNameNotCritical        : msg = @"The subject alternative name extension is not marked as critical."; break;
        case errSecSSLBadExtendedKeyUsage             : msg = @"The appropriate extended key usage for SSL was not found."; break;
        case errSecOCSPBadResponse                    : msg = @"The OCSP response was incorrect or could not be parsed."; break;
        case errSecOCSPBadRequest                     : msg = @"The OCSP request was incorrect or could not be parsed."; break;
        case errSecOCSPUnavailable                    : msg = @"OCSP service is unavailable."; break;
        case errSecOCSPStatusUnrecognized             : msg = @"The OCSP server did not recognize this certificate."; break;
        case errSecEndOfData                          : msg = @"An end-of-data was detected."; break;
        case errSecIncompleteCertRevocationCheck      : msg = @"An incomplete certificate revocation check occurred."; break;
        case errSecNetworkFailure                     : msg = @"A network failure occurred."; break;
        case errSecOCSPNotTrustedToAnchor             : msg = @"The OCSP response was not trusted to a root or anchor certificate."; break;
        case errSecRecordModified                     : msg = @"The record was modified."; break;
        case errSecOCSPSignatureError                 : msg = @"The OCSP response had an invalid signature."; break;
        case errSecOCSPNoSigner                       : msg = @"The OCSP response had no signer."; break;
        case errSecOCSPResponderMalformedReq          : msg = @"The OCSP responder was given a malformed request."; break;
        case errSecOCSPResponderInternalError         : msg = @"The OCSP responder encountered an internal error."; break;
        case errSecOCSPResponderTryLater              : msg = @"The OCSP responder is busy, try again later."; break;
        case errSecOCSPResponderSignatureRequired     : msg = @"The OCSP responder requires a signature."; break;
        case errSecOCSPResponderUnauthorized          : msg = @"The OCSP responder rejected this request as unauthorized."; break;
        case errSecOCSPResponseNonceMismatch          : msg = @"The OCSP response nonce did not match the request."; break;
        case errSecCodeSigningBadCertChainLength      : msg = @"Code signing encountered an incorrect certificate chain length."; break;
        case errSecCodeSigningNoBasicConstraints      : msg = @"Code signing found no basic constraints."; break;
        case errSecCodeSigningBadPathLengthConstraint : msg = @"Code signing encountered an incorrect path length constraint."; break;
        case errSecCodeSigningNoExtendedKeyUsage      : msg = @"Code signing found no extended key usage."; break;
        case errSecCodeSigningDevelopment             : msg = @"Code signing indicated use of a development-only certificate."; break;
        case errSecResourceSignBadCertChainLength     : msg = @"Resource signing has encountered an incorrect certificate chain length."; break;
        case errSecResourceSignBadExtKeyUsage         : msg = @"Resource signing has encountered an error in the extended key usage."; break;
        case errSecTrustSettingDeny                   : msg = @"The trust setting for this policy was set to Deny."; break;
        case errSecInvalidSubjectName                 : msg = @"An invalid certificate subject name was encountered."; break;
        case errSecUnknownQualifiedCertStatement      : msg = @"An unknown qualified certificate statement was encountered."; break;
        case errSecMobileMeRequestQueued              : msg = @"errSecMobileMeRequestQueued"; break;
        case errSecMobileMeRequestRedirected          : msg = @"errSecMobileMeRequestRedirected"; break;
        case errSecMobileMeServerError                : msg = @"errSecMobileMeServerError"; break;
        case errSecMobileMeServerNotAvailable         : msg = @"errSecMobileMeServerNotAvailable"; break;
        case errSecMobileMeServerAlreadyExists        : msg = @"errSecMobileMeServerAlreadyExists"; break;
        case errSecMobileMeServerServiceErr           : msg = @"errSecMobileMeServerServiceErr"; break;
        case errSecMobileMeRequestAlreadyPending      : msg = @"errSecMobileMeRequestAlreadyPending"; break;
        case errSecMobileMeNoRequestPending           : msg = @"errSecMobileMeNoRequestPending"; break;
        case errSecMobileMeCSRVerifyFailure           : msg = @"errSecMobileMeCSRVerifyFailure"; break;
        case errSecMobileMeFailedConsistencyCheck     : msg = @"errSecMobileMeFailedConsistencyCheck"; break;
        case errSecNotInitialized                     : msg = @"A function was called without initializing CSSM."; break;
        case errSecInvalidHandleUsage                 : msg = @"The CSSM handle does not match with the service type."; break;
        case errSecPVCReferentNotFound                : msg = @"A reference to the calling module was not found in the list of authorized callers."; break;
        case errSecFunctionIntegrityFail              : msg = @"A function address was not within the verified module."; break;
        case errSecInternalError                      : msg = @"An internal error has occurred."; break;
        case errSecMemoryError                        : msg = @"A memory error has occurred."; break;
        case errSecInvalidData                        : msg = @"Invalid data was encountered."; break;
        case errSecMDSError                           : msg = @"A Module Directory Service error has occurred."; break;
        case errSecInvalidPointer                     : msg = @"An invalid pointer was encountered."; break;
        case errSecSelfCheckFailed                    : msg = @"Self-check has failed."; break;
        case errSecFunctionFailed                     : msg = @"A function has failed."; break;
        case errSecModuleManifestVerifyFailed         : msg = @"A module manifest verification failure has occurred."; break;
        case errSecInvalidGUID                        : msg = @"An invalid GUID was encountered."; break;
        case errSecInvalidHandle                      : msg = @"An invalid handle was encountered."; break;
        case errSecInvalidDBList                      : msg = @"An invalid DB list was encountered."; break;
        case errSecInvalidPassthroughID               : msg = @"An invalid passthrough ID was encountered."; break;
        case errSecInvalidNetworkAddress              : msg = @"An invalid network address was encountered."; break;
        case errSecCRLAlreadySigned                   : msg = @"The certificate revocation list is already signed."; break;
        case errSecInvalidNumberOfFields              : msg = @"An invalid number of fields were encountered."; break;
        case errSecVerificationFailure                : msg = @"A verification failure occurred."; break;
        case errSecUnknownTag                         : msg = @"An unknown tag was encountered."; break;
        case errSecInvalidSignature                   : msg = @"An invalid signature was encountered."; break;
        case errSecInvalidName                        : msg = @"An invalid name was encountered."; break;
        case errSecInvalidCertificateRef              : msg = @"An invalid certificate reference was encountered."; break;
        case errSecInvalidCertificateGroup            : msg = @"An invalid certificate group was encountered."; break;
        case errSecTagNotFound                        : msg = @"The specified tag was not found."; break;
        case errSecInvalidQuery                       : msg = @"The specified query was not valid."; break;
        case errSecInvalidValue                       : msg = @"An invalid value was detected."; break;
        case errSecCallbackFailed                     : msg = @"A callback has failed."; break;
        case errSecACLDeleteFailed                    : msg = @"An ACL delete operation has failed."; break;
        case errSecACLReplaceFailed                   : msg = @"An ACL replace operation has failed."; break;
        case errSecACLAddFailed                       : msg = @"An ACL add operation has failed."; break;
        case errSecACLChangeFailed                    : msg = @"An ACL change operation has failed."; break;
        case errSecInvalidAccessCredentials           : msg = @"Invalid access credentials were encountered."; break;
        case errSecInvalidRecord                      : msg = @"An invalid record was encountered."; break;
        case errSecInvalidACL                         : msg = @"An invalid ACL was encountered."; break;
        case errSecInvalidSampleValue                 : msg = @"An invalid sample value was encountered."; break;
        case errSecIncompatibleVersion                : msg = @"An incompatible version was encountered."; break;
        case errSecPrivilegeNotGranted                : msg = @"The privilege was not granted."; break;
        case errSecInvalidScope                       : msg = @"An invalid scope was encountered."; break;
        case errSecPVCAlreadyConfigured               : msg = @"The PVC is already configured."; break;
        case errSecInvalidPVC                         : msg = @"An invalid PVC was encountered."; break;
        case errSecEMMLoadFailed                      : msg = @"The EMM load has failed."; break;
        case errSecEMMUnloadFailed                    : msg = @"The EMM unload has failed."; break;
        case errSecAddinLoadFailed                    : msg = @"The add-in load operation has failed."; break;
        case errSecInvalidKeyRef                      : msg = @"An invalid key was encountered."; break;
        case errSecInvalidKeyHierarchy                : msg = @"An invalid key hierarchy was encountered."; break;
        case errSecAddinUnloadFailed                  : msg = @"The add-in unload operation has failed."; break;
        case errSecLibraryReferenceNotFound           : msg = @"A library reference was not found."; break;
        case errSecInvalidAddinFunctionTable          : msg = @"An invalid add-in function table was encountered."; break;
        case errSecInvalidServiceMask                 : msg = @"An invalid service mask was encountered."; break;
        case errSecModuleNotLoaded                    : msg = @"A module was not loaded."; break;
        case errSecInvalidSubServiceID                : msg = @"An invalid subservice ID was encountered."; break;
        case errSecAttributeNotInContext              : msg = @"An attribute was not in the context."; break;
        case errSecModuleManagerInitializeFailed      : msg = @"A module failed to initialize."; break;
        case errSecModuleManagerNotFound              : msg = @"A module was not found."; break;
        case errSecEventNotificationCallbackNotFound  : msg = @"An event notification callback was not found."; break;
        case errSecInputLengthError                   : msg = @"An input length error was encountered."; break;
        case errSecOutputLengthError                  : msg = @"An output length error was encountered."; break;
        case errSecPrivilegeNotSupported              : msg = @"The privilege is not supported."; break;
        case errSecDeviceError                        : msg = @"A device error was encountered."; break;
        case errSecAttachHandleBusy                   : msg = @"The CSP handle was busy."; break;
        case errSecNotLoggedIn                        : msg = @"You are not logged in."; break;
        case errSecAlgorithmMismatch                  : msg = @"An algorithm mismatch was encountered."; break;
        case errSecKeyUsageIncorrect                  : msg = @"The key usage is incorrect."; break;
        case errSecKeyBlobTypeIncorrect               : msg = @"The key blob type is incorrect."; break;
        case errSecKeyHeaderInconsistent              : msg = @"The key header is inconsistent."; break;
        case errSecUnsupportedKeyFormat               : msg = @"The key header format is not supported."; break;
        case errSecUnsupportedKeySize                 : msg = @"The key size is not supported."; break;
        case errSecInvalidKeyUsageMask                : msg = @"The key usage mask is not valid."; break;
        case errSecUnsupportedKeyUsageMask            : msg = @"The key usage mask is not supported."; break;
        case errSecInvalidKeyAttributeMask            : msg = @"The key attribute mask is not valid."; break;
        case errSecUnsupportedKeyAttributeMask        : msg = @"The key attribute mask is not supported."; break;
        case errSecInvalidKeyLabel                    : msg = @"The key label is not valid."; break;
        case errSecUnsupportedKeyLabel                : msg = @"The key label is not supported."; break;
        case errSecInvalidKeyFormat                   : msg = @"The key format is not valid."; break;
        case errSecUnsupportedVectorOfBuffers         : msg = @"The vector of buffers is not supported."; break;
        case errSecInvalidInputVector                 : msg = @"The input vector is not valid."; break;
        case errSecInvalidOutputVector                : msg = @"The output vector is not valid."; break;
        case errSecInvalidContext                     : msg = @"An invalid context was encountered."; break;
        case errSecInvalidAlgorithm                   : msg = @"An invalid algorithm was encountered."; break;
        case errSecInvalidAttributeKey                : msg = @"A key attribute was not valid."; break;
        case errSecMissingAttributeKey                : msg = @"A key attribute was missing."; break;
        case errSecInvalidAttributeInitVector         : msg = @"An init vector attribute was not valid."; break;
        case errSecMissingAttributeInitVector         : msg = @"An init vector attribute was missing."; break;
        case errSecInvalidAttributeSalt               : msg = @"A salt attribute was not valid."; break;
        case errSecMissingAttributeSalt               : msg = @"A salt attribute was missing."; break;
        case errSecInvalidAttributePadding            : msg = @"A padding attribute was not valid."; break;
        case errSecMissingAttributePadding            : msg = @"A padding attribute was missing."; break;
        case errSecInvalidAttributeRandom             : msg = @"A random number attribute was not valid."; break;
        case errSecMissingAttributeRandom             : msg = @"A random number attribute was missing."; break;
        case errSecInvalidAttributeSeed               : msg = @"A seed attribute was not valid."; break;
        case errSecMissingAttributeSeed               : msg = @"A seed attribute was missing."; break;
        case errSecInvalidAttributePassphrase         : msg = @"A passphrase attribute was not valid."; break;
        case errSecMissingAttributePassphrase         : msg = @"A passphrase attribute was missing."; break;
        case errSecInvalidAttributeKeyLength          : msg = @"A key length attribute was not valid."; break;
        case errSecMissingAttributeKeyLength          : msg = @"A key length attribute was missing."; break;
        case errSecInvalidAttributeBlockSize          : msg = @"A block size attribute was not valid."; break;
        case errSecMissingAttributeBlockSize          : msg = @"A block size attribute was missing."; break;
        case errSecInvalidAttributeOutputSize         : msg = @"An output size attribute was not valid."; break;
        case errSecMissingAttributeOutputSize         : msg = @"An output size attribute was missing."; break;
        case errSecInvalidAttributeRounds             : msg = @"The number of rounds attribute was not valid."; break;
        case errSecMissingAttributeRounds             : msg = @"The number of rounds attribute was missing."; break;
        case errSecInvalidAlgorithmParms              : msg = @"An algorithm parameters attribute was not valid."; break;
        case errSecMissingAlgorithmParms              : msg = @"An algorithm parameters attribute was missing."; break;
        case errSecInvalidAttributeLabel              : msg = @"A label attribute was not valid."; break;
        case errSecMissingAttributeLabel              : msg = @"A label attribute was missing."; break;
        case errSecInvalidAttributeKeyType            : msg = @"A key type attribute was not valid."; break;
        case errSecMissingAttributeKeyType            : msg = @"A key type attribute was missing."; break;
        case errSecInvalidAttributeMode               : msg = @"A mode attribute was not valid."; break;
        case errSecMissingAttributeMode               : msg = @"A mode attribute was missing."; break;
        case errSecInvalidAttributeEffectiveBits      : msg = @"An effective bits attribute was not valid."; break;
        case errSecMissingAttributeEffectiveBits      : msg = @"An effective bits attribute was missing."; break;
        case errSecInvalidAttributeStartDate          : msg = @"A start date attribute was not valid."; break;
        case errSecMissingAttributeStartDate          : msg = @"A start date attribute was missing."; break;
        case errSecInvalidAttributeEndDate            : msg = @"An end date attribute was not valid."; break;
        case errSecMissingAttributeEndDate            : msg = @"An end date attribute was missing."; break;
        case errSecInvalidAttributeVersion            : msg = @"A version attribute was not valid."; break;
        case errSecMissingAttributeVersion            : msg = @"A version attribute was missing."; break;
        case errSecInvalidAttributePrime              : msg = @"A prime attribute was not valid."; break;
        case errSecMissingAttributePrime              : msg = @"A prime attribute was missing."; break;
        case errSecInvalidAttributeBase               : msg = @"A base attribute was not valid."; break;
        case errSecMissingAttributeBase               : msg = @"A base attribute was missing."; break;
        case errSecInvalidAttributeSubprime           : msg = @"A subprime attribute was not valid."; break;
        case errSecMissingAttributeSubprime           : msg = @"A subprime attribute was missing."; break;
        case errSecInvalidAttributeIterationCount     : msg = @"An iteration count attribute was not valid."; break;
        case errSecMissingAttributeIterationCount     : msg = @"An iteration count attribute was missing."; break;
        case errSecInvalidAttributeDLDBHandle         : msg = @"A database handle attribute was not valid."; break;
        case errSecMissingAttributeDLDBHandle         : msg = @"A database handle attribute was missing."; break;
        case errSecInvalidAttributeAccessCredentials  : msg = @"An access credentials attribute was not valid."; break;
        case errSecMissingAttributeAccessCredentials  : msg = @"An access credentials attribute was missing."; break;
        case errSecInvalidAttributePublicKeyFormat    : msg = @"A public key format attribute was not valid."; break;
        case errSecMissingAttributePublicKeyFormat    : msg = @"A public key format attribute was missing."; break;
        case errSecInvalidAttributePrivateKeyFormat   : msg = @"A private key format attribute was not valid."; break;
        case errSecMissingAttributePrivateKeyFormat   : msg = @"A private key format attribute was missing."; break;
        case errSecInvalidAttributeSymmetricKeyFormat : msg = @"A symmetric key format attribute was not valid."; break;
        case errSecMissingAttributeSymmetricKeyFormat : msg = @"A symmetric key format attribute was missing."; break;
        case errSecInvalidAttributeWrappedKeyFormat   : msg = @"A wrapped key format attribute was not valid."; break;
        case errSecMissingAttributeWrappedKeyFormat   : msg = @"A wrapped key format attribute was missing."; break;
        case errSecStagedOperationInProgress          : msg = @"A staged operation is in progress."; break;
        case errSecStagedOperationNotStarted          : msg = @"A staged operation was not started."; break;
        case errSecVerifyFailed                       : msg = @"A cryptographic verification failure has occurred."; break;
        case errSecQuerySizeUnknown                   : msg = @"The query size is unknown."; break;
        case errSecBlockSizeMismatch                  : msg = @"A block size mismatch occurred."; break;
        case errSecPublicKeyInconsistent              : msg = @"The public key was inconsistent."; break;
        case errSecDeviceVerifyFailed                 : msg = @"A device verification failure has occurred."; break;
        case errSecInvalidLoginName                   : msg = @"An invalid login name was detected."; break;
        case errSecAlreadyLoggedIn                    : msg = @"The user is already logged in."; break;
        case errSecInvalidDigestAlgorithm             : msg = @"An invalid digest algorithm was detected."; break;
        case errSecInvalidCRLGroup                    : msg = @"An invalid CRL group was detected."; break;
        case errSecCertificateCannotOperate           : msg = @"The certificate cannot operate."; break;
        case errSecCertificateExpired                 : msg = @"An expired certificate was detected."; break;
        case errSecCertificateNotValidYet             : msg = @"The certificate is not yet valid."; break;
        case errSecCertificateRevoked                 : msg = @"The certificate was revoked."; break;
        case errSecCertificateSuspended               : msg = @"The certificate was suspended."; break;
        case errSecInsufficientCredentials            : msg = @"Insufficient credentials were detected."; break;
        case errSecInvalidAction                      : msg = @"The action was not valid."; break;
        case errSecInvalidAuthority                   : msg = @"The authority was not valid."; break;
        case errSecVerifyActionFailed                 : msg = @"A verify action has failed."; break;
        case errSecInvalidCertAuthority               : msg = @"The certificate authority was not valid."; break;
        case errSecInvaldCRLAuthority                 : msg = @"The CRL authority was not valid."; break;
        case errSecInvalidCRLEncoding                 : msg = @"The CRL encoding was not valid."; break;
        case errSecInvalidCRLType                     : msg = @"The CRL type was not valid."; break;
        case errSecInvalidCRL                         : msg = @"The CRL was not valid."; break;
        case errSecInvalidFormType                    : msg = @"The form type was not valid."; break;
        case errSecInvalidID                          : msg = @"The ID was not valid."; break;
        case errSecInvalidIdentifier                  : msg = @"The identifier was not valid."; break;
        case errSecInvalidIndex                       : msg = @"The index was not valid."; break;
        case errSecInvalidPolicyIdentifiers           : msg = @"The policy identifiers are not valid."; break;
        case errSecInvalidTimeString                  : msg = @"The time specified was not valid."; break;
        case errSecInvalidReason                      : msg = @"The trust policy reason was not valid."; break;
        case errSecInvalidRequestInputs               : msg = @"The request inputs are not valid."; break;
        case errSecInvalidResponseVector              : msg = @"The response vector was not valid."; break;
        case errSecInvalidStopOnPolicy                : msg = @"The stop-on policy was not valid."; break;
        case errSecInvalidTuple                       : msg = @"The tuple was not valid."; break;
        case errSecMultipleValuesUnsupported          : msg = @"Multiple values are not supported."; break;
        case errSecNotTrusted                         : msg = @"The certificate was not trusted."; break;
        case errSecNoDefaultAuthority                 : msg = @"No default authority was detected."; break;
        case errSecRejectedForm                       : msg = @"The trust policy had a rejected form."; break;
        case errSecRequestLost                        : msg = @"The request was lost."; break;
        case errSecRequestRejected                    : msg = @"The request was rejected."; break;
        case errSecUnsupportedAddressType             : msg = @"The address type is not supported."; break;
        case errSecUnsupportedService                 : msg = @"The service is not supported."; break;
        case errSecInvalidTupleGroup                  : msg = @"The tuple group was not valid."; break;
        case errSecInvalidBaseACLs                    : msg = @"The base ACLs are not valid."; break;
        case errSecInvalidTupleCredendtials           : msg = @"The tuple credentials are not valid."; break;
        case errSecInvalidEncoding                    : msg = @"The encoding was not valid."; break;
        case errSecInvalidValidityPeriod              : msg = @"The validity period was not valid."; break;
        case errSecInvalidRequestor                   : msg = @"The requestor was not valid."; break;
        case errSecRequestDescriptor                  : msg = @"The request descriptor was not valid."; break;
        case errSecInvalidBundleInfo                  : msg = @"The bundle information was not valid."; break;
        case errSecInvalidCRLIndex                    : msg = @"The CRL index was not valid."; break;
        case errSecNoFieldValues                      : msg = @"No field values were detected."; break;
        case errSecUnsupportedFieldFormat             : msg = @"The field format is not supported."; break;
        case errSecUnsupportedIndexInfo               : msg = @"The index information is not supported."; break;
        case errSecUnsupportedLocality                : msg = @"The locality is not supported."; break;
        case errSecUnsupportedNumAttributes           : msg = @"The number of attributes is not supported."; break;
        case errSecUnsupportedNumIndexes              : msg = @"The number of indexes is not supported."; break;
        case errSecUnsupportedNumRecordTypes          : msg = @"The number of record types is not supported."; break;
        case errSecFieldSpecifiedMultiple             : msg = @"Too many fields were specified."; break;
        case errSecIncompatibleFieldFormat            : msg = @"The field format was incompatible."; break;
        case errSecInvalidParsingModule               : msg = @"The parsing module was not valid."; break;
        case errSecDatabaseLocked                     : msg = @"The database is locked."; break;
        case errSecDatastoreIsOpen                    : msg = @"The data store is open."; break;
        case errSecMissingValue                       : msg = @"A missing value was detected."; break;
        case errSecUnsupportedQueryLimits             : msg = @"The query limits are not supported."; break;
        case errSecUnsupportedNumSelectionPreds       : msg = @"The number of selection predicates is not supported."; break;
        case errSecUnsupportedOperator                : msg = @"The operator is not supported."; break;
        case errSecInvalidDBLocation                  : msg = @"The database location is not valid."; break;
        case errSecInvalidAccessRequest               : msg = @"The access request is not valid."; break;
        case errSecInvalidIndexInfo                   : msg = @"The index information is not valid."; break;
        case errSecInvalidNewOwner                    : msg = @"The new owner is not valid."; break;
        case errSecInvalidModifyMode                  : msg = @"The modify mode is not valid."; break;
        case errSecMissingRequiredExtension           : msg = @"A required certificate extension is missing."; break;
        case errSecExtendedKeyUsageNotCritical        : msg = @"The extended key usage extension was not marked critical."; break;
        case errSecTimestampMissing                   : msg = @"A timestamp was expected but was not found."; break;
        case errSecTimestampInvalid                   : msg = @"The timestamp was not valid."; break;
        case errSecTimestampNotTrusted                : msg = @"The timestamp was not trusted."; break;
        case errSecTimestampServiceNotAvailable       : msg = @"The timestamp service is not available."; break;
        case errSecTimestampBadAlg                    : msg = @"An unrecognized or unsupported Algorithm Identifier in timestamp."; break;
        case errSecTimestampBadRequest                : msg = @"The timestamp transaction is not permitted or supported."; break;
        case errSecTimestampBadDataFormat             : msg = @"The timestamp data submitted has the wrong format."; break;
        case errSecTimestampTimeNotAvailable          : msg = @"The time source for the Timestamp Authority is not available."; break;
        case errSecTimestampUnacceptedPolicy          : msg = @"The requested policy is not supported by the Timestamp Authority."; break;
        case errSecTimestampUnacceptedExtension       : msg = @"The requested extension is not supported by the Timestamp Authority."; break;
        case errSecTimestampAddInfoNotAvailable       : msg = @"The additional information requested is not available."; break;
        case errSecTimestampSystemFailure             : msg = @"The timestamp request cannot be handled due to system failure."; break;
        case errSecSigningTimeMissing                 : msg = @"A signing time was expected but was not found."; break;
        case errSecTimestampRejection                 : msg = @"A timestamp transaction was rejected."; break;
        case errSecTimestampWaiting                   : msg = @"A timestamp transaction is waiting."; break;
        case errSecTimestampRevocationWarning         : msg = @"A timestamp authority revocation warning was issued."; break;
        case errSecTimestampRevocationNotification    : msg = @"A timestamp authority revocation notification was issued."; break;
        case errSecCertificatePolicyNotAllowed        : msg = @"The requested policy is not allowed for this certificate."; break;
        case errSecCertificateNameNotAllowed          : msg = @"The requested name is not allowed for this certificate."; break;
        case errSecCertificateValidityPeriodTooLong   : msg = @"The validity period in the certificate exceeds the maximum allowed."; break;
        default:
            msg = @"Unknown error";
            break;
    }
    return [NSError errorWithDomain:@"ZXKeychainError"
                               code:status
                           userInfo:@{NSLocalizedDescriptionKey:msg}];
}

@end
