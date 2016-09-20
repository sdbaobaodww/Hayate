//
//  DZHTechnicalModel.swift
//  Hayate
//
//  Created by Duanwwu on 16/6/8.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public let TechnicalDefaultValue = CInt.max

public class DZHKLineItemModel: NSObject,HayateDataCollectionItem {
    
    public var origin: DZHResponsePackage2944Item
    public var type: DZHValueVary = .Cross
    public var volumeType: DZHValueVary = .Cross
    
    public var exOpen: CInt = 0
    public var exClose: CInt = 0
    public var exHigh: CInt = 0
    public var exLow: CInt = 0
    public var exVolume: Int64 = 0
    public var isEXRights = false
    
    init(origin: DZHResponsePackage2944Item) {
        self.origin = origin
    }
    
    func collectionPosition() -> CInt {
        return origin.date
    }
    
    public var open: CInt {
        return isEXRights ? exOpen : origin.open
    }
    
    public var close: CInt {
        return isEXRights ? exClose : origin.close
    }
    public var high: CInt {
        return isEXRights ? exHigh : origin.high
    }
    public var low: CInt {
        return isEXRights ? exLow : origin.low
    }
    public var volume: Int64 {
        return isEXRights ? exVolume : origin.volume
    }
}

public class DZHMACDItemModel: NSObject {
    public var DIF: CInt = 0
    public var DEA: CInt = 0
    public var MACD: CInt = 0
}
