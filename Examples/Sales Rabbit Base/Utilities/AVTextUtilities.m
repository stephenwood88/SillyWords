//
//  AVTextUtilities.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/17/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import "AVTextUtilities.h"
#import "Constants.h"
#import "SRGlobalState.h"

@implementation AVTextUtilities

static NSCharacterSet *numChars;
static NSCharacterSet *alphaChars;
static NSCharacterSet *numDecimalChars;

+ (void) initialize {
    
    if (!numDecimalChars) {
        NSMutableCharacterSet *temp = [NSMutableCharacterSet decimalDigitCharacterSet];
        [temp addCharactersInString:@".,"];
        numDecimalChars = [temp copy];
    }
    if (!numChars) {
        numChars = [NSCharacterSet decimalDigitCharacterSet];
    }
    if (!alphaChars) {
        alphaChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    }
}

// Text field formatting

/**
 * Format price text field
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)priceTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Filter input string to just numbers and decimal and get current field digits
    if (!numDecimalChars) {
        NSMutableCharacterSet *temp = [NSMutableCharacterSet decimalDigitCharacterSet];
        [temp addCharactersInString:@".,"];
        numDecimalChars = [temp copy];
    }
    NSMutableString *input = [AVTextUtilities filterString:string byCharacterSet:numDecimalChars];
    NSMutableString *current = [AVTextUtilities filterString:textField.text byCharacterSet:numDecimalChars];
    // Adjust range to range without dollar sign
    NSInteger first = range.location ? range.location - 1 : 0;
    NSInteger last = (range.location + range.length) ? (range.location + range.length - 1) : 0;
    NSInteger delLength = last - first;
    // Allow backspacing through punctuation
    NSInteger cursorOffset = range.location;
    if (delLength == 0 && string.length == 0 && range.length > 0 && first > 0) {
        first--;
        cursorOffset--;
        while (![numDecimalChars characterIsMember:[textField.text characterAtIndex:cursorOffset]]) {
            cursorOffset--;
        }
        delLength++;
    }
    NSRange delRange = NSMakeRange(first, delLength);
    // Delete eligible digits in range
    [current deleteCharactersInRange:delRange];
    // Add new input digits
    [current insertString:input atIndex:first];
    // Disallow more than 2 digits after decimal and only 1 decimal
    NSRange decimalPlace = [current rangeOfString:@"."];
    if (decimalPlace.location != NSNotFound) {
        while (current.length > decimalPlace.location + 1 && [current characterAtIndex:decimalPlace.location + 1] == '.') {
            [current deleteCharactersInRange:NSMakeRange(decimalPlace.location + 1, 1)];
        }
        while (current.length > decimalPlace.location + 2 && [current characterAtIndex:decimalPlace.location + 2] == '.') {
            [current deleteCharactersInRange:NSMakeRange(decimalPlace.location + 2, 1)];
        }
        if (current.length > decimalPlace.location + 3) {
            [current deleteCharactersInRange:NSMakeRange(decimalPlace.location + 3, current.length - (decimalPlace.location + 3))];
        }
    }
    // Add leading 0 if leading decimal
    BOOL leadingZeroAdded = NO;
    if (current.length > 0 && [current characterAtIndex:0] == '.') {
        leadingZeroAdded = YES;
        [current insertString:@"0" atIndex:0];
    }
    // Insert $
    if (current.length > 0) {
        [current insertString:@"$" atIndex:0];
    }
    // Only change text field if digits changed
    if (![textField.text isEqualToString:current]) {
        // Calculate new cursor position
        for (NSInteger charsFound = 0; charsFound < input.length; cursorOffset++) {
            unichar curChar = [current characterAtIndex:cursorOffset];
            if ([numDecimalChars characterIsMember:curChar] && (cursorOffset != 1 || !leadingZeroAdded)) {
                charsFound++;
            }
        }
        while (cursorOffset < current.length && ![numDecimalChars characterIsMember:[current characterAtIndex:cursorOffset]]) {
            cursorOffset++;
        }
        // Adjust cursor for case where all digits were removed ($ removed)
        if (cursorOffset > current.length) {
            cursorOffset = current.length;
        }
        textField.text = current;
        UITextPosition *newCursor = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
        UITextRange *newCursorRange = [textField textRangeFromPosition:newCursor toPosition:newCursor];
        textField.selectedTextRange = newCursorRange;
        return YES;
    }
    else {
        // Still advance cursor even if numbers are the same
        cursorOffset += input.length;
        if (cursorOffset > current.length) {
            cursorOffset = current.length;
        }
        UITextPosition *newCursor = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
        UITextRange *newCursorRange = [textField textRangeFromPosition:newCursor toPosition:newCursor];
        textField.selectedTextRange = newCursorRange;
    }
    return NO;
}

/**
 * Format price text field
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)percentageTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    // Filter input string to just numbers and get current field digits
    // Filter input string to just numbers and decimal and get current field digits
    if (!numDecimalChars) {
        NSMutableCharacterSet *temp = [NSMutableCharacterSet decimalDigitCharacterSet];
        [temp addCharactersInString:@".,"];
        numDecimalChars = [temp copy];
    }
    NSMutableString *input = [AVTextUtilities filterString:string byCharacterSet:numDecimalChars];
    NSMutableString *current = [textField.text mutableCopy];
    // Delete eligible digits in range
    [current deleteCharactersInRange:range];
    // Add new input digits
    [current insertString:input atIndex:range.location];
    // Only change text field if digits changed
    if (![textField.text isEqualToString:current]) {
        // Calculate new cursor position
        NSInteger cursorOffset = range.location + input.length;
        textField.text = current;
        UITextPosition *newCursor = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
        UITextRange *newCursorRange = [textField textRangeFromPosition:newCursor toPosition:newCursor];
        textField.selectedTextRange = newCursorRange;
        return YES;
    }
    return NO;
}


/**
 * Format phone number text field
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)phoneNumberTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Filter input string to just numbers and get current field digits
    NSMutableString *input = [AVTextUtilities filterString:string byCharacterSet:numChars];
    NSMutableString *current = [AVTextUtilities filterString:textField.text byCharacterSet:numChars];
    // Adjust range to range without punctuation
    NSInteger first = [AVTextUtilities phoneIndexAdjustedWithoutPunctuation:range.location];
    NSInteger last = [AVTextUtilities phoneIndexAdjustedWithoutPunctuation:range.location + range.length];
    NSInteger delLength = last - first;
    // Allow backspacing through punctuation
    NSInteger cursorOffset = range.location;
    if (delLength == 0 && string.length == 0 && range.length > 0 && first > 0) {
        first--;
        cursorOffset--;
        while (![numChars characterIsMember:[textField.text characterAtIndex:cursorOffset]]) {
            cursorOffset--;
        }
        delLength++;
    }
    NSRange delRange = NSMakeRange(first, delLength);
    // Delete eligible digits in range
    [current deleteCharactersInRange:delRange];
    // Disallow leading 0 digits
    if (first == 0) {
        while (input.length > 0 && [input characterAtIndex:0] == '0') {
            [input deleteCharactersInRange:NSMakeRange(0, 1)];
        }
    }
    // Dissallow more than 10 digits
    if (current.length + input.length > 10) {
        NSInteger overflowDigits = current.length + input.length - 10;
        [input deleteCharactersInRange:NSMakeRange(input.length - overflowDigits, overflowDigits)];
    }
    // Add new input digits
    [current insertString:input atIndex:first];
    // Insert punctuation
    if (current.length > 5) {
        [current insertString:@"-" atIndex:6];
    }
    if (current.length > 2) {
        [current insertString:@") " atIndex:3];
    }
    if (current.length > 0) {
        [current insertString:@"(" atIndex:0];
    }
    // Only change text field if digits changed
    if (![textField.text isEqualToString:current]) {
        // Calculate new cursor position
        for (NSInteger charsFound = 0; charsFound < input.length; cursorOffset++) {
            if ([numChars characterIsMember:[current characterAtIndex:cursorOffset]]) {
                charsFound++;
            }
        }
        while (cursorOffset < current.length && ![numChars characterIsMember:[current characterAtIndex:cursorOffset]]) {
            cursorOffset++;
        }
        // Adjust cursor for case where all digits were removed (open parantheses removed)
        if (cursorOffset > current.length) {
            cursorOffset = current.length;
        }
        textField.text = current;
        UITextPosition *newCursor = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
        UITextRange *newCursorRange = [textField textRangeFromPosition:newCursor toPosition:newCursor];
        textField.selectedTextRange = newCursorRange;
        return YES;
    }
    return NO;
}

+ (NSInteger)phoneIndexAdjustedWithoutPunctuation:(NSInteger)unadjustedIndex {
    
    if (unadjustedIndex > 9) {
        return unadjustedIndex - 4;
    }
    if (unadjustedIndex > 5) {
        return unadjustedIndex - 3;
    }
    if (unadjustedIndex > 4) {
        return unadjustedIndex - 2;
    }
    if (unadjustedIndex > 0) {
        return unadjustedIndex - 1;
    }
    return 0;
}

/**
 * Format social security number text field
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)socialSecurityNumberTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Filter input string to just numbers and get current field digits
    if (!numChars) {
        numChars = [NSCharacterSet decimalDigitCharacterSet];
    }
    NSMutableString *input = [AVTextUtilities filterString:string byCharacterSet:numChars];
    NSMutableString *current = [AVTextUtilities filterString:textField.text byCharacterSet:numChars];
    // Adjust range to range without punctuation
    NSInteger first = [AVTextUtilities socialSecurityIndexAdjustedWithoutPunctuation:range.location stringLength:current.length];
    NSInteger last = [AVTextUtilities socialSecurityIndexAdjustedWithoutPunctuation:range.location + range.length stringLength:current.length];
    NSInteger delLength = last - first;
    // Allow backspacing through punctuation
    NSInteger cursorOffset = range.location;
    if (delLength == 0 && string.length == 0 && range.length > 0 && first > 0) {
        first--;
        cursorOffset--;
        while (![numChars characterIsMember:[textField.text characterAtIndex:cursorOffset]]) {
            cursorOffset--;
        }
        delLength++;
    }
    NSRange delRange = NSMakeRange(first, delLength);
    // Delete eligible digits in range
    [current deleteCharactersInRange:delRange];
    // Dissallow more than 9 digits
    if (current.length + input.length > 9) {
        NSInteger overflowDigits = current.length + input.length - 9;
        [input deleteCharactersInRange:NSMakeRange(input.length - overflowDigits, overflowDigits)];
    }
    // Add new input digits
    [current insertString:input atIndex:first];
    // Insert punctu1ation
    if (current.length > 4) {
        [current insertString:@"-" atIndex:5];
        [current insertString:@"-" atIndex:3];
    }
    // Only change text field if digits changed
    if (![textField.text isEqualToString:current]) {
        // Calculate new cursor position
        if (cursorOffset == 4 || cursorOffset == 5) { // Handle adding/removing 2 punctuation marks at these positions
            NSInteger punctuationAdded = current.length - textField.text.length - input.length + delLength;
            if (punctuationAdded > 0) {
                cursorOffset++;
            }
            else if (punctuationAdded < 0) {
                cursorOffset--;
            }
        }
        for (NSInteger charsFound = 0; charsFound < input.length; cursorOffset++) {
            if ([numChars characterIsMember:[current characterAtIndex:cursorOffset]]) {
                charsFound++;
            }
        }
        while (cursorOffset < current.length && ![numChars characterIsMember:[current characterAtIndex:cursorOffset]]) {
            cursorOffset++;
        }
        textField.text = current;
        UITextPosition *newCursor = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
        UITextRange *newCursorRange = [textField textRangeFromPosition:newCursor toPosition:newCursor];
        textField.selectedTextRange = newCursorRange;
        return YES;
    }
    return NO;
}

+ (NSInteger)socialSecurityIndexAdjustedWithoutPunctuation:(NSInteger)unadjustedIndex stringLength:(NSInteger)stringLength {
    
    if (unadjustedIndex > 6) {
        return unadjustedIndex - 2;
    }
    if (unadjustedIndex > 3 && stringLength > 4) { // First dash not added until 5 digits entered (not last 4 at this point)
        return unadjustedIndex - 1;
    }
    return unadjustedIndex;
}

/**
 * Format credit card number text field
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)creditCardNumberTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Filter input string to just numbers and get current field digits
    if (!numChars) {
        numChars = [NSCharacterSet decimalDigitCharacterSet];
    }
    NSMutableString *input = [AVTextUtilities filterString:string byCharacterSet:numChars];
    NSMutableString *current = [AVTextUtilities filterString:textField.text byCharacterSet:numChars];
    // Check if card type is American Express
    BOOL americanExpress = current.length ? [current characterAtIndex:0] == '3' : NO;
    // Adjust range to range without punctuation
    NSInteger first = [AVTextUtilities cardIndexAdjustedWithoutPunctuation:range.location isAmericanExpress:americanExpress];
    NSInteger last = [AVTextUtilities cardIndexAdjustedWithoutPunctuation:range.location + range.length isAmericanExpress:americanExpress];
    NSInteger delLength = last - first;
    // Allow backspacing through punctuation
    NSInteger cursorOffset = range.location;
    if (delLength == 0 && string.length == 0 && range.length > 0 && first > 0) {
        first--;
        cursorOffset--;
        while (![numChars characterIsMember:[textField.text characterAtIndex:cursorOffset]]) {
            cursorOffset--;
        }
        delLength++;
    }
    NSRange delRange = NSMakeRange(first, delLength);
    // Delete eligible digits in range
    [current deleteCharactersInRange:delRange];
    // Dissallow more than 15/16 digits
    if (current.length + input.length > (americanExpress ? 15 : 16)) {
        NSInteger overflowDigits = current.length + input.length - (americanExpress ? 15 : 16);
        [input deleteCharactersInRange:NSMakeRange(input.length - overflowDigits, overflowDigits)];
    }
    // Check if card type changed to American Express
    if (first == 0 && input.length) {
        americanExpress = [input characterAtIndex:0] == '3';
        // Check if changed to American Express and need to truncate last character
        if (americanExpress && current.length + input.length > 15) {
            [current deleteCharactersInRange:NSMakeRange(current.length - 1, 1)];
        }
    }
    // Add new input digits
    [current insertString:input atIndex:first];
    // Insert punctuation
    if (americanExpress) {
        if (current.length > 10) {
            [current insertString:@" " atIndex:11];
        }
        if (current.length > 3) {
            [current insertString:@" " atIndex:4];
        }
    }
    else {
        if (current.length > 11) {
            [current insertString:@" " atIndex:12];
        }
        if (current.length > 7) {
            [current insertString:@" " atIndex:8];
        }
        if (current.length > 3) {
            [current insertString:@" " atIndex:4];
        }
    }
    // Only change text field if digits changed
    if (![textField.text isEqualToString:current]) {
        // Calculate new cursor position
        for (NSInteger charsFound = 0; charsFound < input.length; cursorOffset++) {
            if ([numChars characterIsMember:[current characterAtIndex:cursorOffset]]) {
                charsFound++;
            }
        }
        while (cursorOffset < current.length && ![numChars characterIsMember:[current characterAtIndex:cursorOffset]]) {
            cursorOffset++;
        }
        // Adjust cursor for case where all digits were removed (if punctuation were first character)ts
        if (cursorOffset > current.length) {
            cursorOffset = current.length;
        }
        textField.text = current;
        UITextPosition *newCursor = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
        UITextRange *newCursorRange = [textField textRangeFromPosition:newCursor toPosition:newCursor];
        textField.selectedTextRange = newCursorRange;
        return YES;
    }
    return NO;
}

+ (NSInteger)cardIndexAdjustedWithoutPunctuation:(NSInteger)unadjustedIndex isAmericanExpress:(BOOL)americanExpress {
    
    if (americanExpress) {
        if (unadjustedIndex > 12) {
            return unadjustedIndex - 2;
        }
        if (unadjustedIndex > 4) {
            return unadjustedIndex - 1;
        }
        return unadjustedIndex;
    }
    else {
        if (unadjustedIndex > 14) {
            return unadjustedIndex - 3;
        }
        if (unadjustedIndex > 9) {
            return unadjustedIndex - 2;
        }
        if (unadjustedIndex > 4) {
            return unadjustedIndex - 1;
        }
        return unadjustedIndex;
    }
}

/**
 * Filter and limit generic digit text field. When max digits is not greater than zero, no digit limit is enforced.
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)digitTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string maximumDigits:(NSInteger)maxDigits {
    
    // Filter input string to just numbers and get current field digits
    if (!numChars) {
        numChars = [NSCharacterSet decimalDigitCharacterSet];
    }
    NSMutableString *input = [AVTextUtilities filterString:string byCharacterSet:numChars];
    NSMutableString *current = [textField.text mutableCopy];
    // Delete eligible digits in range
    [current deleteCharactersInRange:range];
    // Dissallow more than maximum digits
    if (maxDigits > 0 && current.length + input.length > maxDigits) {
        NSInteger overflowDigits = current.length + input.length - maxDigits;
        [input deleteCharactersInRange:NSMakeRange(input.length - overflowDigits, overflowDigits)];
    }
    // Add new input digits
    [current insertString:input atIndex:range.location];
    // Only change text field if digits changed
    if (![textField.text isEqualToString:current]) {
        // Calculate new cursor position
        NSInteger cursorOffset = range.location + input.length;
        textField.text = current;
        UITextPosition *newCursor = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
        UITextRange *newCursorRange = [textField textRangeFromPosition:newCursor toPosition:newCursor];
        textField.selectedTextRange = newCursorRange;
        return YES;
    }
    return NO;
}

/**
 * Filter and limit generic alpha character text field with optional force capital or lower case
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)alphanumericField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string maximumCharacters:(NSInteger)maxChars;{
    
    // Filter input string to just alphanumeric characters and get current field characters

    NSMutableString *input = [AVTextUtilities filterString:string byCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
   
    NSMutableString *current = [textField.text mutableCopy];
    // Delete eligible characters in range
    [current deleteCharactersInRange:range];
    // Dissallow more than maximum characters
    if (current.length + input.length > maxChars) {
        NSInteger overflowChars = current.length + input.length - maxChars;
        [input deleteCharactersInRange:NSMakeRange(input.length - overflowChars, overflowChars)];
    }
    // Add new input characters
    [current insertString:input atIndex:range.location];
    // Only change text field if digits changed
    if (![textField.text isEqualToString:current]) {
        // Calculate new cursor position
        NSInteger cursorOffset = range.location + input.length;
        textField.text = current;
        UITextPosition *newCursor = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
        UITextRange *newCursorRange = [textField textRangeFromPosition:newCursor toPosition:newCursor];
        textField.selectedTextRange = newCursorRange;
        return YES;
    }
    return NO;
}

/**
 * Filter and limit generic alpha character text field with optional force capital or lower case
 * @return 'YES' if the text field text was changed
 */
