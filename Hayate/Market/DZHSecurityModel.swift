//
//  DZHStockModel.swift
//  Hayate
//
//  Created by Duanwwu on 16/6/5.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public enum DZHSecurityFlag: Int {
    case None//无
    case Margin//融资融券
    case XSBBasic//新三板基础层
    case XSBInnovate//新三板创新层
    case XGMBond//公募债
}

public enum DZHMarketType: Int {
    case SH		= 1	// 上海
    case SZ		= 2	// 深圳
    case HK		= 3 // 香港
    case IX		= 4 // 全球指数
    case CK		= 5 // 全球期货
    case FE		= 6 // 外汇
    case OF		= 7 // 开放基金
    case BI		= 8	// 板块指数
    case SF		= 9 // 上海金融期货（股指期货）
    case SC		= 10 // 上海期货
    case ZC		= 11 // 郑州期货
    case DC		= 12 // 大连期货
    case SG		= 13 // 上海黄金
    case SO     = 14 // 三板市场
    case ZH		= 15 // B转H股
    case OP     = 16 // 期权市场
    case HKT    = 17 // 港股通
    case US		= 18 // 美股
    
    init(market: String) {
        switch market {
        case "SH":
            self = .SH
        case "SZ":
            self = .SZ
        case "HK":
            self = .HK
        case "IX":
            self = .IX
        case "CK":
            self = .CK
        case "FE":
            self = .FE
        case "IB":
            self = .FE
        case "OF":
            self = .OF
        case "BI":
            self = .BI
        case "SF":
            self = .SF
        case "SC":
            self = .SC
        case "ZC":
            self = .ZC
        case "DC":
            self = .DC
        case "SG":
            self = .SG
        case "SO":
            self = .SO
        case "ZH":
            self = .ZH
        case "HH":
            self = .HKT
        case "NS":
            self = .US
        case "NY":
            self = .US
        default:
            self = .SH
        }
    }
}

public enum DZHSecurityType: Int {
    case UNKNOWN        = -1//不清楚类型时使用
    case INDEX          = 0 // 指数
    case STOCK          = 1	// 股票
    case FUND           = 2 // 基金
    case BOND           = 3 // 债券
    case OTHER_STOCK    = 4 // 其它股票
    case OPTION         = 5 // 选择权
    case EXCHANGE       = 6	// 外汇
    case FUTURE         = 7 // 期货
    case FTR_IDX		= 8 // 期指
    case RGZ			= 9 // 认购证
    case ETF			= 10 // ETF
    case LOF			= 11 // LOF
    case COV_BOND       = 12 // 可转债
    case TRUST          = 13 // 信托
    case WARRANT        = 14 // 权证
    case REPO           = 15 // 回购
    case STOCKB         = 16 // B股
    case COMM           = 17 // 商品现货
    case ENTRY          = 18 // 入库
    case FENJIAFUND     = 27 //分级A基金
    case FENJIBFUND     = 28 //分级B基金
    case FENJIMUFUND    = 29 //分级母基金
}

public enum DZHValueVaryType {
    case Rise
    case Fall
    case Cross
    
    init(price: CInt, otherPrice: CInt) {
        if price > otherPrice {
            self = .Rise
        }else if price < otherPrice {
            self = .Fall
        }else {
            self = .Cross
        }
    }
}

public class DZHSecurityModel: NSObject {
    public var code: NSString//证券代码
    public var briefCode: NSString?//去掉市场代码
    public var marketType: DZHMarketType//市场类型
    public var name: NSString?//证券名称
    public var lastClose: CInt = 0//昨收
    public var price: CInt = 0//最新价
    public var high: CInt = 0//最高价
    public var low: CInt = 0//最低价
    public var precision: CInt = 0//价格小数位数
    public var flag: DZHSecurityFlag = .None//证券标记
    public var type: DZHSecurityType = .UNKNOWN//证券类型
    
