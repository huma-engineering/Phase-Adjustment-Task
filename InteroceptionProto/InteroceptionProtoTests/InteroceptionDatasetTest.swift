//
//  InteroceptionDatasetTest.swift
//  InteroceptionProtoTests
//
//  Created by Joel Barker on 11/02/2020.
//  Copyright © 2020 BioBeats. All rights reserved.
//

import XCTest

class InteroceptionDatasetTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func createDataset(numValues: Int, numItems: Int) -> InteroceptionDataset {

        let dataSet = InteroceptionDataset()
        let runNum = Int.random(in: 0 ..< 100)

        dataSet.participantID = "joel" + runNum.description

        // Syncro
        for _ in 0...numValues {
            let recordedHR = self.makeRandomFloatArray(numValues: numItems)
            let instantBpms = self.makeRandomFloatArray(numValues: numItems)
            let instantPeriods = self.makeRandomDoubleArray(numValues: numItems)
            let averagePeriods = self.makeRandomDoubleArray(numValues: numItems)
            let instantErrs = self.makeRandomDoubleArray(numValues: numItems)
            let knobScales = self.makeRandomDoubleArray(numValues: numItems)
            let currentDelays = self.makeRandomDoubleArray(numValues: numItems)

            let syncroSet = SyncroTrialDataset()
            syncroSet.date = Date()

            syncroSet.confidence = Int.random(in: 0 ..< 100)
            syncroSet.bodyPos = Int.random(in: 0 ..< 100)

            syncroSet.recordedHR = recordedHR
            syncroSet.instantBpms = instantBpms
            syncroSet.instantPeriods = instantPeriods
            syncroSet.averagePeriods = averagePeriods
            syncroSet.instantErrs = instantErrs
            syncroSet.knobScales = knobScales
            syncroSet.currentDelays = currentDelays
            dataSet.syncroTraining.append(syncroSet)
        }

        // Baseline
        for _ in 0...numValues {

            let baselineSet = BaseLineDataset()

            baselineSet.date = Date()

            let instantBpms = self.makeRandomFloatArray(numValues: numItems)
            let recordedHR = self.makeRandomFloatArray(numValues: numItems)

            baselineSet.recordedHR = recordedHR
            baselineSet.instantBpms = instantBpms

            dataSet.baselines.append(baselineSet)
        }

        dataSet.endDate = Date()
        return dataSet
    }

    func testEqaulity(one: InteroceptionDataset, two: InteroceptionDataset) {
        XCTAssert(one.participantID == two.participantID)
        XCTAssert(one.startDate == two.startDate)

        XCTAssert(one.endDate == two.endDate)

        XCTAssert(one.syncroTraining.count == two.syncroTraining.count)

        for (trialOne, trialTwo) in zip(one.syncroTraining, two.syncroTraining) {
            let isEqual = trialOne.equals(other: trialTwo)
            XCTAssert(isEqual)
        }

        XCTAssert(one.baselines.count == two.baselines.count)

        for (trialOne, trialTwo) in zip(one.baselines, two.baselines) {
            let isEqual = trialOne.equals(other: trialTwo)
            XCTAssert(isEqual)
        }
    }

    func testExample() {
        InteroceptionDataset.wipePreviousData()
        XCTAssert(!InteroceptionDataset.hasPreviousData())

        let numValues = 1
        let numItems = 5

        let dataset = createDataset(numValues: numValues, numItems: numItems)
        dataset.store()

        XCTAssert(InteroceptionDataset.hasPreviousData())

        let newSet = InteroceptionDataset.load()
        XCTAssert(newSet!.syncroTraining.count == (numValues + 1))
        XCTAssert(newSet!.baselines.count == (numValues + 1))

        testEqaulity(one: newSet!, two: dataset)

        let newSyncro = newSet!.syncroTraining.first
        let oldSyncro = dataset.syncroTraining.first

        newSyncro?.averagePeriods.removeAll()

        XCTAssert(!(newSyncro?.equals(other: oldSyncro!))!)

        let newBase = newSet?.baselines.first
        let oldBase = dataset.baselines.first

        newBase?.recordedHR.removeAll()

        XCTAssert(!(newBase?.equals(other: oldBase!))!)
    }

    func makeRandomDoubleArray (numValues: Int) -> [Double] {
        var rnds: [Double] = []
        for _ in 0...numValues {
            let flt = Double.random(in: 0 ..< 100)
            rnds.append(flt)
        }

        return rnds
    }

    func makeRandomFloatArray (numValues: Int) -> [Float] {
        var rnds: [Float] = []
        for _ in 1...numValues {

            let flt = Float.random(in: 0 ..< 100)
            rnds.append(flt)
        }

        return rnds
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