+ (BOOL)alphaTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string maximumCharacters:(NSInteger)maxChars characterCase:(CharacterCase)characterCase {
    
    // Filter input string to just alpha characters and get current field characters
    if (!alphaChars) {
        alphaChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    }
    NSMutableString *input = [AVTextUtilities filterString:string byCharacterSet:alphaChars];
    switch (characterCase) {
        case CharacterCaseUppercase:
            input = [[input uppercaseString] mutableCopy];
            break;
        case CharacterCaseLowercase:
            input = [[input lowercaseString] mutableCopy];
            break;
        case CharacterCaseUpperAndLower:
            break;
    }
    NSMutableString *current = [textField.text mutableCopy];
    // Delete eligible characters in range
    [current deleteCharactersInRange:range];
    // Dissallow more than maximum characters
    if (current.length + input.length > maxChars) {
        NSInteger overflowChars = current.length + input.length - maxChars;
        [input deleteCharactersInRange:NSMakeRange(input.length - overflowChars, overflowChars)];
    }
    // Add new input characters
    [current insertString:input atIndex:range.location];
    // Only change text field if digits changed
    if (![textField.text isEqualToString:current]) {
        // Calculate new cursor position
        NSInteger cursorOffset = range.location + input.length;
        textField.text = current;
        UITextPosition *newCursor = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
        UITextRange *newCursorRange = [textField textRangeFromPosition:newCursor toPosition:newCursor];
        textField.selectedTextRange = newCursorRange;
        return YES;
    }
    return NO;
}

