rule.js
=======
*functional coffeescript templating*

    rule = new Rule
      '.title': ->@title ? 'rule.js'
      '.description': ['rule.js ', 'is ', 'a ', 'templating ', 'library.']


What
----

Rule is a templating library that uses css selectors to select elements, and then applies a value to that element. That value can be a string, DOM element, array, function, or even another rule. Strings are inserted as text nodes to protect against XSS. DOM elements can be created however you want. Iteration is done by returning an array. Functions are evaluated and can return any other type (even another function). A rule will be evaluated and return a DOM element. The power of the library comes from combining these fundamental types. For example, a function can return an array, of rules that evaluate to DOM elements. How you use these types is up to you and the possibilities are endless.

###Rule
Choose where your data goes and how...

    rule = new Rule
      '.data': ->@content

###Template
Use whatever DOM object you want, made however you want...

    <div class="template">
      <span class="data">
      </span>
    </div>

    dom = $('.template')


###Execution
Build the populated template with the data you pass it...

    rule.render
      content: 'a string'
      dom

Reap the rewards.

    <div class="template">
      <span class="data">
        'a string'
      </span>
    </div>

How
---
###Rules
The Rule constructor takes an object, and an optional template

    rule = new Rule
      '.data': ->@content
      document.querySelector 'div'

####Keys
The key is a selector for the element to populate.

    '.data'

You can add @[attribute] to select the attribute within the selector.

    '.data@type'

You can add a position to point where to add the data to.

    '.data@type+'

#####Positions
**-**: insert as previous sibling node or concatenate before with a space for attributes

**+**: insert as next sibling node or concatenate after with a space for attributes

**=**: replace the selected node with a new node

**<**: insert as first child node or concatenate immediately before for attributes

**>**: insert as last child node or concatenate immediately after for attributes

####Values
Rules can have a variety of values.
#####Functions
The value can be a function. The 'this' context is the data, and its return value gets parsed again.

    '.data': ->@content

You can do whatever coffeescript can do

    '.data': ->@content ? 'default'

Conditionals...

    '.data': ->if @hidden then 'hidden' else 'show'

Loops...

    '.data': ->item for item in @list

Even another function...

    '.data': -> ->'inner'

#####Arrays
Each element in an array will be inserted in order to the given position

    '.data': ['R','U','L','E']

The values in the array can be anything

    '.data': [->@a,->@b,->@c]

A Function can return an array

    '.data': ->item for item in @list

It can be processed by another rule first

    '.data': ->itemRule.render item for item in @list

#####Rules
A rule can be another rule.


If it has a template, it will render with that.


If it doesn't, it will use the current selection of the rule and modify that


#####Objects
You can have an object within the object. It is made into a new rule and the parent selector is the template root.

    '.data':
      '.inner': ->@content

#####HTML Elements and jQuery objects
The passed in object will be added as it is.

#####Objects with toString
An object that overrides toString will have their toString method called.


Some objects that override toString are Strings, Numbers, and Booleans.


They can also be your own.


###Template
The template can be whatever DOM object you want.

    <div class="template">
      <span class="content">
      </span>
    </div>
    dom = document.querySelector '.template'

It can also be an array of elements

    <div class="article"></div>
    <div class="article"></div>
    <div class="article"></div>
    dom = document.querySelectorAll '.article'

It can also be a jQuery (or similar) object

    $ '<div><span></span></div>'

###Execution
Pass whatever data you want to your Rule.

    rule.render
      content: 'a string'

A DOM element will be returned.

    <div class="template">
      <span class="data">
        'a string'
      </span>
    </div>

If the data isn't there, it's just ignored

    rule.render()

Or choose how you want to react.

    '.data=' ->@content ? ''

The data class element is replaced with an empty string.

    <div class="template">
    </div>

You can render to a specific dom instance

    rule.render {}, document.querySelectorAll('.container')

Why
---
With rule you can seperate your DOM from your mappings, from your data. With generic selectors you can change your DOM structure, and keep the same mappings, or change the mappings for a new data type and keep the same structure. They are no longer tied together, and you can use them how you like. With coffeescript you can have succinct code, with infinite power. Just use it wisely.


Rule Object methods
-------------------
**new Rule(rule, [template]):** create a new Rule based on the rule object given in, and an optional template. The template must be either an HTMLElement, an array of HTMLElements, or a jQuery like object that supports a 'get' method that returns an array of HTMLElements

**.render(data, [element]):** create an html element with the given data. If an optional element is given then apply modifications directly to it. The element parameter must meet the same type requirements of a template

Rule Static methods
---------------------
**Rule.split(selector):** takes a rule selector string in the format of [selector]?(@[attribute])?[-+<>=]? and splits it into an array of [selector, attribute, position]. If one of the sections are not there it will be returned as undefined

**Rule.parse(rule, data, selection):** takes the rule object binding and returns the data bound content based on its type. The return value will be either a Node object, a String, or an array of Node objects or Strings

**Rule.add(content, selection, [attribute], [position]):** adds content to a selection or its attribute at the given position. The selection and any added siblings will be returned.

Examples
--------

### Simple Example
#### Template
    <div class="simple">
      <span class="content"></span>
    </div>
#### Rule Object
    simple = new Rule
      '.content': ->@content
      $ '.simple'
#### Execution
    ($ 'body').append simple.render
        content: 'test'

### Embedded Object Example
#### Template
    <div class="book">
      <h1 class="title"></h1>
      <div class="author">
        <div class="name">
          <span class="first"></span>
          <span class="last"></span>
        </div>
      </div>
    </div>

#### Rule Object
    book = new Rule
      '.title': ->@title
      '.author':
        '.name':
          '.first': ->@author.first
          '.last': ->@author.last
      $ '.book'

#### Execution

    ($ 'body').append book.render
      title: 'The Hobbit'
      author:
        first: 'J. R. R.'
        last: 'Tolkien'

### Iteration Example
#### Template
    <ul class="list">
      <li class="item"><span class="content"></span></li>
    </ul>

#### Rule Object
    itemRule = new Rule
      '.content': ->@content ? 'default'
      $ '.list'
    listRule = new Rule
      '.': ->itemRule.render item for item in @list
      $ '.list > .item'

#### Execution
    ($ 'body').append listRule.render
      list: [{content: 'hello'}, {content: 'world'}, {}]


### Recursion Example
#### Template
    <ul class="recursive">
      <li class="location"></li>
      <div class="list"></div>
    </ul>

#### Rule Object
    recursive = new Rule
      '.location': ->@location
      '.list=': ->if @list then recursive.render item for item in @list
      $ '.recursive'

#### Execution
    ($ 'body').append recursive.render
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
        ]

Requirements
------------
Rule has no hard requirements. 'indexOf' and 'querySelectorAll' are used but fallbacks are exposed if the browser does not support those methods. For querySelectorAll, if the browser does not support it, a jQuery like library may be used that correctly implements wrapping an HTMLElement or array of HTMLElements with '$', the 'find' method, and the 'get' method.

Size
----
Rule attempts to be as simplistic and small as possible while still providing a large amount of flexibility and power

Here is a minified gzipped size comparison to some other client side templating libraries

  **rule:**        1.08 kb

  **mustache:**    2.01 kb

  **pure:**        4.21 kb

  **jade:**        8.19 kb

Thanks
------
Thanks to [Pure](http://beebole.com/pure/) for providing the inspiration.