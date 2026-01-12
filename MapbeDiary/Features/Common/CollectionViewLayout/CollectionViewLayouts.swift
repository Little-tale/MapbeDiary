//
//  CollectionViewLayouts.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import UIKit

struct CollectionViewLayouts {
    
    static func makePlainListLayout(
        separators: Bool = true,
        backgroundColor: UIColor = .white
    ) -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = separators
        config.backgroundColor = backgroundColor
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
}