/**
 * Filter a string by a set of characters
 */
+ (NSMutableString *)filterString:(NSString *)unfilteredString byCharacterSet:(NSCharacterSet *)characterSet {
    
       NSMutableString *filteredString  = [NSMutableString stringWithCapacity:unfilteredString.length];
        NSScanner *scanner = [NSScanner scannerWithString:unfilteredString];
        while (!scanner.isAtEnd) {
            NSString *buffer;
            if ([scanner scanCharactersFromSet:characterSet intoString:&buffer]) {
                [filteredString appendString:buffer];
            }
            else {
                scanner.scanLocation++;
            }
        }
    
        return filteredString;

}

/**
 * Return an NSNumber representation of the provided string, filtered of all but digit characters
 */
+ (NSNumber *)numberForString:(NSString *)string {
    
    if (!numChars) {
        numChars = [NSCharacterSet decimalDigitCharacterSet];
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter numberFromString:[AVTextUtilities filterString:string byCharacterSet:numChars]];
}

/**
 * Returns the phone number as a formatted string
 */
+ (NSString *)formattedPhoneNumber:(NSNumber *)number {
    
    if (number) {
        NSString *string = number.stringValue;
        if (string.length == 10) {
            return [NSString stringWithFormat:@"(%@) %@-%@", [string substringToIndex:3], [string substringWithRange:NSMakeRange(3, 3)], [string substringFromIndex:6]];
        }
    }
    return nil;
}

