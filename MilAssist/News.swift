//
//  News.swift
//  MilApp
//
//  Created by Hovak Davtyan on 6/20/17.
//  Copyright © 2017 Hovak Davtyan. All rights reserved.
//

import Foundation
import UIKit

struct News {
    var imageURL: URL?
    var dateCreated: Date?
    var articleURL: URL?
    var title: String?
    var description: String?
    var type: NewsType?
}

enum NewsType : Int {
    case article = 1
    case video = 2
    case article1000Plus = 3
}

