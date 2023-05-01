//
//  InlineHostView+HostingCell.swift
//  InlineHostingViewApp
//
//  Created by Stephan Casas on 5/1/23.
//

import AppKit;
import SwiftUI;

extension InlineHostingView {
    
    class HostingCell<Content: View>: NSTextAttachmentCell {
        
        private let contentView: () -> Content;
        private let contentHost: NSHostingView<Content>;
        
        init(_ content: @escaping () -> Content) {
            self.contentView = content;
            self.contentHost = NSHostingView(rootView: contentView());
            
            super.init();
        }
        
        override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
            guard let controlView = controlView else {
                return;
            }
            
            controlView.addSubview(contentHost);
            contentHost.frame = NSRect(
                x: cellFrame.origin.x,
                y: cellFrame.origin.y,
                width: cellFrame.width,
                height: cellFrame.height);
        }
        
        override func cellSize() -> NSSize {
            self.contentHost.fittingSize;
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
