//
//  CMSCustomSlider.swift
//  CMSAudio
//
//  Created by admin on 2020/9/4.
//  Copyright © 2020 Sihj. All rights reserved.
//

import UIKit

public class CMSCustomSlider: UISlider {

    public var sliderHeight: CGFloat = 5.0
    
    public override func minimumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }
    
    public override func maximumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }

    // 控制slider的宽和高，这个方法才是真正的改变slider滑道的高的
    public override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.trackRect(forBounds: bounds)
        layer.cornerRadius = sliderHeight/2
        return CGRect.init(x: rect.origin.x, y: (bounds.size.height-sliderHeight)/2, width: bounds.size.width, height: sliderHeight)
    }
    
    // 改变滑块的触摸范围
    public override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        return super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
    }


}
