rule.js
=======

`rule = new Rule
  '.title': ->@title ? 'no title'
  '.description': ['rule.js ', 'is ', 'a ', 'templating ', 'library.']`

rule.js is a templating library that uses an object definition to map values to selectors. The object keys are special selector definitions that also allow for selecting attributes, and specifying where new data should be placed. The values can be a function that return a value, an array that is iterated and appended, another Rule, or a string or DOMElement that is used as is.

This syntax was inspired by Pure, a templating library that also uses object keys as selectors. The key difference is that rule.js does not attempt to parse value strings, and instead uses javascript functions to establish mapping values. With coffeescript syntax the functions become very concise and easy to read, while retaining all the power and flexibility that they bring, and at the same time limits their scope.

Using the syntax of coffeescript rule.js can do conditionals, iteration, recursion, and variable checking in a simple and concise way.

Rule Object methods
-------------------
new Rule(rule): create a new Rule based on the rule object given in.
Rule.build(data): build an html element with the given data.
Rule.bind(template): bind the rule to a jquery dom element to use as the template.

Right Hand Value Types
----------------
Function: execute function bound with the data as the context and parse result.
Array: iterate through array and join parsed contents.
Object: compile into rule object and execute with same data context.
String: Used as is.
DOMElement: Used as is.

Examples
--------

### Simple Example
#### DOM Template
`<div class="simple">
  <span class="content">content</span>
</div>`
#### Rule Object
`simple = new Rule
  '.content': ->@content`
#### Execution
`simple.bind $ '#template > .simple'
  ($ 'body').append simple.build
    content: 'test'`

### Embedded Object Example
#### DOM Template
`<div class="book">
  <h1 class="title"></h1>
  <div class="author">
    <div class="name">
      <span class="first"></span>
      <span class="last"></span>
    </div>
  </div>
</div>`
#### Rule Object
`book = new Rule
  '.title': ->@title
  '.author':
    '.name':
      '.first': ->@author.first
      '.last': ->@author.last`
#### Execution
`book.bind $ '#template > .book'

($ 'body').append book.build
  title: 'The Hobbit'
  author:
    first: 'J. R. R.'
    last: 'Tolkien'`

### Iteration Example
#### DOM Template
`<ul class="list">
  <li class="item"><span class="content"></span></li>
</ul>`
#### Rule Object
`itemRule = new Rule
  '.content': ->@a ? @b ? @c ? 'default'`
`listRule = new Rule
  '.': ->itemRule.build item for item in @list`
#### Execution
`listRule.bind $ '#template > .list'
itemRule.bind $ '#template > .list > .item'

($ 'body').append listRule.build
  list: [{c: 'hello'}, {b: 'world'}, {}]`


### Recursion Example
#### DOM Template
`<ul class="recursive">
  <li class="location"></li>
  <div class="list"></div>
</ul>`
#### Rule Object
`recursive = new Rule
  '.location': ->@location
  '.list=': ->if @list then recursive.build item for item in @list`
#### Execution
`recursive.bind $ '#template > .recursive'

($ 'body').append recursive.build
  location: 'USA'
  list:
    [
      {
        location: 'California'
        list:
          [
            { location: 'San Diego' }
            { location: 'San Francisco' }
            { location: 'San Jose' }
          ]
      }
      {
        location: 'Nevada'
        list:
          [
            { location: 'Reno' }
            { location: 'Las Vegas' }
          ]
      }
    ]`