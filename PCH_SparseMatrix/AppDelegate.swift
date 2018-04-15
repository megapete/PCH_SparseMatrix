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
        
        let A = PCH_SparseMatrix(type: .complex, rows: 4, cols: 4)
        
        A[0,0] = Complex(real: 5.0, imag: 2.0)
        A[1,0] = Complex(real: 0.0, imag: 0.0)
        A[2,0] = Complex(real: 4.0, imag: 9.0)
        A[3,0] = Complex(real: 3.2, imag: 1.0)
        
        A[0,1] = Complex(real: 3.0, imag: 1.0)
        A[1,1] = Complex(real: -2.0, imag: -2.0)
        A[2,1] = Complex(real: 9.0, imag: -4.5)
        A[3,1] = Complex(real: 0.0)
        
        A[0,2] = Complex(real: 2.0, imag: -3.0)
        A[1,2] = Complex(real: 1.0, imag: 1.5)
        A[2,2] = Complex(real: 0.0)
        A[3,2] = Complex(real: 2.3)
        
        A[0,3] = Complex(real: 0.0)
        A[1,3] = Complex(real: 0.0)
        A[2,3] = Complex(real: 6.0, imag: 2.3)
        A[3,3] = Complex(real: 0.0)
        
        let Asp = A.CreateSparseMatrix()
        let numRowIndices = Asp.structure.columnStarts[8]
        
        let test1 = Asp.structure.columnStarts[0]
        
        var rowIndString = "["
        for i in 0..<Int(numRowIndices)
        {
            rowIndString += "\(Asp.structure.rowIndices[i]), "
        }
        rowIndString += "]"
        DLog("rowIndices: \(rowIndString)")
        
        var colStartString = "["
        for i:Int in 0..<9
        {
            let test = Asp.structure.columnStarts[i]
            colStartString += "\(Asp.structure.columnStarts[i]), "
        }
        colStartString += "]"
        DLog("colStarts: \(colStartString)")
        
        for i in 0..<16
        {
            DLog("Array[\(i)] = \(Asp.data[i])")
        }
        
        let Xsp = PCH_SparseMatrix.CreateDenseMatrixForComplexVector(values: [Complex(real: 2.5, imag: 3.5), Complex(real: 1.6, imag: -2.0), Complex(real: 1.0, imag: 4.2), Complex(real: 0.0, imag: -6.3)])
        
        for i in 0..<8
        {
            DLog("X[\(i)] = \(Xsp.data[i])")
        }
        
        let Ysp = PCH_SparseMatrix.CreateEmptyMatrixForComplexVector(count: 4)
        
        SparseMultiply(Asp, Xsp, Ysp)
        
        var Y:[Complex] = []
        
        for i in 0..<4
        {
            let real = Ysp.data[2 * i]
            let imag = Ysp.data[2 * i + 1]
            
            Y.append(Complex(real: real, imag: imag))
        }
        
        DLog("A:\(A)")
        DLog("Y:\(Y)")
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

