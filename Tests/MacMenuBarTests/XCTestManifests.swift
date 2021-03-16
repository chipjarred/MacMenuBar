import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(KeyEquivalent_Tests.allTests),
    ]
}
#endif
