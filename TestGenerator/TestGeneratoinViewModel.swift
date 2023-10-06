//
//  TestGeneratoinViewModel.swift
//  TestGenerator
//
//  Created by Серегин Михаил Андреевич on 06.10.2023.
//

import Foundation
import Combine

final class TestGenerationViewModel: ObservableObject {
    @Published var text = ""
    @Published var successTests: [TestCase] = []
    @Published var failureTests: [TestCase] = []
    private var disposables = Set<AnyCancellable>()
    
    init() {
        bind()
    }
    
    @discardableResult
    func generate() -> [String] {
        let funcs = getFuncToTest()
        let success = funcs.map { generateTest(for: $0, type: .success) }
        let successTestCase = TestCaseTemplate(id: .init(), type: .success).generate(for: success, className: getClassname())
        let failure = funcs.map { generateTest(for: $0, type: .failure) }
        let failureTestCase = TestCaseTemplate(id: .init(), type: .failure).generate(for: failure, className: getClassname())
        self.successTests = success
        self.failureTests = failure
        
        return [successTestCase, failureTestCase]
    }
    
    func getSuccessTestTemplate() -> String {
        TestCaseTemplate(id: .init(), type: .success).generate(for: successTests, className: getClassname())
    }
    
    func getFailureTestTemplate() -> String {
        TestCaseTemplate(id: .init(), type: .failure).generate(for: failureTests, className: getClassname())
    }
    
    private func bind() {
        $text.sink { textData in
            self.generate()
        }
        .store(in: &disposables)
    }
    
    private func getFuncToTest() -> [String] {
        let data = text
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces)}
            .filter { $0.hasPrefix("public func") || $0.hasPrefix("func") }
            .map { String($0.dropLast()).trimmingCharacters(in: .whitespaces) }
            .map(normalize)
        return data
    }
    
    private func normalize(_ funcName: String) -> String {
        var result = ""
        for char in funcName {
            if char == "(" {
                return result
            } else {
                result += String(char)
            }
        }
        return result
    }
    
    private func generateTest(for string: String, type: TestType) -> TestCase {
        let funcName = string.split(separator: " ")
            .map { str -> String in
                if str == "func" || str == "public" {
                    return String(str.replacingOccurrences(of: "public", with: ""))
                } else {
                    return "test\(str.capitalized)"
                }
            }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        print(funcName)
        return .init(id: .init(), type: type, text: funcName)
    }
    
    private func getClassname() -> String {
        let name = text.split(separator: "\n")
            .filter { $0.localizedCaseInsensitiveContains("class")}
            .map(String.init)
            .first ?? ""
        return normalizeClassName(classname: name)
    }
    
    func normalizeClassName(classname: String) -> String {
        var name = classname
        for word in keywords {
            if classname.localizedCaseInsensitiveContains(word) {
                name = String(name.dropFirst(word.count).trimmingCharacters(in: .whitespaces))
            }
        }
        var result = ""
        for char in name {
            if char == ":" {
                return result
            } else {
                result += String(char)
            }
        }
        return result
    }
}

struct TestCaseTemplate {
    let id: UUID
    
    let type: TestType
    
    private func generateCases(tests: [TestCase]) -> String {
        tests.map {
            "\t\($0.text)() throws { \n\n\n\t}"
        }
        .joined(separator: " \n\n")
    }
 
    func generate(for tests: [TestCase], className: String) -> String {
    """
    final class \(className)\(type.prefix)Tests: XCTestCase {

        var sut: \(className)!
    
        override func setUpWithError() throws {
            //sut = init me!
        }

        override func tearDownWithError() throws {
            sut = nil
        }
    
    \(generateCases(tests: tests))
    }
    """
    }
}

struct TestCase: Identifiable {
    let id: UUID
    let type: TestType
    let text: String
}

enum TestType {
    case success, failure
    
    var prefix: String {
        switch self {
        case .failure:
            return "Failure"
        case .success:
            return "Success"
        }
    }
}

let keywords: [String] = "public, private, open, internal, final, associatedtype, deinit, enum, extension, fileprivate, func, import, init, inout, let, operator, precedencegroup, protocol, rethrows, static, struct, subscript, typealias, var, class".split(separator: ", ").map(String.init)

let testViewModelDataMock: String = """
public final class RecommendationViewModel: ObservableObject, RecommendationViewModelDelegate {
    @Published private(set) var model: RecommendationModel?
    @Published private(set) var runActionDisabled = false
    @Dependency(recommendationService) var service
    
    private var disposables = Set<AnyCancellable>()
    private var logger = LoggerFactory.createLogger(type: RecommendationViewModel.self)
    public init() {
        bind()
    }

    public func update() {
        service.updateRecommendation()
    }
    
    private func bind() {
        service
            .actionPublisher
            .removeDuplicates(by: { $0?.title == $1?.title })
            .receive(on: DispatchQueue.main)
            .sink { model in
                self.model = model
                self.logger.info("Установлена рекомендация")
            }
            .store(in: &disposables)
    }
    
    func runAction() {
        runActionDisabled = true
        if let model {
            navigate(for: model.actionId)
        }
        self.service.updateRecommendation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.runActionDisabled = false
        }
    }
    
    public func calculate(x: Int, y: Int) -> Int {
        return x + y
    }
}
"""
