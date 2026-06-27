import XCTest
@testable import Daybreak

/// Verifies the progressive tax, Medicare levy and marginal-rate maths against
/// hand-computed values for the AU 2025-26 brackets.
final class TaxCalculatorTests: XCTestCase {
    let tax = TaxCalculator(config: .australia)

    func testTaxFreeThreshold() {
        XCTAssertEqual(tax.incomeTax(taxable: 0), 0, accuracy: 0.001)
        XCTAssertEqual(tax.incomeTax(taxable: 18_200), 0, accuracy: 0.001)
    }

    func testBracketBoundaries() {
        // Up to $45,000: 16% of the slice above $18,200 = 26,800 * 0.16 = 4,288
        XCTAssertEqual(tax.incomeTax(taxable: 45_000), 4_288, accuracy: 0.001)
        // $95,000: 4,288 + 50,000 * 0.30 = 19,288
        XCTAssertEqual(tax.incomeTax(taxable: 95_000), 19_288, accuracy: 0.001)
        // $135,000: 4,288 + 90,000 * 0.30 = 31,288
        XCTAssertEqual(tax.incomeTax(taxable: 135_000), 31_288, accuracy: 0.001)
        // $190,000: 31,288 + 55,000 * 0.37 = 51,638
        XCTAssertEqual(tax.incomeTax(taxable: 190_000), 51_638, accuracy: 0.001)
        // $200,000: 51,638 + 10,000 * 0.45 = 56,138
        XCTAssertEqual(tax.incomeTax(taxable: 200_000), 56_138, accuracy: 0.001)
    }

    func testMedicareLevy() {
        XCTAssertEqual(tax.medicareLevy(taxable: 95_000, enabled: true), 1_900, accuracy: 0.001)
        XCTAssertEqual(tax.medicareLevy(taxable: 95_000, enabled: false), 0, accuracy: 0.001)
        XCTAssertEqual(tax.medicareLevy(taxable: 20_000, enabled: true), 0, accuracy: 0.001)
    }

    func testMarginalRate() {
        XCTAssertEqual(tax.marginalRatePercent(taxable: 95_000, medicare: true), 32)   // 30% + 2%
        XCTAssertEqual(tax.marginalRatePercent(taxable: 95_000, medicare: false), 30)
        XCTAssertEqual(tax.marginalRatePercent(taxable: 10_000, medicare: true), 0)
        XCTAssertEqual(tax.marginalRatePercent(taxable: 40_000, medicare: true), 18)   // 16% + 2%
        XCTAssertEqual(tax.marginalRatePercent(taxable: 250_000, medicare: true), 47)  // 45% + 2%
    }
}
