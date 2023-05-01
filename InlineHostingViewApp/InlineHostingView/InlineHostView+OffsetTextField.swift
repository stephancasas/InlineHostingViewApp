//
//  InlineHostView+OffsetTextField.swift
//  InlineHostingViewApp
//
//  Created by Stephan Casas on 5/1/23.
//

import Foundation
import AppKit;

extension InlineHostingView {
    
    class OffsetTextField: NSTextField {
        
        /// Reformat the attributed string to vertically align content and
        /// the display string.
        private func reformatAttributedString(forRect: NSRect) {
            let layoutManager = NSLayoutManager();
            let textContainer = NSTextContainer(size: forRect.size);
            let textStorage = NSTextStorage(attributedString: self.attributedStringValue);
            
            textStorage.addLayoutManager(layoutManager);
            layoutManager.addTextContainer(textContainer);
            
            let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize);
            textStorage.font = font;
            
            let reformattedString = NSMutableAttributedString(
                attributedString: self.attributedStringValue
            );
            
            var lineOffset = 0;
            var lineCount = 0;
            while lineOffset < textStorage.length {
                var lineRange = NSRange();
                layoutManager.lineFragmentRect(
                    forGlyphAt: lineOffset,
                    effectiveRange: &lineRange);
                
                var charRanges: [NSRange] = [];
                
                var tallestLineChar: CGFloat = 0;
                var tallestLineAttachment: CGFloat = 0;
                
                for charOffset in lineOffset..<lineRange.upperBound {
                    let attachmentHeight = layoutManager.attachmentSize(forGlyphAt: charOffset).height;
                    if attachmentHeight > 0 {
                        if attachmentHeight > tallestLineAttachment {
                            tallestLineAttachment = attachmentHeight;
                        }
                        continue;
                    }
                    
                    if charRanges.isEmpty || charRanges.last?.upperBound != charOffset {
                        charRanges.append(NSRange(location: charOffset, length: 1));
                    } else {
                        let existing = charRanges.removeLast();
                        charRanges.append(NSRange(
                            location: existing.location,
                            length: existing.length + 1
                        ));
                    }
                    
                    // The actual pixel height of the glyph -- no leading considered.
                    let glyphHeight = font.boundingRect(
                        forGlyph: layoutManager.glyph(at: charOffset)
                    ).height;
                    
                    if glyphHeight > tallestLineChar {
                        tallestLineChar = glyphHeight;
                    }
                }
                
                if tallestLineAttachment > tallestLineChar {
                    let offset = ((tallestLineAttachment - tallestLineChar) / 2);
                    for charRange in charRanges {
                        reformattedString.addAttribute(.baselineOffset, value: offset, range: charRange);
                    }
                }
                
                lineOffset = NSMaxRange(lineRange);
                lineCount += 1;
            }
            
            self.attributedStringValue = reformattedString;
        }
        
        override func draw(_ dirtyRect: NSRect) {
            self.reformatAttributedString(forRect: dirtyRect);
            super.draw(dirtyRect);
        }
        
    }
    
}
