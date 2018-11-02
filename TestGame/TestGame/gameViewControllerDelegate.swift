//
//  gameViewControllerDelegate.swift
//  TestGame
//
//  Created by Shawn Chen on 11/2/18.
//  Copyright © 2018 Jay Peters. All rights reserved.
//

import SpriteKit

protocol GameViewControllerDelegate: class {
    func callMethod(control:String, addRock:Bool?)
    func removeRock()
}
