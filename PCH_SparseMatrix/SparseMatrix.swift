//
//  SparseMatrix.swift
//  PCH_SparseMatrix
//
//  Created by PeterCoolAssHuber on 2018-04-14.
//  Copyright © 2018 Peter Huber. All rights reserved.
//

// This is a wrapper around Apple's sparse matrix routines. The reason for taking this on is that Apple does not offer Complex precision, which we need for a number of programs. Also, the Apple routines for creating a memory structure for Sparse matrices assumes that the entries in the matrix are already known (which makes it kinda useless if you ask me). Our strategy here is one we've used before where we store the numbers in a dictionary where the keys are instances of a special index class and the values are the Complex values (duh). We will use the Complex Matrix Theory that we developed some time ago where any complex number is converted into a 2x2 matrix with the real number repeated on the diagonal, the negative of the imaginary part on the first row and the unmodified impaginary part on the second row.

// Note: All row and column indices are 0-based

import Foundation
import Accelerate

class PCH_SparseMatrix:CustomStringConvertible
{
    // This is the number of rows and cols in the "virtual" Complex matrix (which does not really exist, since we actually store each complex as a 2x2 matrix)
    let rows:Int
    let cols:Int
    
    /// As simple description function to display matrices with 'print' (the output is quite ugly and not nicely formatted)
    var description:String
    {
        var result = ""
        
        for i in 0..<self.rows
        {
            result += "\n| "
            
            for j in 0..<self.cols
            {
                if (j == self.cols - 1)
                {
                    let value:Complex = self[i,j]
                    result += "\(value) |"
                }
                else
                {
                    let value:Complex = self[i,j]
                    result += "\(value)   "
                }
            }
        }
        
        return result
    }
    
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
            
            let realKey1 = SparseKey(row: row * 2, col: column * 2)
            let realKey2 = SparseKey(row: row * 2 + 1, col: column * 2 + 1)
            let imagKey1 = SparseKey(row: row * 2, col: column * 2 + 1) // negative imaginary term
            let imagKey2 = SparseKey(row: row * 2 + 1, col: column * 2)
            
            if newValue.real == 0.0
            {
                self.matrix.removeValue(forKey: realKey1)
                self.matrix.removeValue(forKey: realKey2)
            }
            else
            {
                self.matrix[realKey1] = newValue.real
                self.matrix[realKey2] = newValue.real
            }
            
            if newValue.imag == 0.0
            {
                
                self.matrix.removeValue(forKey: imagKey1)
                self.matrix.removeValue(forKey: imagKey2)
            }
            else
            {
                self.matrix[imagKey1] = -newValue.imag
                self.matrix[imagKey2] = newValue.imag
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
        var columnStarts:[Int] = Array(repeating: -1, count: self.cols * 2 + 1)
        
        // We assume that the user has done SOME work and that every column has at least one entry in it...
        var lastColumnStart = 0
        columnStarts[0] = lastColumnStart
        
        for column in 0..<self.cols
        {
            var numRowValues:Int32 = 0
            for row in 0..<self.rows
            {
                if let value = self.matrix[SparseKey(row: row, col: column)]
                {
                    if value != 0.0
                    {
                        rowIndices.append(Int32(row))
                        values.append(value)
                        numRowValues += 1
                    }
                }
            }
            
            lastColumnStart += Int(numRowValues)
            columnStarts[column + 1] = lastColumnStart
        }
        
        let sparseStruct = SparseMatrixStructure(rowCount: Int32(self.rows * 2), columnCount: Int32(self.cols * 2), columnStarts: &columnStarts, rowIndices: &rowIndices, attributes: SparseAttributes_t(), blockSize: 1)
        
        return SparseMatrix_Double(structure: sparseStruct, data: &values)
    }
    
    static func CreateDenseMatrixForComplexVector(values:[Complex]) -> DenseMatrix_Double
    {
        let rowCount = values.count
        let data = UnsafeMutablePointer<Double>.allocate(capacity: rowCount * 4)
        
        var i = 0
        for nextValue in values
        {
            data[i] = nextValue.real
            data[i + 1] = nextValue.imag
            data[i + rowCount] = -nextValue.imag
            data[i + 1 + rowCount] = nextValue.real
            
            i += 1
        }
        
        let result = DenseMatrix_Double(rowCount: Int32(rowCount * 2), columnCount: 2, columnStride: 1, attributes: SparseAttributes_t(), data: data)
        
        return result
    }
    
    // See the Apple documentation under Sparse to see how to create a DenseMatrix
    func SolveWithB(_ B:DenseMatrix_Double) -> DenseMatrix_Double
    {
        
    }
    
}


