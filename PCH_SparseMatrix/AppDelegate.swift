//
//  AppDelegate.swift
//  PCH_SparseMatrix
//
//  Created by PeterCoolAssHuber on 2018-04-14.
//  Copyright © 2018 Peter Huber. All rights reserved.
//

import Cocoa
import Accelerate

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Insert code here to initialize your application
        
        let values = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
        
        let matrix = PCH_SparseMatrix.CreateDenseVectorForDoubleVector(values: values)
        let testStruct = matrix.attributes
        
        
        DLog("Matrix type: \(testStruct.kind); Allocated by sparse:\(testStruct._allocatedBySparse)")
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

