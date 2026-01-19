//
//  CircleImage.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import UIKit

class circleImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
}
