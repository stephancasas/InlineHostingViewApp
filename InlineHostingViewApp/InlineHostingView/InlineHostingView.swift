//
//  InlineHostView.swift
//  InlineHostViewApp
//
//  Created by Stephan Casas on 4/30/23.
//

import AppKit;
import SwiftUI;
import Combine;


// MARK: - Custom SwiftUI NSViewRepresentable with NSTextField and NSHostingView
struct InlineHostingView: NSViewRepresentable {
    
    private var displayString: String;
    private var contentAnchors: [Int] = [];
    
    let contentViews: [() -> AnyView];
    
    init(
        _ usingString: String,
        replaceText: String = "{{ content }}",
        _ withContent: () -> any View...
    ) {
        self.displayString = usingString;
        
        for anchor in self.displayString.ranges(of: replaceText) {
            let anchor = self.displayString.distance(
                from: self.displayString.startIndex,
                to: anchor.lowerBound);
            
            // consider offset for prior replacements in next step
            let offset = self.contentAnchors.count * replaceText.count;
            
            contentAnchors.append(anchor - offset + self.contentAnchors.count);
        }
        
        self.displayString = self.displayString.replacingOccurrences(
            of: replaceText,
            with: ""
        );
        
        self.contentViews = withContent.map({ contentView in
            { AnyView(contentView()) };
        });
    }
    
    /// The text color for the display string
    private var color: NSColor = .secondaryLabelColor;
    
    /// Set the text color for the display string.
    func color(_ color: NSColor) -> Self {
        var copy = self;
        copy.color = color;
        
        return copy;
    }
    
    /// The font for the display string
    private var font: NSFont = .systemFont(ofSize: 14, weight: .semibold);
    
    /// Set the font for the display string.
    func font(_ font: NSFont) -> Self {
        var copy = self;
        copy.font = font;
        
        return copy;
    }
    
    /// The alignment for the display string
    private var alignment: NSTextAlignment = .center;
    
    /// Set the alignment for the display string.
    func align(_ alignment: NSTextAlignment) -> Self {
        var copy = self;
        copy.alignment = alignment;
        
        return copy;
    }
    
    func makeNSView(context: Context) -> OffsetTextField {
        let textView = OffsetTextField();
        
        textView.translatesAutoresizingMaskIntoConstraints = false;
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal);
        textView.setContentCompressionResistancePriority(.required, for: .vertical);
        
        textView.isBezeled = false;
        textView.isEditable = false;
        textView.isSelectable = false;
        textView.drawsBackground = false;
        textView.isAutomaticTextCompletionEnabled = false;
        
        textView.lineBreakMode = .byWordWrapping;
        textView.maximumNumberOfLines = 0;
        
        textView.alignment = .center;
        textView.font = self.font;
        textView.textColor = self.color;
        
        let attributedString = NSMutableAttributedString(string: self.displayString);
        attributedString.setAlignment(.center, range: NSRange(
            location: 0,
            length: attributedString.length - 1)
        );
        
        contentAnchors.enumerated().forEach { anchor in
            let offset = anchor.offset;
            let anchor = anchor.element;
            
            if offset > contentViews.count {
                NSLog("[InlineHostTextView] Content anchor occurrences exceed given content views.");
                return;
            }
            
            let attachment = NSTextAttachment();
            attachment.attachmentCell = HostingCell(
                self.contentViews[offset]
            );
            
            attributedString.insert(
                NSAttributedString(
                    attachment: attachment),
                at: anchor
            );
        }
        
        textView.attributedStringValue = attributedString;
        
        return textView;
    }
    
    // MARK: - NSTextView with Vertical Offset
    func updateNSView(_ nsView: OffsetTextField, context: Context) {
        /// If we needed in this to be a usable control,
        /// we'd populate this method and add a `Coordinator`.
    }
    
}



