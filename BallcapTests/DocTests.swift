//
//  DocTests.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage

class DocTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testDoc() {

        class Obj: Document {
            struct Model: Modelable & Codable {
                var name: String?
            }

            func data() -> ()? {
                <#code#>
            }
        }

        let obj: Obj = Obj(id: "aa")

        XCTAssertEqual(obj.documentReference.path, "version/1/model/a")
    }

    // TODO: Query tests
}
