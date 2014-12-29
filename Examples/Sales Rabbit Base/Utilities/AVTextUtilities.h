//
//  AVTextUtilities.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/17/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVTextUtilities : NSObject

// Text field formatting

/**
 * Format price text field
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)priceTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

/**
 * Format price text field
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)percentageTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

/**
 * Format phone number text field
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)phoneNumberTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

/**
 * Format social security number text field
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)socialSecurityNumberTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

/**
 * Format credit card number text field
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)creditCardNumberTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

/**
 * Filter and limit generic digit text field. When max digits is not greater than zero, no digit limit is enforced.
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)digitTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string maximumDigits:(NSInteger)maxDigits;

/**
 * Filter and limit generic alphanumeric text field. When max digits is not greater than zero, no digit limit is enforced.
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)alphanumericField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string maximumCharacters:(NSInteger)maxChars;

/**
 * Character case to force in filtered alpha character text field
 */
typedef enum {
    CharacterCaseUpperAndLower = 0,
    CharacterCaseUppercase,
    CharacterCaseLowercase
} CharacterCase;

/**
 * Filter and limit generic alpha character text field with optional force capital or lower case
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)alphaTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string maximumCharacters:(NSInteger)maxChars characterCase:(CharacterCase)characterCase;

/**
 * Filter a string by a set of characters
 */
+ (NSMutableString *)filterString:(NSString *)unfilteredString byCharacterSet:(NSCharacterSet *)characterSet;

/**
 * Return an NSNumber representation of the provided string, filtered of all but digit characters
 */
+ (NSNumber *)numberForString:(NSString *)string;

/**
 * Returns the phone number as a formatted string
 */
+ (NSString *)formattedPhoneNumber:(NSNumber *)number;

// Issuer Identification Number (IIN) checking of beginning of credit card number

+ (BOOL)isAmericanExpressIIN:(NSString *)cardNumber;
+ (BOOL)isDiscoverIIN:(NSString *)cardNumber;
+ (BOOL)isMasterCardIIN:(NSString *)cardNumber;
+ (BOOL)isVisaIIN:(NSString *)cardNumber;

// String validation

/**
 * Validate email string according to RFC 2822 standard
 */
+ (BOOL)isValidEmailAddress:(NSString *)email;

/**
 * Validate phone number string, assuming string was created with only digits
 * in this class' formatted phone number field, just checks length
 */
+ (BOOL)isValidPhoneNumber:(NSString *)phone;

/**
 * Validate social security number string, assuming string was created with only digits in this class'
 * formatted social security number field. Allows for both all 9 and last 4 digit only numbers.
 */
+ (BOOL)isValidSocialSecurityNumber:(NSString *)socialSecurity;

/**
 * Validate social security or individual taxpayer identification number string, assuming string was created with only
 * digits in this class' formatted social security number field. Allows for both all 9 and last 4 digit only numbers.
 */
+ (BOOL)isValidSocialSecurityOrIndividualTaxIdNumber:(NSString *)socialSecurityOrTaxId;

/**
 * Validates a credit card number string using the Luhn algorithm
 */
+ (BOOL)isValidCreditCardNumber:(NSString *)creditCardNumber;

/**
 * Validates a Routing Transit Number (RTN)
 */
+ (BOOL)isValidRoutingNumber:(NSString *)routingNumber;

/**
 * Validate ACH account number string, assuming string was created with only digits
 * in this class' generic digit field
 */
+ (BOOL)isValidAchAccountNumber:(NSString *)accountNumber;

/**
 * An obfuscated version of the specificed number string with all digit characters replaced
 * by '●' except for the specified number of shown digits at the end of the number
 */
+ (NSString *)obfuscatedNumber:(NSString *)number showNumDigits:(NSInteger)showNumDigits;

/**
 * Returns a random string of the specified length using the 95 printable ASCII characters
 */
+ (NSString *)randomStringOfLength:(NSInteger)length;

+ (BOOL)isValidStateName:(NSString *)state;

/**
 * Validates a zipcode string
 */
+ (BOOL)isValidZipcode:(NSString *)zipcode forCountryCode:(NSString *)countryCode;

/**
 * Returns zipcode length for a given country
 */

+ (int)maxZipcodeLength:(NSString *)countryCode;

@end
