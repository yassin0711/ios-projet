import XCTest
@testable import Matbakhi

final class ValidationTests: XCTestCase {
    func testEmail() {
        XCTAssertNil(Validation.email("ali@mail.com"))
        XCTAssertEqual(Validation.email("ali.mail.com"), "validation.email")
        XCTAssertEqual(Validation.email("ali@mail"), "validation.email")
    }

    func testPassword() {
        XCTAssertNil(Validation.password("123456"))
        XCTAssertEqual(Validation.password("123"), "validation.password")
    }

    func testName() {
        XCTAssertNil(Validation.name("Ali"))
        XCTAssertEqual(Validation.name(" A "), "validation.name")
    }

    func testConfirmation() {
        XCTAssertNil(Validation.confirmation("secret1", "secret1"))
        XCTAssertEqual(Validation.confirmation("secret1", "secret2"), "validation.confirm")
    }
}
