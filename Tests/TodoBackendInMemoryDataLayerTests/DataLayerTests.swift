/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
import Foundation
import TodoBackendInMemoryDataLayer

class DataLayerTests: XCTestCase {
    static var allTests: [(String, (DataLayerTests) -> () throws -> Void)] {
        return [
            ("testInitializer", testInitializer),
            ("testAddItem", testAddItem),
        ]
    }

    func testInitializer() {
        let _ = DataLayer()
    }

    func testAddItem() {
        let dataLayer = DataLayer()
        let testExpectation = expectation(description: "Add first item")

        let testTitle = "Reticulate splines"
        let testOrder = 0
        let testCompleted = false

        dataLayer.add(title: testTitle, order: testOrder, completed: testCompleted) { result in
            switch result {
            case .success(let todo):
                XCTAssertEqual(todo.title, testTitle, "wrong title")
                XCTAssertEqual(todo.order, testOrder, "wrong order")
                XCTAssertEqual(todo.completed, testCompleted, "wrong completed")
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            testExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }
}
