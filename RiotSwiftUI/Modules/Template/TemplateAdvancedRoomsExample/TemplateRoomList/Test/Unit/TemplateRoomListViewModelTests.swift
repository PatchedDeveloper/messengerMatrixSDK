// 
// Copyright 2021 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import Combine

@testable import RiotSwiftUI

@available(iOS 14.0, *)
class TemplateRoomListViewModelTests: XCTestCase {
    private enum Constants {
        static let presenceInitialValue: TemplateRoomListPresence = .offline
        static let displayName = "Alice"
    }
    var service: MockTemplateRoomListService!
    var viewModel: TemplateRoomListViewModel!
    var cancellables = Set<AnyCancellable>()
    override func setUpWithError() throws {
        service = MockTemplateRoomListService(displayName: Constants.displayName, presence: Constants.presenceInitialValue)
        viewModel = TemplateRoomListViewModel(templateRoomListService: service)
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.viewState.displayName, Constants.displayName)
        XCTAssertEqual(viewModel.viewState.presence, Constants.presenceInitialValue)
    }

    func testFirstPresenceReceived() throws {
        let presencePublisher = viewModel.$viewState.map(\.presence).removeDuplicates().collect(1).first()
        XCTAssertEqual(try xcAwait(presencePublisher), [Constants.presenceInitialValue])
    }
    
    func testPresenceUpdatesReceived() throws {
        let presencePublisher = viewModel.$viewState.map(\.presence).removeDuplicates().collect(3).first()
        let newPresenceValue1: TemplateRoomListPresence = .online
        let newPresenceValue2: TemplateRoomListPresence = .idle
        service.simulateUpdate(presence: newPresenceValue1)
        service.simulateUpdate(presence: newPresenceValue2)
        XCTAssertEqual(try xcAwait(presencePublisher), [Constants.presenceInitialValue, newPresenceValue1, newPresenceValue2])
    }
}
