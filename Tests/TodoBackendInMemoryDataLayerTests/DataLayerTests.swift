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

import TodoBackendDataLayer
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

    private func checkSingleTodoResult(_ result: Result<Todo>, expectedTitle: String, expectedCompleted: Bool, expectedOrder: Int? = nil, expectedID: String? = nil) {
        switch result {
        case .success(let todo):
            XCTAssertEqual(todo.title, expectedTitle, "wrong title")
            XCTAssertEqual(todo.completed, expectedCompleted, "wrong completed")
            XCTAssertEqual(todo.order, expectedOrder, "wrong order")
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAddItem() {
        let dataLayer = DataLayer()
        let testExpectation = expectation(description: #function)

        let title = "Reticulate splines"
        let order = 0
        let completed = false

        dataLayer.add(title: title, order: order, completed: completed) { result in
            checkSingleTodoResult(result, expectedTitle: title, expectedCompleted: completed,
                                  expectedOrder: order)
            testExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }

    func testGetItem() {
        let dataLayer = DataLayer()
        let testExpectation = expectation(description: #function)

        let title = "Reticulate splines"
        let order = 0
        let completed = false

        dataLayer.add(title: title, order: order, completed: completed) { resultOfAdd in
            switch resultOfAdd {
            case .success(let addedTodo):
                dataLayer.get(id: addedTodo.id) { resultOfGet in
                    checkSingleTodoResult(resultOfGet, expectedTitle: title, expectedCompleted: completed, expectedOrder: order, expectedID: addedTodo.id)
                    testExpectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
                 testExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }
}
