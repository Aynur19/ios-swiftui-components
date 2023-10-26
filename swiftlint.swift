#!/usr/bin/swift

import Foundation

// Путь к вашему проекту
let absolutePath = FileManager.default.currentDirectoryPath + "/"
let projectPath = URL(fileURLWithPath: absolutePath)

// Команда для запуска SwiftLint
let command = "/usr/local/bin/swiftlint"

// Запуск SwiftLint
let process = Process()
process.executableURL = URL(fileURLWithPath: command)
process.currentDirectoryURL = projectPath

// Установка переменной окружения
process.environment = ["DYLD_FRAMEWORK_PATH": "/Applications/Xcode.app/Contents/Frameworks"]

do {
    try process.run()
    process.waitUntilExit()
} catch {
    print("Ошибка при запуске SwiftLint: \(error)")
}