// Issuer Identification Number (IIN) checking of beginning of credit card number

// 34, 37
+ (BOOL)isAmericanExpressIIN:(NSString *)cardNumber {
    
    if (cardNumber.length >= 2) {
        NSString *iinString = [cardNumber substringToIndex:2];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSInteger iin = [[numberFormatter numberFromString:iinString] integerValue];
        if (iin == 34 || iin == 37) {
            return YES;
        }
    }
    return NO;
}

// 6011, 622126-622925, 644-649, 65
+ (BOOL)isDiscoverIIN:(NSString *)cardNumber {
    
    if (cardNumber.length >= 6) {
        NSString *iinString = [cardNumber substringToIndex:6];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSInteger iin = [[numberFormatter numberFromString:iinString] integerValue];
        if (iin >= 622126 && iin <= 622925) {
            return YES;
        }
    }
    if (cardNumber.length >= 4) {
        NSString *iinString = [cardNumber substringToIndex:4];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSInteger iin = [[numberFormatter numberFromString:iinString] integerValue];
        if (iin == 6011) {
            return YES;
        }
    }
    if (cardNumber.length >= 3) {
        NSString *iinString = [cardNumber substringToIndex:3];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSInteger iin = [[numberFormatter numberFromString:iinString] integerValue];
        if (iin >= 644 && iin <= 649) {
            return YES;
        }
    }
    if (cardNumber.length >= 2) {
        NSString *iinString = [cardNumber substringToIndex:2];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSInteger iin = [[numberFormatter numberFromString:iinString] integerValue];
        if (iin == 65) {
            return YES;
        }
    }
    return NO;
}

