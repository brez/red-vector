# REDVECTOR

Basic idea is to put together VSM (vector space model) based toolset for a variety of things that could get some assistance from a variety of things VSMs provide. Vague enough for you? We're starting with search / tag but plan to think abt more. Also we're starting with a simple key / value store (e.g. pure ruby) but plan to build adapter support for Redis, etc. 

Also plan to get it back to it's origins as a Rails plugin eventually or perhaps create specific plugins that leverage it (e.g. RedVectorSearch / RedVectorTag / etc)

## What it's not

A replacement for something as powerful as ThinkingSphinx / Solr / etc - the basic thought here is a simplified toolset with access to the underlying stats (e.g. you need to match everything above some threshold that you define)

## License

Copyright (C)2011 John Bresnik

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
