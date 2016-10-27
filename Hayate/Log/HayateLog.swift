//
//  HayateLog.swift
//  Hayate
//
//  Created by Duanwwu on 16/9/29.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public func LOG_DEBUG(_ logModule: LogModule, _ message: String, method: String = #function, file: String = #file,
                  line: Int = #line) {
    HayateLog.instance.log(message, logLevel: LogLevel.debug, logModule: logModule, method: method, file: file, line: line)
}

public func LOG_INFO(_ logModule: LogModule, _ message: String, method: String = #function, file: String = #file,
                 line: Int = #line) {
    HayateLog.instance.log(message, logLevel: LogLevel.info, logModule: logModule, method: method, file: file, line: line)
}

public func LOG_WARN(_ logModule: LogModule, _ message: String, method: String = #function, file: String = #file,
                 line: Int = #line) {
    HayateLog.instance.log(message, logLevel: LogLevel.warn, logModule: logModule, method: method, file: file, line: line)
}

public func LOG_ERROR(_ logModule: LogModule, _ message: String, method: String = #function, file: String = #file,
                  line: Int = #line) {
    HayateLog.instance.log(message, logLevel: LogLevel.error, logModule: logModule, method: method, file: file, line: line)
}

public func LOG_FATAL(_ logModule: LogModule, _ message: String, method: String = #function, file: String = #file,
                  line: Int = #line) {
    HayateLog.instance.log(message, logLevel: LogLevel.fatal, logModule: logModule, method: method, file: file, line: line)
}

public enum LogLevel: Int16 {
    case debug
    case info
    case warn
    case error
    case fatal
    
    public func toString() -> String {
        switch self {
            case .debug: return "DEBUG"
            case .info: return "INFO"
            case .warn: return "WARN"
            case .error: return "ERROR"
            case .fatal: return "FATAL"
        }
    }
}

public enum LogModule {
    case common
    case socket
    case http
    
    public func toString() -> String {
        switch self {
            case .common: return "COMMON"
            case .socket: return "SOCKET"
            case .http: return "HTTP"
        }
    }
}

enum LogSwitch {
    case all
    case limit
    case off
}

public struct LogRule {
    let levelSwitch: LogSwitch
    let logLevel: LogLevel
    
    let moduleSwitch: LogSwitch
    let logModule: LogModule
    
    init(_ levelSwitch: LogSwitch, _ moduleSwitch: LogSwitch) {
       self.init(levelSwitch, moduleSwitch, LogLevel.debug, LogModule.common)
    }
    
    init(_ levelSwitch: LogSwitch, _ moduleSwitch: LogSwitch, _ logLevel: LogLevel, _ logModule: LogModule) {
        self.levelSwitch = levelSwitch
        self.moduleSwitch = moduleSwitch
        self.logLevel = logLevel
        self.logModule = logModule
    }
}

public class HayateLog {
    
    public static let instance: HayateLog = HayateLog()
    public let rule = LogRule(.limit, .limit, LogLevel.debug, LogModule.socket)
    
    public func log(_ message: String, logLevel: LogLevel, logModule: LogModule, method: String, file: String, line: Int) {
        print("[\(logLevel.toString())] \(logModule.toString()) \((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    }
}

