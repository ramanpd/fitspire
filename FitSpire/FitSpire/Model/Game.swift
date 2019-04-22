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
    var gameType:String = ""
    var player1Name:String = ""
    var player1ID:String = ""
    var player2ID:String = ""
    var player1Score : Int = 0
    var player2Score : Int = 0
    var gameFinished : Bool = false
    var target : Int = 0
    var gameStarted: Bool = false

}
