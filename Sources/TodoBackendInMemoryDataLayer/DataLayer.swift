/**
 * Copyright IBM Corporation 2017
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

import TodoBackendDataLayer

public class DataLayer: TodoBackendDataLayer.DataLayer {
    public init() {}

    private var idGenerator = IDGenerator()
    private var todos: [String: TodoImplementation] = [String: TodoImplementation]()

    public func get(completion: (Result<[Todo]>) -> Void) {
        completion(Result.success(Array(todos.values)))
    }

    public func get(id: String, completion: (Result<Todo>) -> Void) {
        guard let todo = todos[id] else {
            return completion(Result.failure(.todoNotFound))
        }
        completion(Result.success(todo))
    }

    public func add(title: String, order: Int?, completed: Bool,
                             completion: (Result<Todo>) -> Void) {
        let id = idGenerator.generate()
        let todo = TodoImplementation(id: id, title: title, order: order, completed: completed)
        todos[id] = todo
        completion(Result.success(todo))
    }

    public func delete(id: String, completion: (Result<Void>) -> Void) {
        todos[id] = nil
        completion(Result.success(()))
    }

    public func delete(completion: (Result<Void>) -> Void) {
        todos.removeAll()
        completion(Result.success(()))
    }

    public func update(id: String, title: String?, order: Int?, completed: Bool?,
                       completion: (Result<Todo>) -> Void) {
        guard var todo = todos[id] else {
            return completion(Result.failure(.todoNotFound))
        }

        todo.title = title ?? todo.title
        todo.order = order ?? todo.order
        todo.completed = completed ?? todo.completed

        todos[id] = todo
        completion(Result.success(todo))
    }
}
