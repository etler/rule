rule.js
=======
*functional coffeescript templating*

    rule = new Rule
      '.title': ->@title ? 'rule.js'
      '.description': ['rule.js ', 'is ', 'a ', 'templating ', 'library.']


What
----
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
    rule.bind(dom)


###Execution
Build the populated template with the data you pass it...

    rule.build
      content: 'a string'

Reap the rewards.

    <div class="template">
      <span class="data">
        'a string'
      </span>
    </div>

How
---
###Rules
The Rule constructor takes an object.

    rule = new Rule
      '.data': ->@content

####Keys
The key is a selector for the element to populate.

    '.data'

You can add @[attribute] to select the attribute within the selector.

    '.data@type'

You can add a position to point where to add the data to.

    '.data@type+'

#####Positions
**-**: jQuery's 'before' or concatenate before for attributes

**+**: jQuery's 'after' or concatenate after for attributes

**=**: jQuery's 'replaceWith'

**<**: jQuery's 'prepend'

**>**: jQuery's 'append'

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
Each element in an array is concatenated together, before being added

    '.data': ['R','U','L','E']

The values in the array can be anything

    '.data': [->@a,->@b,->@c]

A Function can return an array

    '.data': ->item for item in @list

It can be processed by another rule first

    '.data': ->itemRule.build item for item in @list

#####Rules
A rule can be another rule.


If it has a template, it will render with that.


If it doesn't, it will use the current position in the template as its template


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
    dom = $('.template')

Just turn it into a jQuery DOM object, and you're good to go.
    rule.bind(dom)

You need to tell your Rule what DOM object to use.

###Execution
Pass whatever data you want to your Rule.

    rule.build
      content: 'a string'

A DOM element will be returned.

    <div class="template">
      <span class="data">
        'a string'
      </span>
    </div>

If the data isn't there, it's just ignored

  rule.build()

Or choose how you want to react.

  '.data=' ->@content ? ''

The data class element is replaced with an empty string.

    <div class="template">
    </div>

Why
---
With rule you can seperate your DOM from your mappings, from your data. With generic selectors you can change your DM structure, and keep the same mappings, or change the mappings for a new data type and keep the same structure. They are no longer tied together, and you can use them how you like. With coffeescript you can have succinct code, with infinite power. Just use it wisely.


Rule Object methods
-------------------
**new Rule(rule):** create a new Rule based on the rule object given in.

**.build(data, [template]):** build an html element with the given data.

**.bind(template):** bind the rule to a jquery dom element to use as the template.

Rule Static methods
---------------------
**Rule.split(selector):** takes a rule selector string and splits it into an array of [selector, attribute, position].

**Rule.parse(rule, data, selection):** takes the rule object binding and returns the data bound content based on its type.

**Rule.add(content, selection, [attribute], [position]):** adds content to a selection or its attribute at the given position.

Examples
--------

### Simple Example
#### DOM Template
    <div class="simple">
      <span class="content"></span>
    </div>
#### Rule Object
    simple = new Rule
      '.content': ->@content
#### Execution
    simple.bind $ '#template > .simple'
      ($ 'body').append simple.build
        content: 'test'

### Embedded Object Example
#### DOM Template
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
#### Execution
    book.bind $ '#template > .book'

    ($ 'body').append book.build
      title: 'The Hobbit'
      author:
        first: 'J. R. R.'
        last: 'Tolkien'

### Iteration Example
#### DOM Template
    <ul class="list">
      <li class="item"><span class="content"></span></li>
    </ul>
#### Rule Object
    itemRule = new Rule
      '.content': ->@content ? 'default'
    listRule = new Rule
      '.': ->itemRule.build item for item in @list
#### Execution
    listRule.bind $ '#template > .list'
    itemRule.bind $ '#template > .list > .item'

    ($ 'body').append listRule.build
      list: [{content: 'hello'}, {content: 'world'}, {}]


### Recursion Example
#### DOM Template
    <ul class="recursive">
      <li class="location"></li>
      <div class="list"></div>
    </ul>
#### Rule Object
    recursive = new Rule
      '.location': ->@location
      '.list=': ->if @list then recursive.build item for item in @list
#### Execution
    recursive.bind $ '#template > .recursive'

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
        ]

Requirements
------------
jQuery, or a library that implements the following

  .add
  .append
  .appendTo
  .attr
  .contents
  .empty
  .find
  .insertAfter
  .insertBefore
  .parent
  .prependTo
  .render
  .replaceAll

Size
----
Rule attempts to be as simplistic and small as possible while still providing a large amount of flexibility and power

Here is a minified gzipped size comparison to some other client side templating libraries
  rule:        0.71 kb
  mustache:    2.01 kb
  pure:        4.21 kb
  jade:        8.19 kb

Thanks
------
Thanks to [Pure](http://beebole.com/pure/) for providing the inspiration.