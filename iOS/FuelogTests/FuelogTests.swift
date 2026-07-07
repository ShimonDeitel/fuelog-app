import XCTest
@testable import Fuelog

@MainActor
final class FuelogTests: XCTestCase {

    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(FuelogEntry(vehicleName: "Test", amount: 10, note: "n", date: Date()))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenBelowLimit() {
        let store = Store()
        store.entries = []
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtFreeLimit() {
        let store = Store()
        store.entries = (0..<Store.freeLimit).map { i in
            FuelogEntry(vehicleName: "E\(i)", amount: 1, note: "", date: Date())
        }
        store.isPro = false
        XCTAssertFalse(store.canAddMore)
        let result = store.add(FuelogEntry(vehicleName: "Over", amount: 1, note: "", date: Date()))
        XCTAssertFalse(result)
    }

    func testProUserCanAlwaysAdd() {
        let store = Store()
        store.entries = (0..<Store.freeLimit).map { i in
            FuelogEntry(vehicleName: "E\(i)", amount: 1, note: "", date: Date())
        }
        store.isPro = true
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteEntry() {
        let store = Store()
        let entry = FuelogEntry(vehicleName: "ToDelete", amount: 5, note: "", date: Date())
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntry() {
        let store = Store()
        var entry = FuelogEntry(vehicleName: "Original", amount: 5, note: "", date: Date())
        store.add(entry)
        entry.vehicleName = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.vehicleName, "Updated")
    }

    func testDeleteAtOffsets() {
        let store = Store()
        store.entries = []
        store.add(FuelogEntry(vehicleName: "A", amount: 1, note: "", date: Date()))
        store.add(FuelogEntry(vehicleName: "B", amount: 1, note: "", date: Date()))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, 1)
    }
}
