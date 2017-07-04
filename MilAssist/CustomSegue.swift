//
//  CustomSegue.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/4/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit

class CustomSegue: UIStoryboardSegue {
    override func perform() {
        
        let src = self.source
        let dst = self.destination
        src.navigationController?.pushViewController(dst, animated: true)
    }
}
