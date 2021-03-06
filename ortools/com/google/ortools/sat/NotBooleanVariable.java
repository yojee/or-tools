// Copyright 2010-2017 Google
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.google.ortools.sat;

/**
 * The negation of a boolean variable. This class should not be used directly, ILiteral must be used
 * instead.
 */
public class NotBooleanVariable implements ILiteral {
  public NotBooleanVariable(IntVar boolvar) {
    boolvar_ = boolvar;
  }

  /** Internal: return the index in the literal in the underlying CpModelProto. */
  @Override
  public int getIndex() {
    return -boolvar_.getIndex() - 1;
  }

  /** Returns the negation of this literal. */
  @Override
  public ILiteral not() {
    return boolvar_;
  }

  /** Returns a short string describing this literal. */
  @Override
  public String getShortString() {
    return "not(" + boolvar_.getShortString() + ")";
  }

  private IntVar boolvar_;
}
