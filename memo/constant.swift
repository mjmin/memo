//
//  constant.swift
//  memo
//
//  Created by Minji Kim on 2022/09/03.
//

import Foundation
import UIKit

func getPointColor(mode : UIUserInterfaceStyle ) -> UIColor{
    if mode == .dark {
        // User Interface is Dark
        return .systemOrange
    } else {
        // User Interface is Light
        return .systemBlue
    }
}
