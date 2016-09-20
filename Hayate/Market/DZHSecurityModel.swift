//
//  DZHStockModel.swift
//  Hayate
//
//  Created by Duanwwu on 16/6/5.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

/**
 * 证券标记
 */
public enum DZHSecurityFlag: Int {
    case None//无
    case Margin//融资融券
    case XSBBasic//新三板基础层
    case XSBInnovate//新三板创新层
    case XGMBond//公募债
}

/**
 * 市场类型
 */
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

/**
 * 证券类型
 */
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

/**
 * 指标类型
 */
public enum DZHIndicatorsType: Int32 {
    case MINUTE         // 分时
    case MINUTE_VOL     // 分时成交量
    case MINUTE_DDX     // 分时ddx
    case MINUTE_DIFFER  // 分时单差
    case MINUTE_TOTALVOL// 分时总买卖量
    case MINUTE_SHOOT   // 分时突
    
    case KLINE          // K线
    case KLINE_MA       // K线均线
    case KLINE_VOL      // K线成交量
    case KLINE_VOL_MA   // K线成交量均线
    case KLINE_MACD     // K线MACD
    case KLINE_KDJ      // K线KDJ
    case KLINE_RSI      // K线RSI
    case KLINE_BIAS     // K线BIAS
    case KLINE_CCI      // K线CCI
    case KLINE_DDX      // K线DDX
    case KLINE_DDY      // K线DDY
    case KLINE_DDZ      // K线DDZ
    case KLINE_MAINMEM  // K线主力资金线
    case KLINE_BS       // K线BS点
    case KLINE_BOLL     // K线BOLL
    case KLINE_WR       // K线WR
    case KLINE_DMA      // K线DMA
    case KLINE_D        // K线D信号
}

/**
 * 值比较，上涨、下跌、不变
 */
public enum DZHValueVary {
    case Rise
    case Fall
    case Cross
}

extension Int32 {
    
    public func vary(otherValue: Int32) -> DZHValueVary {
        if self > otherValue {
            return .Rise
        }else if self < otherValue {
            return .Fall
        }else {
            return .Cross
        }
    }
}

extension Int {
    
    public func vary(otherValue: Int) -> DZHValueVary {
        if self > otherValue {
            return .Rise
        }else if self < otherValue {
            return .Fall
        }else {
            return .Cross
        }
    }
}

extension Double {
    
    public func vary(otherValue: Double) -> DZHValueVary {
        if self > otherValue {
            return .Rise
        }else if self < otherValue {
            return .Fall
        }else {
            return .Cross
        }
    }
}

extension Float {
    
    public func vary(otherValue: Float) -> DZHValueVary {
        if self > otherValue {
            return .Rise
        }else if self < otherValue {
            return .Fall
        }else {
            return .Cross
        }
    }
}

/**
 * 证券数据模型，如股票、基金、债券等
 */
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
    public var indicators: Dictionary<DZHIndicatorsType, DZHIndicatorsModel> = Dictionary<DZHIndicatorsType, DZHIndicatorsModel>()//各种指标数据
    
    init(code: NSString, name: NSString?, type: DZHSecurityType) {
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
    
    convenience init(code: NSString, name: NSString?) {
        self.init(code: code, name: name, type: .UNKNOWN);
    }
    
    convenience init(code: NSString) {
        self.init(code: code, name: nil, type: .UNKNOWN);
    }
}

/**
 * 指标基础数据模型，只依赖基础数据，不依赖其它指标
 */
public class DZHIndicatorsModel: NSObject {
    public var max: Int = 0 //最大值
    public var min: Int = 0 //最小值
    public var precision: CInt = 0//小数位数
    public var items = NSMutableArray() //数据项
    
    /**
     * 对数据进行处理
     * 1，根据原始数据生成指标模型数据，并放置在items的正确位置
     * 2，可对更新后的数据进行指标计算
     */
    public func process(originData: NSMutableArray, update: HayatePageUpdate) {
        let updateDatas = originData.subarrayWithRange(update.range)
        switch update.type {
        case .Init:
            let models = self.createModelsWithOriginData(updateDatas)
            items.addObjectsFromArray(models)
        case .EndAppend:
            let models = self.createModelsWithOriginData(updateDatas)
            items.addObjectsFromArray(models)
        case .FrontInsert:
            let models = self.createModelsWithOriginData(updateDatas)
            items.insertObjects(models, atIndex: 0)
        case .Update:
            let index = update.range.location
            let models = self.createModelsWithOriginData(updateDatas)
            items.replaceObjectsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(index, items.count - index)), withObjects: models)
        default:
            break
        }
        let indexSet = self.needRecalculateIndexs(update)
        self.calculateTechnical(indexSet)//计算指标
    }
    
    public func createModelsWithOriginData(origins: [AnyObject]) -> [AnyObject] {
        return []
    }
    
    /**
     * 需要重新计算指标数据的索引集合
     * @param update 页面数据变更信息
     * @returns 索引集合
     */
    func needRecalculateIndexs(update: HayatePageUpdate) -> NSIndexSet {
        return NSIndexSet(indexesInRange: NSMakeRange(0, items.count))
    }
    
    public func calculateTechnical(updateIndex: NSIndexSet) {
        
    }
    
    /**
     * 计算区间的最大值最小值
     * @param from 开始索引
     * @param to 结束索引
     */
    public func calculateMaxAndMin(from: Int, to: Int) {
        
    }
}

public class DZHKLineModel: DZHIndicatorsModel {
    
    public override func createModelsWithOriginData(origins: [AnyObject]) -> [AnyObject] {
        var results: [AnyObject] = []
        for data in origins {
            results.append(DZHKLineItemModel(origin: data as! DZHResponsePackage2944Item))
        }
        return results
    }
    
//    override func needRecalculateIndexs(update: HayatePageUpdate) -> NSIndexSet {
//        let range = update.range
//        switch update.type {
//        case .Init:
//            return NSIndexSet(indexesInRange: range)
//        case .EndAppend:
//            return NSIndexSet(indexesInRange: NSMakeRange(range.location - 1, range.length + 1))
//        case .FrontInsert:
//            return NSIndexSet(indexesInRange: NSMakeRange(range.location, range.length + 1))
//        case .Update:
//            if range.location == 0 {
//                return NSIndexSet(indexesInRange: range)
//            }else{
//                return NSIndexSet(indexesInRange: NSMakeRange(range.location - 1, range.length + 1))
//            }
//        default:
//            return NSIndexSet(indexesInRange: range)
//        }
//    }
    
    public override func calculateTechnical(updateIndex: NSIndexSet) {
        
    }
    
    public override func calculateMaxAndMin(from: Int, to: Int) {
        
    }
}

