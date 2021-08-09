import Foundation

struct MyScript {
    static func main() {
        print("Hello, World!")
//        struct Ack: Codable {
//            let title: String
//            let license: String
//        }
//
//        guard let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"] else {
//            print("could not detect the built products directory.")
//            return
//        }
//        guard let tempDir = ProcessInfo.processInfo.environment["PROJECT_TEMP_DIR"] else {
//            print("could not detect the built products directory.")
//            return
//        }
//
//        let path = tempDir.components(separatedBy: "/Build/")[0] + "/SourcePackages/checkouts"
//        let fman = FileManager.default
//
//        do {
//            try "Test"
//                .data(using: .utf8)!
//                .write(to: URL(fileURLWithPath: "\(srcRoot)/Test.md"))
//
//            let items = try fman.contentsOfDirectory(atPath: path)
//            var array = [Ack]()
//            for item in items where item.prefix(1) != "." {
//                guard let data = fman.contents(atPath: "\(path)/\(item)/LICENSE") else { continue }
//                let new = Ack(title: item, license: String(data: data, encoding: .utf8)!)
//                array.append(new)
//            }
//
//            let encoder = PropertyListEncoder()
//            encoder.outputFormat = .xml
//
//            let plistPath = "\(srcRoot)/Acknowledgements.plist"
//            do {
//                let data = try encoder.encode(array)
//                try data.write(to: URL(fileURLWithPath: plistPath))
//            } catch {
//                print(error)
//            }
//        } catch {
//            print(error)
//        }

    }
}

MyScript.main()
