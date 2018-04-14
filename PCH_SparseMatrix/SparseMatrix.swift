//
//  SparseMatrix.swift
//  PCH_SparseMatrix
//
//  Created by PeterCoolAssHuber on 2018-04-14.
//  Copyright © 2018 Peter Huber. All rights reserved.
//

// This is a wrapper around Apple's sparse matrix routines. The reason for taking this on is that Apple does not offer Complex precision, which we need for a number of programs. Also, the Apple routines for creating a memory structure for Sparse matrices assumes that the entries in the matrix are already known (which makes it kinda useless if you ask me). Our strategy here is one we've used before where we store the numbers in a dictionary where the keys are instances of a special index class and the values are the Complex values (duh). We will use the Complex Matrix Theory that we developed some time ago where any complex number is converted into a 2x2 matrix with the real number repeated on the diagonal, the negative of the imaginary part on the first row and the unmodified impaginary part on the second row.

import Foundation
import Accelerate

class PCH_SparseMatrix
{
    // This is the number of rows and cols in the "virtual" Complex matrix (which does not really exist, since we actually store each complex as a 2x2 matrix)
    let rows:Int
    let cols:Int
    
    struct SparseKey:Hashable
    {
        let row:Int
        let col:Int
        
        // Standard hash function
        var hashValue: Int
        {
            return self.row.hashValue ^ self.col.hashValue &* 16777619
        }
        
        static func == (lhs:SparseKey, rhs:SparseKey) -> Bool
        {
            if lhs.row == rhs.row && lhs.col == rhs.col
            {
                return true
            }
            
            return false
        }
    }
    
    var matrix:[SparseKey:Double] = [:]
    
    subscript(row: Int, column: Int) -> Complex {
        get
        {
            if row >= self.rows || column >= self.cols
            {
                ALog("Illegal index")
                return Complex.ComplexNan
            }
            
            let realKey = SparseKey(row: row * 2, col: column * 2)
            let imagKey = SparseKey(row: row * 2, col: column * 2 + 1)
            
            if let realResult = self.matrix[realKey]
            {
                let imagResult = -self.matrix[imagKey]!
                
                return Complex(real: realResult, imag: imagResult)
            }
            else
            {
                return Complex(real:0.0)
            }
        }
        set
        {
            if row * 2 >= self.rows || column * 2 >= self.cols
            {
                ALog("Illegal index")
            }
            
            let key = SparseKey(row: row, col: column)
            
            if newValue == Complex(real: 0.0)
            {
                self.matrix.removeValue(forKey: key)
            }
            else
            {
                self.matrix[key] = newValue
            }
        }
    }
    
    init(rows:Int, cols:Int)
    {
        self.rows = rows
        self.cols = cols
    }
    
    func CreateSparseMatrix() -> SparseMatrix_Double
    {
        var rowIndices:[Int32] = Array(repeating: -1, count: self.matrix.count * 2)
        var values:[Double] = Array(repeating: Double.greatestFiniteMagnitude, count: self.matrix.count * 2)
        var columnStarts:[Int32] = Array(repeating: -1, count: self.cols * 2 + 1)
        
        // We assume that the user has done SOME work and that every column has at least one entry in it...
        var lastColumnStart = 0
        columnStarts[0] = 0
        
        
        for (key, value) in self.matrix
        {
            
        }
    }
    
    func NumberOfEntriesInColumn(_ col:Int) -> Int
    {
        var result = 0
        for (key, value) in self.matrix
        {
            if key.col == col
            {
                result += 1
            }
        }
        
        return result
    }
    
}


