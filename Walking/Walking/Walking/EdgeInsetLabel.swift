//
//  HeadlineLabel.swift
//  views
//
//  Created by Dennis Schmidt on 30/08/2016.
//  Copyright © 2016 Nytorv. All rights reserved.
//

import UIKit

class EdgeInsetLabel : UILabel {
    
    var textInsets = UIEdgeInsets.zero {
 
        didSet { invalidateIntrinsicContentSize() }
    
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    
        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
        
    }
    
    override func drawText(in rect: CGRect) {
        
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    
    }
    
}
