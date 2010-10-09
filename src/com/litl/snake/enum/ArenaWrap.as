/* Copyright (c) 2010 litl, LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to
* deal in the Software without restriction, including without limitation the
* rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
* sell copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
* IN THE SOFTWARE.
*/
package com.litl.snake.enum {
    public class ArenaWrap {
        public static const WRAP_YES:ArenaWrap = new ArenaWrap("wrap across walls", true);
        public static const WRAP_NO:ArenaWrap = new ArenaWrap("crash at walls", false);

        public static const ALL_WRAPS:Array = [ WRAP_YES, WRAP_NO ];

        public var name:String;
        public var shouldWrap:Boolean;

        public function ArenaWrap(name:String, shouldWrap:Boolean = false) {
            this.name = name;
            this.shouldWrap = shouldWrap;
        }

        public function toString():String {
            return name;
        }
    }
}