    init(code: NSString) {
        self.code = code
        if (code.length > 2)
        {
            self.briefCode = code.substringFromIndex(2);
            self.marketType = DZHMarketType(market: code.substringToIndex(2))
        }else{
            self.marketType = .SH
        }
        super.init()
    }
}

public class DZHTechnicalModel: NSObject {
    public var max: Int = 0
    public var min: Int = 0
    public var items = NSMutableArray()
    
    //对数据进行处理
    func process(model: DZHSecurityModel, originData: NSMutableArray, update: HayatePageUpdate) {
//        if update.type == .EndAppend {
//            let index = update.range.location
//            var lastItem: AnyObject? = index - 1 >= 0 ? originData.objectAtIndex(index - 1) : nil
//            for origin in originData.subarrayWithRange(update.range) {
//                self.processItem(curItem: origin, lastItem: lastItem)
//                lastItem = item
//            }
//        }else if update.type == .FrontInsert {
//            var lastItem: AnyObject? = nil
//            for origin in originData.subarrayWithRange(update.range) {
//                self.processItem(curItem: origin, lastItem: lastItem)
//                lastItem = item
//            }
//        }else if update.type == .Update {
//            var updateData = [AnyObject]()
//            let index = update.range.location
//            var lastClose = index - 1 >= 0 ? (originData.objectAtIndex(index - 1) as! DZHResponsePackage2944Item).close : 0
//            for origin in originData.subarrayWithRange(update.range) {
//                let item = origin as! DZHResponsePackage2944Item
//                let model = DZHKLineItemModel(origin: item)
//                model.type = DZHValueVaryType(price: item.close, otherPrice: lastClose)
//                updateData.append(model)
//                lastClose = item.close
//            }
//            items.replaceObjectsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(index, items.count - index)), withObjects: updateData)
//        }
    }
    
    func processItem(curItem: AnyObject, lastItem: AnyObject) {
        
    }
    
    //计算区间的最大值最小值
    func calculateMaxAndMin(from: Int, to: Int) {
        
    }
}

public class DZHKLineItemModel: NSObject {
    public var type: DZHValueVaryType = .Cross
    public var origin: DZHResponsePackage2944Item
    
    init(origin: DZHResponsePackage2944Item) {
        self.origin = origin
    }
}

public class DZHKLineModel: DZHTechnicalModel {
    
    public func process(model: DZHSecurityModel, originData: NSMutableArray, update: HayatePageUpdate) {
        if update.type == .EndAppend {
            var lastClose = (items.lastObject != nil) ? (items.lastObject as! DZHKLineItemModel).origin.close : 0
            for origin in originData.subarrayWithRange(update.range) {
                let item = origin as! DZHResponsePackage2944Item
                let model = DZHKLineItemModel(origin: item)
                model.type = DZHValueVaryType(price: item.close, otherPrice: lastClose)
                items.addObject(model)
                lastClose = item.close
            }
        }else if update.type == .FrontInsert {
            var lastClose: CInt = 0
            for origin in originData.subarrayWithRange(update.range) {
                let item = origin as! DZHResponsePackage2944Item
                let model = DZHKLineItemModel(origin: item)
                model.type = DZHValueVaryType(price: item.close, otherPrice: lastClose)
                items.insertObject(model, atIndex: 0)
                lastClose = item.close
            }
        }else if update.type == .Update {
            var updateData = [AnyObject]()
            let index = update.range.location
            var lastClose = index - 1 >= 0 ? (originData.objectAtIndex(index - 1) as! DZHResponsePackage2944Item).close : 0
            for origin in originData.subarrayWithRange(update.range) {
                let item = origin as! DZHResponsePackage2944Item
                let model = DZHKLineItemModel(origin: item)
                model.type = DZHValueVaryType(price: item.close, otherPrice: lastClose)
                updateData.append(model)
                lastClose = item.close
            }
            items.replaceObjectsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(index, items.count - index)), withObjects: updateData)
        }
    }
    
    public func calculateMaxAndMin(from: Int, to: Int) {
        
    }
}

