//
//  FirstMakeFolderViewControlelr.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import UIKit

class FirstMakeFolderViewControlelr: BaseHomeViewController<FirstMakeFolderBaseView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
   
    override func viewDidLayoutSubviews() {
        homeView.folderImageSetting(size: homeView.frame.width)
    }
    
}
