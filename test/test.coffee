describe 'Rule', ->
  asString = (object) ->
    $('<div>').append($ object).html()
  describe '::split', ->
    selectors = [undefined, 'div', '.a', '.a-b', '["a=b"]', 'div:nth-child(n)', 'div > span', 'div + span']
    attributes = [undefined, 'a', 'a-b']
    positions = [undefined, '-', '+', '=', '<', '>']
    it "should return [selector, attribute, position]", ->
      for selector in selectors
        for attribute in attributes
          for position in positions
            expect(Rule.split (selector ? '')+(if attribute then '@'+attribute else '')+(position ? '')).to.be.eql [selector, attribute, position]
      return
  describe '::parse', ->
    it "should return the parsed result of the function bound to data", ->
      expect(Rule.parse (->@), 'a').to.be.eql 'a'
      expect(Rule.parse (->@a), {a:'b'}).to.be.eql 'b'
      expect(Rule.parse (->->@a), {a:'b'}).to.be.eql 'b'
      a = -> @a
      expect(Rule.parse (->a), {a:'b'}).to.be.eql 'b'
    it "should return the array with each array item parsed", ->
      a = document.createTextNode('a')
      b = document.createTextNode('b')
      c = document.createTextNode('c')
      expect(Rule.parse [a,b,c]).to.be.eql [a,b,c]
      expect(Rule.parse [(->@a),(->@b),(->@c)], {a: a, b: b, c: c}).to.be.eql [a,b,c]
    it "should return the result of the rule's render function", ->
      rule = new Rule
        '.a': ->@
      selection = $ '<div><span class="a"></div>'
      Rule.parse rule, 'b', selection
      expect(asString selection).to.be.equal asString $ '<div><span class="a">b</div>'
      selection = $ '<div><span class="a"></div>'
      rule.template = selection
      expect(asString Rule.parse rule, 'b').to.be.eql asString $ '<div><span class="a">b</span></div>'
    it "should return the passed in HTMLElement", ->
      el = $('<div>')[0]
      expect(Rule.parse el).to.be el
    it "should return the passed in jQuery object's contents as an array", ->
      el = $('<div>')
      expect((Rule.parse el)).to.eql el.get()
      el = $('<div></div><span></span>')
      expect((Rule.parse el)).to.eql el.get()
    it "should return undefined", ->
      expect(Rule.parse undefined).to.be undefined
    it "should return null", ->
      expect(Rule.parse null).to.be null
    it "should return the object's toString results", ->
      expect(Rule.parse true).to.be 'true'
      expect(Rule.parse false).to.be 'false'
      expect(Rule.parse 'abc').to.be 'abc'
      expect(Rule.parse 123).to.be '123'
      O = ->
      O.prototype.toString = -> 'test'
      o = new O
      expect(Rule.parse o).to.be 'test'
      o = {toString: -> 'test'}
      expect(Rule.parse o).to.be 'test'
    it "should return the results of the object compiled as a new rule with selection as the template", ->
      rule =
        '.a': ->@
      selection = $ '<div><span class="a"></div>'
      Rule.parse rule, 'b', selection
      expect(asString selection).to.be.eql asString $ '<div><span class="a">b</div>'
  describe '::add', ->
    it "should prepend the attribute with content", ->
      e = $('<div class="b">')
      expect(asString Rule.add 'a', e, 'class', '-').to.be.eql asString $('<div class="ab">')
    it "should append the attribute with content", ->
      e = $('<div class="a">')
      expect(asString Rule.add 'b', e, 'class', '+').to.be.eql asString $('<div class="ab">')
    it "should add before the attribute with content", ->
      e = $('<div class="b">')
      expect(asString Rule.add 'a', e, 'class', '<').to.be.eql asString $('<div class="a b">')
    it "should add after the attribute with content", ->
      e = $('<div class="a">')
      expect(asString Rule.add 'b', e, 'class', '>').to.be.eql asString $('<div class="a b">')
    it "should set the attribute to content", ->
      e = $('<div class="b">')
      expect(asString Rule.add 'a', e, 'class').to.be.eql asString $('<div class="a">')
    it "should add content before selection", ->
      c = $('<div>')
      e = $('<span>').appendTo c
      r = Rule.add 'a', e, null, '<'
      expect(asString c).to.be.eql asString $('<div>a<span></span></div>')
      expect(asString r).to.be.eql $('<div>a<span></span></div>').html()
    it "should add content after selection", ->
      c = $('<div>')
      e = $('<span>').appendTo c
      r = Rule.add 'a', e, null, '>'
      expect(asString c).to.be.eql asString $('<div><span></span>a</div>')
      expect(asString r).to.be.eql $('<div><span></span>a</div>').html()
    it "should add content as the first child of selection", ->
      c = $('<div>')
      e = $('<span>').appendTo c
      f = $('<span>').appendTo e
      r = Rule.add 'a', e, null, '-'
      expect(asString c).to.be.eql asString $('<div><span>a<span></span></span></div>')
      expect(asString r).to.be.eql $('<div><span>a<span></span></span></div>').html()
    it "should add content as the last child of selection", ->
      c = $('<div>')
      e = $('<span>').appendTo c
      f = $('<span>').appendTo e
      r = Rule.add 'a', e, null, '+'
      expect(asString c).to.be.eql asString $('<div><span><span></span>a</span></div>')
      expect(asString r).to.be.eql $('<div><span><span></span>a</span></div>').html()
    it "should set content to replace selection", ->
      c = $('<div>')
      e = $('<span>').appendTo c
      r = Rule.add 'a', e, null, '='
      expect(asString c).to.be.eql asString $('<div>a</div>')
      expect(asString r).to.be.eql 'a'
    it "should set content as the only child of selection", ->
      c = $('<div>')
      e = $('<span>').appendTo c
      f = $('<span>').appendTo e
      r = Rule.add 'a', e
      expect(asString c).to.be.eql asString $('<div><span>a</span></div>')
      expect(asString r).to.be.eql $('<div><span>a</span></div>').html()
    it "should set array of content as children of selection", ->
      c = $('<div>')
      r = Rule.add ['a','b','c','d'], c
      expect(asString c).to.be.eql asString $('<div>abcd</div>')
      expect(asString r).to.be.eql asString $('<div>abcd</div>')
    it "should set joined array of content as attribute", ->
      c = $('<div>')
      r = Rule.add ['a','b','c','d'], c, 'class'
      expect(asString r).to.be.eql asString $('<div class="abcd"></div>')
  describe '.render', ->
    # From template and application
    it "should clone a template and return that object", ->
      template = $('<div>')
      rule = new Rule
        '': 'test',
        template
      expect(asString rule.render()).to.be.eql asString $('<div>test</div>')
      expect(asString template).to.be.eql asString $('<div>')
    it "should alter a template and return that object", ->
      template = $('<div>')
      rule = new Rule
        '': 'test'
      expect(asString rule.render {}, template).to.be.eql asString $('<div>test</div>')
      expect(template).to.be.equal template
    # Attributes
    it "should set the attributes of the parent", ->
      rule = new Rule
        '@class': 'test',
        $('<div>')
      expect(asString rule.render()).to.be.eql asString $('<div class="test"></div>')
    it "should set the attributes of a selection", ->
      rule = new Rule
        'span@class': 'test',
        $('<div><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span class="test"></span></div>')
    # Data insertion
    it "should set the contents based on a data object", ->
      rule = new Rule
        '': ->@a,
        $('<div>')
      expect(asString rule.render {a: 'test'}).to.be.eql asString $('<div>test</div>')
    # Selections
    it "should set the contents of the selection", ->
      rule = new Rule
        'span': 'test',
        $('<div><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span>test</span></div>')
    it "should replace the contents of the selection", ->
      rule = new Rule
        'span': 'test',
        $('<div><span><a>a</a><a>b</a><a>c</a></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span>test</span></div>')
    it "should not find the selection and do nothing", ->
      rule = new Rule
        'span': 'x',
        $('<div><a></a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a></a></div>')
    it "should set the contents of a complex selection", ->
      rule = new Rule
        'a span:nth-of-type(2)': 'test',
        $('<div><a><span>a</span><h1>x</h1><span>b</span><span>c</span></a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a><span>a</span><h1>x</h1><span>test</span><span>c</span></a></div>')
    # Multiple Selections
    it "should set the contents of multiple selections", ->
      rule = new Rule
        'span': 'test',
        $('<div><span></span><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span>test</span><span>test</span></div>')
    it "should set the contents of multiple selections on different levels", ->
      rule = new Rule
        'span': 'test',
        $('<div><span></span><a><span></span></a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span>test</span><a><span>test</span></a></div>')
    # Parent Positioning
    it "should return the template and the content added before and after it", ->
      rule = new Rule
        '+': 'test',
        $('<div>a</div>')
      expect(asString rule.render()).to.be.eql $('<span><div>a</div>test</span>').html()
      rule = new Rule
        '-': 'test',
        $('<div>a</div>')
      expect(asString rule.render()).to.be.eql $('<span>test<div>a</div></span>').html()
    it "should add content in the right order and return the added siblings", ->
      rule = new Rule
        '+': 'e'
        '': 'c'
        '>': 'd'
        '<': 'b'
        '-': 'a',
        $('<span>x</span>')
      expect(asString rule.render()).to.be.eql $('<div>a<span>bcd</span>e</div>').html()
    it "should add content before and after, then replace the selection", ->
      rule = new Rule
        '+': 'c'
        '-': 'a'
        '=': 'b',
        $('<span>x</span>')
      expect(asString rule.render()).to.be.eql $('<div>abc</div>').html()
    # Parent Replacement
    it "should replace the root of the template with new content", ->
      rule = new Rule
        '=': 'test',
        $('<div>a</div>')
      expect(asString rule.render()).to.be.eql $('<span>test</span>').html()
    it "should replace the root of the template with new content and select off it", ->
      rule = new Rule
        '=': ->$('<a><span>a</span></a>')
        'span': 'test',
        $('<div><a>b</a></div>')
      expect(asString rule.render()).to.be.eql asString $('<a><span>test</span></a>')
    # Selection Positioning
    it "should add content before and after a selection", ->
      rule = new Rule
        'span-': ->$('<a>')
        $('<div><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a></a><span></span></div>')
      rule = new Rule
        'span+': ->$('<a>')
        $('<div><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span></span><a></a></div>')
    it "should add content after a selection and then select off it", ->
      rule = new Rule
        'span+': ->$('<a>')
        'a': 'test'
        $('<div><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span></span><a>test</a></div>')
    it "should add content to the start and end of a selection", ->
      rule = new Rule
        'span<': ->$('<a>')
        $('<div><span><p></p></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span><a></a><p></p></span></div>')
      rule = new Rule
        'span>': ->$('<a>')
        $('<div><span><p></p></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span><p></p><a></a></span></div>')
    it "should replace a selection", ->
      rule = new Rule
        'span=': ->$('<a>')
        $('<div><span><p></p></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a></a></div>')
    # Multiple Selection Positioning
    it "should add content before and after multiple selections", ->
      rule = new Rule
        'span-': ->$('<a>')
        $('<div><span></span><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a></a><span></span><a></a><span></span></div>')
      rule = new Rule
        'span+': ->$('<a>')
        $('<div><span></span><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span></span><a></a><span></span><a></a></div>')
    it "should add content to the start and end of multiple selections", ->
      rule = new Rule
        'span<': ->$('<a>')
        $('<div><span><p></p></span><span><h1></h1></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span><a></a><p></p></span><span><a></a><h1></h1></span></div>')
      rule = new Rule
        'span>': ->$('<a>')
        $('<div><span><p></p></span><span><h1></h1></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span><p></p><a></a></span><span><h1></h1><a></a></span></div>')
    it "should replace multiple selections", ->
      rule = new Rule
        'span=': ->$('<a>')
        $('<div><span><p></p></span><span><h1></h1></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a></a><a></a></div>')
    # Selection Attributes
    it "should alter attributes of a selection", ->
      rule = new Rule
        'span@class': 'test',
        $('<div><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span class="test"></span></div>')
    it "should set the attributes of a complex selection", ->
      rule = new Rule
        'a span:nth-of-type(2)@class': 'test',
        $('<div><a><span>a</span><h1>x</h1><span>b</span><span>c</span></a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a><span>a</span><h1>x</h1><span class="test">b</span><span>c</span></a></div>')
    it "should alter attributes of multiple selections", ->
      rule = new Rule
        'span@class': 'test'
        $('<div><span></span><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span class="test"></span><span class="test"></span></div>')
    # Sub Rules
    it "should select into a new scope and apply a new rule object to it", ->
      rule = new Rule
        'a':
          'span': 'c',
        $('<div><a><span>b</span></a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a><span>c</span></a></div>')
    it "should select into a new scope and not find the selection in the new context", ->
      rule = new Rule
        'a':
          'div': 'c',
        $('<div><a><span>b</span></a><div></div></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a><span>b</span></a><div></div></div>')
    it "should select into a new scope, replace it, then select off of it", ->
      rule = new Rule
        'a':
          '=': ->$('<span>')
        'span': 'b',
        $('<div><a>b</a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span>b</span></div>')
    it "should select into a new scope and do nothing", ->
      rule = new Rule
        '': {},
        $('<div>')
      expect(asString rule.render()).to.be.eql asString $('<div></div>')
    it "should remove a selection then attempt to add to it", ->
      rule = new Rule
        'a':
          '=': ''
          '': 'c',
        $('<div><a>b</a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div></div>')
    it "should replace a selection then add to it", ->
      rule = new Rule
        'a':
          '=': ->$('<span>')
          '': 'c',
        $('<div><a>b</a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span>c</span></div>')
    it "should add a sibling to a selection then add to the root", ->
      rule = new Rule
        'a':
          '+': ->$('<a>')
          '': 'c'
        $('<div><a>b</a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a>c</a><a></a></div>')
    # Arrays
    it "should set the contents to the result of an array of functions", ->
      rule = new Rule
        'span': [(->@a), (->@b), (->@c)],
        $('<div><span></span></div>')
      expect(asString rule.render {a:'x',b:'y',c:'z'}).to.be.eql asString $('<div><span>xyz</span></div>')
    it "should set the contents to the result of a function that returns an array of functions", ->
      rule = new Rule
        'span': -> ((i)->i*@x).bind(@, i) for i in [1...5],
        $('<div><span></span></div>')
      expect(asString rule.render {x: 2}).to.be.eql asString $('<div><span>2468</span></div>')
    # Array of parents
    it "should append before each element in the parent array", ->
      rule = new Rule
        '-': ->$('<a>')
        $('<div></div><div></div><div></div>')
      expect(asString rule.render()).to.be.eql asString $('<a></a><div></div><a></a><div></div><a></a><div></div>')
    it "should append before each element in the parent array then replace each parent element with new content", ->
      rule = new Rule
        '-': ->$('<a>')
        '=': ->$('<div>')
        $('<span></span><span></span><span></span>')
      expect(asString rule.render()).to.be.eql asString $('<a></a><div></div><a></a><div></div><a></a><div></div>')
    it "should take array, append before, replace with array, then append after", ->
      rule = new Rule
        '-': ->$('<a>')
        '=': [(->$ '<div>'), (->$ '<div>')]
        '+': ->$('<p>')
        $('<span></span><span></span>')
      expect(asString rule.render()).to.be.eql asString $('<a></a><div></div><p></p><div></div><p></p><a></a><div></div><p></p><div></div><p></p>')
    it "should take array, append before, replace with jQuery, then append after", ->
      rule = new Rule
        '-': ->$('<a>')
        '=': ->$('<div></div><div></div>')
        '+': ->$('<p>')
        $('<span></span><span></span>')
      expect(asString rule.render()).to.be.eql asString $('<a></a><div></div><p></p><div></div><p></p><a></a><div></div><p></p><div></div><p></p>')