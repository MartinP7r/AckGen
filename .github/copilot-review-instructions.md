This is a Swift Package Manager project that generates acknowledgements/licenses for SPM dependencies.

When reviewing pull requests, pay attention to:

- Swift API design conventions and naming
- Correct use of Codable and property list serialization
- Platform availability guards (macOS 10.15+, iOS 13+, watchOS 6+, tvOS 14+)
- Thread safety around FileManager operations
- Proper error handling (avoid force unwraps where possible)
- Ensure new public API has documentation comments
