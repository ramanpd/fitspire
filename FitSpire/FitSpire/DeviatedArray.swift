//
//  DeviatedArray.swift
//  FitSpire
//
//  Created by Connor Clancy on 08/04/2019.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import Foundation

class DeviatedArray{
    
    private var BUFFER: [Double] = [0,0,0,0,0,0,0,0,0,0,0]
    private var scoreTotal: Double = 0, scoreAve: Double = 0, totalAve: Double = 0, setAve: Double = 0
    
    public func leftshift(value: Double){
        var i = 0
        while(i < BUFFER.count-1){
            BUFFER[i] = BUFFER[i+1]
            i += 1
        }
        BUFFER[BUFFER.count-1] = value
    }
    
    public func average() -> Double{
        var i = 0
        var total:Double = 0
        while(i < BUFFER.count){
            total += BUFFER[i]
            i += 1
        }
        return total / Double(BUFFER.count-1)
    }
    
    public func stnOffsetCalc(nextValue: Double, Iteration: Double) -> Double{
        scoreTotal = scoreTotal + nextValue
        scoreAve = scoreTotal / Iteration
        
        if(pow(nextValue - scoreAve, 2) != Double.infinity){
            totalAve = totalAve + pow(nextValue - scoreAve, 2)
        }
        setAve = totalAve / Iteration
        return sqrt(setAve) + setAve
    }
    
    /*
     Getter methods
     */
    public func Array() -> [Double]{
        return BUFFER
    }
    
    public func mid() -> Double{
        return BUFFER[5]
    }
}

