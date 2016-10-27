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
    case none//无
    case margin//融资融券
    case xsbBasic//新三板基础层
    case xsbInnovate//新三板创新层
    case xgmBond//公募债
}

/**
 * 市场类型
 */
public enum DZHMarketType: Int {
    case sh		= 1	// 上海
    case sz		= 2	// 深圳
    case hk		= 3 // 香港
    case ix		= 4 // 全球指数
    case ck		= 5 // 全球期货
    case fe		= 6 // 外汇
    case of		= 7 // 开放基金
    case bi		= 8	// 板块指数
    case sf		= 9 // 上海金融期货（股指期货）
    case sc		= 10 // 上海期货
    case zc		= 11 // 郑州期货
    case dc		= 12 // 大连期货
    case sg		= 13 // 上海黄金
    case so     = 14 // 三板市场
    case zh		= 15 // B转H股
    case op     = 16 // 期权市场
    case hkt    = 17 // 港股通
    case us		= 18 // 美股
    
    init(market: String) {
        switch market {
        case "SH":
            self = .sh
        case "SZ":
            self = .sz
        case "HK":
            self = .hk
        case "IX":
            self = .ix
        case "CK":
            self = .ck
        case "FE":
            self = .fe
        case "IB":
            self = .fe
        case "OF":
            self = .of
        case "BI":
            self = .bi
        case "SF":
            self = .sf
        case "SC":
            self = .sc
        case "ZC":
            self = .zc
        case "DC":
            self = .dc
        case "SG":
            self = .sg
        case "SO":
            self = .so
        case "ZH":
            self = .zh
        case "HH":
            self = .hkt
        case "NS":
            self = .us
        case "NY":
            self = .us
        default:
            self = .sh
        }
    }
}

/**
 * 证券类型
 */
public enum DZHSecurityType: Int {
    case unknown        = -1//不清楚类型时使用
    case index          = 0 // 指数
    case stock          = 1	// 股票
    case fund           = 2 // 基金
    case bond           = 3 // 债券
    case other_STOCK    = 4 // 其它股票
    case option         = 5 // 选择权
    case exchange       = 6	// 外汇
    case future         = 7 // 期货
    case ftr_IDX		= 8 // 期指
    case rgz			= 9 // 认购证
    case etf			= 10 // ETF
    case lof			= 11 // LOF
    case cov_BOND       = 12 // 可转债
    case trust          = 13 // 信托
    case warrant        = 14 // 权证
    case repo           = 15 // 回购
    case stockb         = 16 // B股
    case comm           = 17 // 商品现货
    case entry          = 18 // 入库
    case fenjiafund     = 27 //分级A基金
    case fenjibfund     = 28 //分级B基金
    case fenjimufund    = 29 //分级母基金
}

/**
 * 指标类型
 */
public enum DZHIndicatorsType: Int32 {
    case minute         // 分时
    case minute_VOL     // 分时成交量
    case minute_DDX     // 分时ddx
    case minute_DIFFER  // 分时单差
    case minute_TOTALVOL// 分时总买卖量
    case minute_SHOOT   // 分时突
    
    case kline          // K线
    case kline_MA       // K线均线
    case kline_VOL      // K线成交量
    case kline_VOL_MA   // K线成交量均线
    case kline_MACD     // K线MACD
    case kline_KDJ      // K线KDJ
    case kline_RSI      // K线RSI
    case kline_BIAS     // K线BIAS
    case kline_CCI      // K线CCI
    case kline_DDX      // K线DDX
    case kline_DDY      // K线DDY
    case kline_DDZ      // K线DDZ
    case kline_MAINMEM  // K线主力资金线
    case kline_BS       // K线BS点
    case kline_BOLL     // K线BOLL
    case kline_WR       // K线WR
    case kline_DMA      // K线DMA
    case kline_D        // K线D信号
}

/**
 * 值比较，上涨、下跌、不变
 */
public enum DZHValueVary {
    case rise
    case fall
    case cross
}

extension Int32 {
    
    public func vary(_ otherValue: Int32) -> DZHValueVary {
        if self > otherValue {
            return .rise
        }else if self < otherValue {
            return .fall
        }else {
            return .cross
        }
    }
}

extension Int {
    
    public func vary(_ otherValue: Int) -> DZHValueVary {
        if self > otherValue {
            return .rise
        }else if self < otherValue {
            return .fall
        }else {
            return .cross
        }
    }
}

extension Double {
    
