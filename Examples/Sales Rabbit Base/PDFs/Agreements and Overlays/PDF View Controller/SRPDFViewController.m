//
//  ProviderAgreementViewController.m
//  DishTech
//
//  Created by Brown Family on 6/18/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import "SRPDFViewController.h"
#import "CGPDFDocument.h"
#import "Constants.h"
#import "TextOverlayView.h"

@implementation SRPDFViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dismissAll:(BOOL)animated
{
    for (TextOverlayView *overlayView in self.activeOverlayViews) {
        [overlayView dismissAll:animated];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    for (TextOverlayView *overlayView in self.activeOverlayViews) {
        [overlayView setPopoverLocation];
    }
}

- (BOOL)verifySignature
{
    for (TextOverlayView *overlayView in self.activeOverlayViews)
    {
        if (![overlayView verifySignature]) {
            return NO;
        }
    }
    return YES;
}

-(void) allowSignature:(BOOL)allowed
{
    for (TextOverlayView *overlayView in self.activeOverlayViews) {
        overlayView.allowSignature = allowed;
    }
}

- (NSData *)agreementPdfFile {
    
    NSDictionary *docInfo = @{(NSString *)kCGPDFContextAuthor:kPdfAuthor,
                              (NSString *)kCGPDFContextCreator:kPdfCreator,
                              (NSString *)kCGPDFContextTitle:kPdfTitle};
    CGPDFDocumentRef templatePDF = CGPDFDocumentCreateX((__bridge CFURLRef)(document.fileURL), document.password);
    NSMutableData *pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, docInfo);
    
    size_t numPages = CGPDFDocumentGetNumberOfPages(templatePDF);
    for (size_t pageNumber = 1; pageNumber <= numPages; pageNumber++) {
        CGPDFPageRef templatePage = CGPDFDocumentGetPage(templatePDF, pageNumber);
        [self drawPDFPageToCurrentContext:templatePage];
        
        // Draw text overlay if exists for this page
        TextOverlayView *textOverlayView = [self.textOverlayViews objectForKey:[NSNumber numberWithInt:(int)pageNumber]];
        if (textOverlayView) {
            textOverlayView.frame = CGPDFPageGetBoxRect(templatePage, kCGPDFCropBox);
            [self setNeedsDisplay:textOverlayView];
            [textOverlayView.layer renderInContext:UIGraphicsGetCurrentContext()];
            [self setNeedsDisplay:textOverlayView]; // Set needs display again to render rasterized in display again
        }
    }
    CGPDFDocumentRelease(templatePDF);
    UIGraphicsEndPDFContext();
    return pdfData;
}

- (void)drawPDFPageToCurrentContext:(CGPDFPageRef)pdfPage {
    
    CGRect pdfPageBounds = CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox);
    UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip context due to different origins
    CGContextTranslateCTM(context, 0.0, pdfPageBounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Copy content of template page to new PDF file
    CGContextDrawPDFPage(context, pdfPage);
    
    // Flip context back
    CGContextTranslateCTM(context, 0.0, pdfPageBounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
}

/** Set the view and all subviews recursively to require rerendering so that they will render unrasterized in PDF */
- (void)setNeedsDisplay:(UIView *)view {
    
    [view setNeedsDisplay];
    for (UIView *subView in view.subviews) {
        [self setNeedsDisplay:subView];
    }
}

#pragma mark - Custom accessors

- (void)setAgreementModel:(NSManagedObject *)agreementModel {
    
    if (_agreementModel) {
        for (TextOverlayView *overlayView in self.activeOverlayViews) {
            overlayView.agreementModel = nil;
        }
    }
    _agreementModel = agreementModel;
    for (TextOverlayView *overlayView in self.activeOverlayViews) {
        overlayView.agreementModel = agreementModel;
    }
}

@end
