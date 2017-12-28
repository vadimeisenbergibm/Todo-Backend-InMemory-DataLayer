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
            ("testGetItem", testGetItem),
            ("testGetItems", testGetItems),
            ("testNotFoundItemInEmptyTodos", testNotFoundItemInEmptyTodos),
        ]
    }

    func testInitializer() {
        let _ = DataLayer()
    }

    private func check(todo: Todo, expectedTitle: String, expectedCompleted: Bool,
                       expectedOrder: Int? = nil, expectedID: String? = nil) {
        XCTAssertEqual(todo.title, expectedTitle, "wrong title")
        XCTAssertEqual(todo.completed, expectedCompleted, "wrong completed")
        if let expectedOrder = expectedOrder {
            XCTAssertEqual(todo.order, expectedOrder, "wrong order")
        }
        if let expectedID = expectedID {
            XCTAssertEqual(todo.id, expectedID, "wrong ID")
        }
    }

    private func checkSingleTodoResult(_ result: Result<Todo>, expectedTitle: String,
                                       expectedCompleted: Bool, expectedOrder: Int? = nil,
                                       expectedID: String? = nil) {
        switch result {
        case .success(let todo):
            check(todo: todo, expectedTitle: expectedTitle, expectedCompleted: expectedCompleted,
            expectedOrder: expectedOrder)
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func checkSingleTodoResult(_ result: Result<[Todo]>, expectedTitle: String,
                                       expectedCompleted: Bool, expectedOrder: Int? = nil,
                                       expectedID: String? = nil) {
        switch result {
        case .success(let todos):
            XCTAssertEqual(todos.count, 1)
            guard let todo = todos.first else {
                XCTFail("The returned todo items do not have the first member")
                return
            }
            check(todo: todo, expectedTitle: expectedTitle, expectedCompleted: expectedCompleted,
                  expectedOrder: expectedOrder)
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func checkError(_ result: Result<Todo>, expectedError: DataLayerError) {
        switch result {
        case .success(let todo):
            XCTFail("Received todo instead of failure, todo: \(todo)")
        case .failure(let error):
            switch(error, expectedError) {
            case (.internalError, .internalError), (.todoNotFound, .todoNotFound):
                break
            default:
                XCTFail("Wrong error:  expected \(expectedError), received \(error)")
            }
        }
    }

    typealias DataLayerTest = (TodoBackendInMemoryDataLayer.DataLayer, XCTestExpectation) -> Void
    private func runDataLayerTest(dataLayerTest: DataLayerTest) {
        let dataLayer = DataLayer()
        let testExpectation = expectation(description: "run test")

        dataLayerTest(dataLayer, testExpectation)
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }

    func testAddItem() {
        runDataLayerTest() { dataLayer, testExpectation in
            let title = "Reticulate splines"
            let order = 0
            let completed = false

            dataLayer.add(title: title, order: order, completed: completed) { result in
                checkSingleTodoResult(result, expectedTitle: title, expectedCompleted: completed,
                                      expectedOrder: order)
                testExpectation.fulfill()
            }
        }
    }

    func testGetItem() {
        runDataLayerTest() { dataLayer, testExpectation in
            let title = "Reticulate splines"
            let order = 0
            let completed = false

            dataLayer.add(title: title, order: order, completed: completed) { resultOfAdd in
                switch resultOfAdd {
                case .success(let addedTodo):
                    dataLayer.get(id: addedTodo.id) { resultOfGet in
                        checkSingleTodoResult(resultOfGet, expectedTitle: title,
                                              expectedCompleted: completed, expectedOrder: order,
                                              expectedID: addedTodo.id)
                        testExpectation.fulfill()
                    }
                case .failure(let error):
                    XCTFail("Unexpected error: \(error)")
                    testExpectation.fulfill()
                }
            }
        }
    }

    func testGetItems() {
        runDataLayerTest() { dataLayer, testExpectation in
            let title = "Reticulate splines"
            let order = 0
            let completed = false

            dataLayer.add(title: title, order: order, completed: completed) { resultOfAdd in
                switch resultOfAdd {
                case .success(let addedTodo):
                    dataLayer.get() { resultOfGet in
                        checkSingleTodoResult(resultOfGet, expectedTitle: title, expectedCompleted: completed, expectedOrder: order, expectedID: addedTodo.id)
                        testExpectation.fulfill()
                    }
                case .failure(let error):
                    XCTFail("Unexpected error: \(error)")
                    testExpectation.fulfill()
                }
            }
        }
    }

    func testNotFoundItemInEmptyTodos() {
        runDataLayerTest() { dataLayer, testExpectation in
            dataLayer.get(id: "dummyID") { result in
                checkError(result, expectedError: .todoNotFound)
                testExpectation.fulfill()
            }
        }
    }
}