    public func vary(_ otherValue: Double) -> DZHValueVary {
        if self > otherValue {
            return .rise
        }else if self < otherValue {
            return .fall
        }else {
            return .cross
        }
    }
}

extension Float {
    
    public func vary(_ otherValue: Float) -> DZHValueVary {
        if self > otherValue {
            return .rise
        }else if self < otherValue {
            return .fall
        }else {
            return .cross
        }
    }
}

/**
 * 证券数据模型，如股票、基金、债券等
 */
open class DZHSecurityModel: NSObject {
    open var code: NSString//证券代码
    open var briefCode: NSString?//去掉市场代码
    open var marketType: DZHMarketType//市场类型
    open var name: NSString?//证券名称
    open var lastClose: CInt = 0//昨收
    open var price: CInt = 0//最新价
    open var high: CInt = 0//最高价
    open var low: CInt = 0//最低价
    open var precision: CInt = 0//价格小数位数
    open var flag: DZHSecurityFlag = .none//证券标记
    open var type: DZHSecurityType = .unknown//证券类型
    open var indicators: Dictionary<DZHIndicatorsType, DZHIndicatorsModel> = Dictionary<DZHIndicatorsType, DZHIndicatorsModel>()//各种指标数据
    
    init(code: NSString, name: NSString?, type: DZHSecurityType) {
        self.code = code
        if (code.length > 2)
        {
            self.briefCode = code.substring(from: 2) as NSString?;
            self.marketType = DZHMarketType(market: code.substring(to: 2))
        }else{
            self.marketType = .sh
        }
        super.init()
    }
    
    convenience init(code: NSString, name: NSString?) {
        self.init(code: code, name: name, type: .unknown);
    }
    
    convenience init(code: NSString) {
        self.init(code: code, name: nil, type: .unknown);
    }
}

/**
 * 指标基础数据模型，只依赖基础数据，不依赖其它指标
 */
open class DZHIndicatorsModel: NSObject {
    open var max: Int = 0 //最大值
    open var min: Int = 0 //最小值
    open var precision: CInt = 0//小数位数
    open var items = NSMutableArray() //数据项
    
    /**
     * 对数据进行处理
     * 1，根据原始数据生成指标模型数据，并放置在items的正确位置
     * 2，可对更新后的数据进行指标计算
     */
    open func process(_ originData: NSMutableArray, update: HayatePageUpdate) {
        let updateDatas = originData.subarray(with: update.range)
        switch update.type {
        case .Init:
            let models = self.createModelsWithOriginData(updateDatas as [AnyObject])
            items.addObjects(from: models)
        case .endAppend:
            let models = self.createModelsWithOriginData(updateDatas as [AnyObject])
            items.addObjects(from: models)
        case .frontInsert:
            let models = self.createModelsWithOriginData(updateDatas as [AnyObject])
            items.insertObjects(models, atIndex: 0)
        case .update:
            let index = update.range.location
            let models = self.createModelsWithOriginData(updateDatas as [AnyObject])
            items.replaceObjects(at: IndexSet(integersIn: NSMakeRange(index, items.count - index).toRange() ?? 0..<0), with: models)
        default:
            break
        }
        let indexSet = self.needRecalculateIndexs(update)
        self.calculateTechnical(indexSet)//计算指标
    }
    
    open func createModelsWithOriginData(_ origins: [AnyObject]) -> [AnyObject] {
        return []
    }
    
    /**
     * 需要重新计算指标数据的索引集合
     * @param update 页面数据变更信息
     * @returns 索引集合
     */
    func needRecalculateIndexs(_ update: HayatePageUpdate) -> IndexSet {
        return IndexSet(integersIn: NSMakeRange(0, items.count).toRange()!)
    }
    
    open func calculateTechnical(_ updateIndex: IndexSet) {
        
    }
    
    /**
     * 计算区间的最大值最小值
     * @param from 开始索引
     * @param to 结束索引
     */
    open func calculateMaxAndMin(_ from: Int, to: Int) {
        
    }
}

open class DZHKLineModel: DZHIndicatorsModel {
    
    open override func createModelsWithOriginData(_ origins: [AnyObject]) -> [AnyObject] {
        var results: [AnyObject] = []
        for data in origins {
//            results.append(DZHKLineItemModel(origin: data as! DZHResponsePackage2944Item))
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
    
    open override func calculateTechnical(_ updateIndex: IndexSet) {
        
    }
    
    open override func calculateMaxAndMin(_ from: Int, to: Int) {
        
    }
}