// 51-55
+ (BOOL)isMasterCardIIN:(NSString *)cardNumber {
    
    if (cardNumber.length >= 2) {
        NSString *iinString = [cardNumber substringToIndex:2];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSInteger iin = [[numberFormatter numberFromString:iinString] integerValue];
        if (iin >= 51 && iin <= 55) {
            return YES;
        }
    }
    return NO;
}

// 4
+ (BOOL)isVisaIIN:(NSString *)cardNumber {
    
    if (cardNumber.length >= 1) {
        if ([cardNumber characterAtIndex:0] == '4') {
            return YES;
        }
    }
    return NO;
}

/**
 * Validate email string according to RFC 2822 standard
 */
+ (BOOL)isValidEmailAddress:(NSString *)email {
    
    if (!email) {
        return NO;
    }
    static NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:email];
}

/**
 * Validate phone number string, assuming string was created with only digits
 * in this class' formatted phone number field, just checks length
 */
+ (BOOL)isValidPhoneNumber:(NSString *)phone {
    
    if (!phone) {
        return NO;
    }
    if (!numChars) {
        numChars = [NSCharacterSet decimalDigitCharacterSet];
    }
    NSString *digits = [AVTextUtilities filterString:phone byCharacterSet:numChars];
    return digits.length == 10;
}

