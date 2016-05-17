//
//  DWWDrawingBase.swift
//  DWWDrawing
//
//  Created by 段 文武 on 16/5/6.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation
import UIKit

enum AxisYType {
    case Right
    case Left
}

struct DWWDraingContext {
    var startIndex:Int//绘制起点
    var endIndex:Int//绘制结束点
    var axisYType:AxisYType//y轴在左边还是右边
    var axisYWidth:CGFloat//y轴需要的宽度
    var plotWidth:CGFloat//每个绘制小块的宽度
    var plotPadding:CGFloat//相邻绘制小块之间的间距
    var selectedIndex:Int//选中的索引
    var touchPoint:CGPoint//触摸选中时的位置
}

protocol DWWDrawing {
    
    var frame:CGRect{get set}
    
    var plotData:NSArray{get set}
    
    func buildPlotData(originData:NSArray)
    
    func draw(context:CGContext, drawingContext:DWWDraingContext)
}
