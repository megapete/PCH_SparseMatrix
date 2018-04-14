//
//  SparseMatrix.swift
//  PCH_SparseMatrix
//
//  Created by PeterCoolAssHuber on 2018-04-14.
//  Copyright © 2018 Peter Huber. All rights reserved.
//

// This is a wrapper around Apple's sparse matrix routines. The reason for taking this on is that Apple does not offer Complex precision, which we need for a number of programs. Also, the Apple routines for creating a memory structure for Sparse matrices assumes that the entries in the matrix are already known (which makes it kinda useless if you ask me).

import Foundation
import Accelerate



