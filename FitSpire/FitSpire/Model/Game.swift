//
//  Game.swift
//  FitSpire
//
//  Created by Raman Prasad on 08/04/19.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit

class Game: NSObject {
    
    var gameID:AnyObject!
    var player1ID:AnyObject!
    var player2ID: AnyObject!
    var player1Score : Int = 0
    var player2Score : Int = 0
    var gameFinished : Bool = false
    var target : Int = 0
    var gameStarted: Bool = false

}
