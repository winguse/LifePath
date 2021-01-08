//
//  Logger.swift
//  LifePath
//
//  Created by Yingyu Cheng on 1/8/21.
//

import SwiftUI
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let background = Logger(subsystem: subsystem, category: "background")
    static let ui = Logger(subsystem: subsystem, category: "ui")
}
