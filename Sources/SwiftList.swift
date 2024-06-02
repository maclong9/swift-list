import ArgumentParser
import Foundation

let files = FileManager.default

enum ConsoleColor: String {
  case red = "\u{001B}[0;31m"
  case blue = "\u{001B}[0;34m"
  case reset = "\u{001B}[0;0m"
}

func determineColor(path: URL) -> String {
  // TODO: Determine white, red and blue for file, executable and directory
  return ""
}

func findContents(path: URL, _ all: Bool, _ recurse: Bool) throws -> String {
  var result = ""
  let contents = try files.contentsOfDirectory(
    at: path,
    includingPropertiesForKeys: nil,
    options: all ? [] : [.skipsHiddenFiles]
  )

  for url in contents {
    var color = determineColor(path: url)
    result += "\(color)\(url.lastPathComponent)\(ConsoleColor.reset.rawValue)\t"
  }

  if recurse {
    result += "\n"

    for url in contents {
      if url.hasDirectoryPath {
        result += "\n./\(url.lastPathComponent):\n"
        result += try findContents(path: url, all, recurse)
      }
    }
  }

  return result
}

@main
struct SwiftList: ParsableCommand {
  @Flag(name: .shortAndLong, help: "Display all files, including hidden.")
  var all = false
  @Flag(name: .shortAndLong, help: "Display extended details and attributes.")
  var long = false
  @Flag(name: .shortAndLong, help: "Recurse into directories.")
  var recurse = false
  @Flag(name: .shortAndLong, help: "Colorize the output.")
  var color = false
  @Argument(help: "List files at path, omit for current directory.")
  var path: String?

  func run() throws {
    let files = FileManager.default
    let location = URL(fileURLWithPath: path ?? files.currentDirectoryPath)
    let result = try findContents(path: location, all, recurse)

    print(result)
  }
}