/**
 * Validate social security number string, assuming string was created with only digits in this class'
 * formatted social security number field. Allows for both all 9 and last 4 digit only numbers.
 */
+ (BOOL)isValidSocialSecurityNumber:(NSString *)socialSecurity {
    
    if (!socialSecurity) {
        return NO;
    }
    if (!numChars) {
        numChars = [NSCharacterSet decimalDigitCharacterSet];
    }
    NSString *ssNumber = [AVTextUtilities filterString:socialSecurity byCharacterSet:numChars];
    if (ssNumber.length == 9) {
        NSString *areaNumber = [ssNumber substringToIndex:3];
        if ([areaNumber isEqualToString:@"000"] || [areaNumber isEqualToString:@"666"]) { // No all 0 groups or 666 area number
            return NO;
        }
        if ([[ssNumber substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"00"] || [[ssNumber substringFromIndex:5] isEqualToString:@"0000"]) {
            return NO;
        }
        if ([ssNumber characterAtIndex:0] == '9') { // 900-999 reserved area numbers
            return NO;
        }
        /*The SSA used 219-09-9999 in a promotional pamphlet in 1940. In 1938, a wallet manufacturer inserted
         a sample Social Security card in each of its wallets as part of a marketing effort. The sample was a
         copy of Hilda Schrader Whitcher’s card, with the SSN 078-05-1120. Hilda was secretary to the Vice
         President of Marketing of the firm. (Note that the Vice President did not copy his own card.)
         According to the SSA, over 40,000 people have used this SSN.*/
        if ([ssNumber isEqualToString:@"219099999"] || [ssNumber isEqualToString:@"078051120"]) {
            return NO;
        }
        return YES;
    }
    else if (ssNumber.length == 4 && ![ssNumber isEqualToString:@"0000"]) {
        return YES;
    }
    return NO;
}

/**
 * Validate social security or individual taxpayer identification number string, assuming string was created with only
 * digits in this class' formatted social security number field. Allows for both all 9 and last 4 digit only numbers.
 */
+ (BOOL)isValidSocialSecurityOrIndividualTaxIdNumber:(NSString *)socialSecurityOrTaxId {
    
    if (!socialSecurityOrTaxId) {
        return NO;
    }
    if (!numChars) {
        numChars = [NSCharacterSet decimalDigitCharacterSet];
    }
    NSString *ssTidNumber = [AVTextUtilities filterString:socialSecurityOrTaxId byCharacterSet:numChars];
    if (ssTidNumber.length == 9) {
        NSString *areaNumber = [ssTidNumber substringToIndex:3];
        if ([areaNumber isEqualToString:@"000"] || [areaNumber isEqualToString:@"666"]) { // No all 0 groups or 666 area number
            return NO;
        }
        if ([[ssTidNumber substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"00"] || [[ssTidNumber substringFromIndex:5] isEqualToString:@"0000"]) {
            return NO;
        }
        if ([ssTidNumber characterAtIndex:0] == '9') { // 900-999 ITIN
            unichar groupTens = [ssTidNumber characterAtIndex:3];
            unichar groupOnes = [ssTidNumber characterAtIndex:4];
            if (groupTens == '7' || (groupTens == '8' && groupOnes != '9') || (groupTens == '9' && groupOnes != '3')) { // 70 to 99 (excluding 89 and 93)
                return YES;
            }
            return NO;
        }
        /*The SSA used 219-09-9999 in a promotional pamphlet in 1940. In 1938, a wallet manufacturer inserted
         a sample Social Security card in each of its wallets as part of a marketing effort. The sample was a
         copy of Hilda Schrader Whitcher’s card, with the SSN 078-05-1120. Hilda was secretary to the Vice
         President of Marketing of the firm. (Note that the Vice President did not copy his own card.)
         According to the SSA, over 40,000 people have used this SSN.*/
        if ([ssTidNumber isEqualToString:@"219099999"] || [ssTidNumber isEqualToString:@"078051120"]) {
            return NO;
        }
        return YES;
    }
    else if (ssTidNumber.length == 4 && ![ssTidNumber isEqualToString:@"0000"]) {
        return YES;
    }
    return NO;
}

/**
 * Validates a credit card number string using the Luhn algorithm
 */
+ (BOOL)isValidCreditCardNumber:(NSString *)creditCardNumber {
    
    if (!creditCardNumber) {
        return NO;
    }
    if (!numChars) {
        numChars = [NSCharacterSet decimalDigitCharacterSet];
    }
    NSString *ccNumber = [AVTextUtilities filterString:creditCardNumber byCharacterSet:numChars];
    if ([AVTextUtilities isAmericanExpressIIN:ccNumber]) {
        if (ccNumber.length != 15) {
            return NO;
        }
    }
    else if ([AVTextUtilities isMasterCardIIN:ccNumber]) {
        if (ccNumber.length != 16) {
            return NO;
        }
    }
    else if ([AVTextUtilities isVisaIIN:ccNumber]) {
        if (ccNumber.length != 13 && ccNumber.length != 16) {
            return NO;
        }
    }
    else if ([AVTextUtilities isDiscoverIIN:ccNumber]) {
        if (ccNumber.length != 16) {
            return NO;
        }
    }
    else {
        return NO;
    }
    NSInteger end = ccNumber.length - 1;
    NSInteger sum = 0;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    for (NSInteger i = 0; i < ccNumber.length; i++) {
        NSInteger digit = [[numberFormatter numberFromString:[NSString stringWithFormat:@"%c", [ccNumber characterAtIndex:end - i]]] integerValue];
        sum += !(i % 2) ? digit : digit > 4 ? ((digit * 2) % 10) + 1 : digit * 2;
    }
    return sum != 0 && !(sum % 10);
}

/**
 * Validates a Routing Transit Number (RTN)
 */
+ (BOOL)isValidRoutingNumber:(NSString *)routingNumber {
    
    if (routingNumber.length != 9) {
        return NO;
    }
    NSInteger sum = 0;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    for (NSInteger i = 0; i < 9; i += 3) {
        NSInteger digit = [[numberFormatter numberFromString:[NSString stringWithFormat:@"%c", [routingNumber characterAtIndex:i]]] integerValue];
        sum += digit * 3;
        digit = [[numberFormatter numberFromString:[NSString stringWithFormat:@"%c", [routingNumber characterAtIndex:i + 1]]] integerValue];
        sum += digit * 7;
        digit = [[numberFormatter numberFromString:[NSString stringWithFormat:@"%c", [routingNumber characterAtIndex:i + 2]]] integerValue];
        sum += digit;
    }
    return sum != 0 && !(sum % 10);
}

/**
 * Validate ACH account number string, assuming string was created with only digits
 * in this class' generic digit field
 */
+ (BOOL)isValidAchAccountNumber:(NSString *)accountNumber {
    
    if (accountNumber.length >= 4 && accountNumber.length <= 17) {
        return YES;
    }
    return NO;
}

/**
 * An obfuscated version of the specificed number string with all digit characters replaced
 * by '●' except for the specified number of shown digits at the end of the number
 */
+ (NSString *)obfuscatedNumber:(NSString *)number showNumDigits:(NSInteger)showNumDigits {
    
    if (number) {
        if (showNumDigits > number.length) {
            return number;
        }
        if (!numChars) {
            numChars = [NSCharacterSet decimalDigitCharacterSet];
        }
        NSMutableString *obfuscatedNumber = [NSMutableString string];
        for (NSInteger i = 0; i < number.length - showNumDigits; i++) {
            if ([numChars characterIsMember:[number characterAtIndex:i]]) {
                [obfuscatedNumber appendString:kObfuscationChar];
            }
            else {
                [obfuscatedNumber appendString:[number substringWithRange:NSMakeRange(i, 1)]];
            }
        }
        [obfuscatedNumber appendString:[number substringFromIndex:number.length - showNumDigits]];
        return [obfuscatedNumber copy];
    }
    return nil;
}

//static char letters[95];

/**
 * Returns a random string of the specified length using the 95 printable ASCII characters
 */
+ (NSString *)randomStringOfLength:(NSInteger)length {
    
    // Generate array of the 95 printable ASCII characters
//    if (letters[0] != ' ') {
//        for (NSInteger i = 0; i < 95; i++) {
//            letters[i] = i + ' ';
//        }
//    }
//    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
//    for (NSInteger i = 0; i < length; i++) {
//        [randomString appendFormat:@"%C", letters[arc4random() % strlen(letters)]];
//    }
//    return randomString;
    
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

+ (BOOL)isValidStateName:(NSString *)state {
    
    NSArray *stateAbbreviations = @[
                          @"AL",
                          @"AK",
                          @"AZ",
                          @"AR",
                          @"CA",
                          @"CO",
                          @"CT",
                          @"DE",
                          @"FL",
                          @"GA",
                          @"HI",
                          @"ID",
                          @"IL",
                          @"IN",
                          @"IA",
                          @"KS",
                          @"KY",
                          @"LA",
                          @"ME",
                          @"MD",
                          @"MA",
                          @"MI",
                          @"MN",
                          @"MS",
                          @"MO",
                          @"MT",
                          @"NE",
                          @"NV",
                          @"NH",
                          @"NJ",
                          @"NM",
                          @"NY",
                          @"NC",
                          @"ND",
                          @"OH",
                          @"OK",
                          @"OR",
                          @"PA",
                          @"RI",
                          @"SC",
                          @"SD",
                          @"TN",
                          @"TX",
                          @"UT",
                          @"VT",
                          @"VA",
                          @"WA",
                          @"WV",
                          @"WI",
                          @"WY",
                          @"AS", // American Samoa
                          @"DC", // District of Columbia
                          @"FM", // Federated States of Micronesia
                          @"GU", // Guam
                          @"MH", // Marshall Islands
                          @"MP", // Northern Mariana Islands
                          @"PW", // Palau
                          @"PR", // Puerto Rico
                          @"VI"  // Virgin Islands
                          ];
    if ([stateAbbreviations indexOfObject:state] != NSNotFound) {
        return YES;
    }
    return NO;

}

+ (BOOL)isValidZipcode:(NSString *)zipcode forCountryCode:(NSString *)countryCode {
    if ([countryCode isEqualToString:@"USA"]) {
        if (zipcode.length == 5) {
            return YES;
        }
        return NO;
    }
    else if ([countryCode isEqualToString:@"CAN"]) {
        if (zipcode.length == 6 || zipcode.length == 7) {
            return YES;
        }
        return NO;
    }
    else if ([countryCode isEqualToString:@"AUS"]) {
        if (zipcode.length == 4) {
            return YES;
        }
        return NO;
    }
    return NO;
}

+ (int) maxZipcodeLength:(NSString *)countryCode {
    
    if([countryCode isEqualToString:@"CAN"]) {
        return 7;
    }
    
    if([countryCode isEqualToString:@"AUS"]) {
        return 4;
    }
    
    return 5;
}
@end
