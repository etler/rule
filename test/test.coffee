describe 'Rule', ->
  asString = (object) ->
    $('<div>').append(object).html()
  describe '::split', ->
    selectors = ['div', '.a', '.a-b', '["a=b"]', 'div:nth-child(n)', 'div > span', 'div + span']
    attributes = ['a', 'a-b']
    positions = ['-', '+', '=', '<', '>']
    it "should return [selector, undefined, undefined]", ->
      for selector in selectors
        expect(Rule.split "#{selector}").to.be.eql [selector, undefined, undefined]
      return
    it "should return [selector, attribute, undefined]", ->
      for selector in selectors
        for attribute in attributes
          expect(Rule.split "#{selector}@#{attribute}").to.be.eql [selector, attribute, undefined]
      return
    it "should return [selector, undefined, position]", ->
      for selector in selectors
        for position in positions
          expect(Rule.split "#{selector}#{position}").to.be.eql [selector, undefined, position]
      return
    it "should return [selector, attribute, position]", ->
      for selector in selectors
        for attribute in attributes
          for position in positions
            expect(Rule.split "#{selector}@#{attribute}#{position}").to.be.eql [selector, attribute, position]
      return

  describe '::parse', ->
    it "should return the parsed result of the function bound to data", ->
      expect(Rule.parse (->@), 'a').to.be 'a'
      expect(Rule.parse (->@a), {a:'b'}).to.be 'b'
      expect(Rule.parse (->->@a), {a:'b'}).to.be 'b'
      a = -> @a
      expect(Rule.parse (->a), {a:'b'}).to.be 'b'
    it "should return the array with each array item parsed", ->
      expect(Rule.parse ['a','b','c']).to.be.eql ['a','b','c']
      expect(Rule.parse [(->@a),(->@b),(->@c)], {a:'a',b:'b',c:'c'}).to.be.eql ['a','b','c']
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
    it "should return the passed in jQuery object", ->
      el = $('<div>')
      expect(Rule.parse el).to.be el
    it "should return undefined", ->
      expect(Rule.parse undefined).to.be undefined
    it "should return null", ->
      expect(Rule.parse null).to.be null
    it "should return true or false", ->
      expect(Rule.parse true).to.be true
      expect(Rule.parse false).to.be false
    it "should return the object's toString results", ->
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
    it "should set the attribute to content", ->
      e = $('<div class="b">')
      expect(asString Rule.add 'a', e, 'class').to.be.eql asString $('<div class="a">')
    it "should add content before selection", ->
      c = $('<div>')
      e = $('<span>').appendTo c
      r = Rule.add 'a', e, null, '-'
      expect(asString c).to.be.eql asString $('<div>a<span></span></div>')
      expect(asString r).to.be.eql 'a'
    it "should add content after selection", ->
      c = $('<div>')
      e = $('<span>').appendTo c
      r = Rule.add 'a', e, null, '+'
      expect(asString c).to.be.eql asString $('<div><span></span>a</div>')
      expect(asString r).to.be.eql 'a'
    it "should add content as the first child of selection", ->
      c = $('<div>')
      e = $('<span>').appendTo c
      f = $('<span>').appendTo e
      r = Rule.add 'a', e, null, '<'
      expect(asString c).to.be.eql asString $('<div><span>a<span></span></span></div>')
      expect(asString r).to.be.eql 'a'
    it "should add content as the last child of selection", ->
      c = $('<div>')
      e = $('<span>').appendTo c
      f = $('<span>').appendTo e
      r = Rule.add 'a', e, null, '>'
      expect(asString c).to.be.eql asString $('<div><span><span></span>a</span></div>')
      expect(asString r).to.be.eql 'a'
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
      expect(asString r).to.be.eql 'a'
    it "should set array of content as children of selection", ->
      c = $('<div>')
      r = Rule.add ['a','b','c','d'], c
      expect(asString c).to.be.eql asString $('<div>abcd</div>')
      expect(asString r).to.be.eql 'abcd'
    it "should set joined array of content as attribute", ->
      c = $('<div>')
      r = Rule.add ['a','b','c','d'], c, 'class'
      expect(asString r).to.be.eql asString $('<div class="abcd"></div>')
  describe '.render', ->
    it "should clone a template and return that object", ->
      rule = new Rule
        '': 'test'
      template = $('<div>')
      rule.template = template
      expect(asString rule.render()).to.be.eql asString $('<div>test</div>')
      expect(asString template).to.be.eql asString $('<div>')
    it "should alter a template and return that object", ->
      rule = new Rule
        '': 'test'
      template = $('<div>')
      expect(asString rule.render {}, template).to.be.eql asString $('<div>test</div>')
      expect(template).to.be.equal template
    it "should set the base attributes", ->
      rule = new Rule
        '@class': 'test'
      rule.template = $('<div>')
      expect(asString rule.render()).to.be.eql asString $('<div class="test"></div>')
    it "should set the attributes of a selection", ->
      rule = new Rule
        'span@class': 'test'
      rule.template = $('<div><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span class="test"></span></div>')
    it "should set the contents based on a data object", ->
      rule = new Rule
        '': ->@a
      rule.template = $('<div>')
      expect(asString rule.render {a: 'test'}).to.be.eql asString $('<div>test</div>')
    it "should set the contents of the selection", ->
      rule = new Rule
        'span': 'test'
      rule.template = $('<div><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span>test</span></div>')
    it "should set the contents of multiple selections", ->
      rule = new Rule
        'span': 'test'
      rule.template = $('<div><span></span><span></span></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span>test</span><span>test</span></div>')
    it "should set the contents of multiple selections on different levels", ->
      rule = new Rule
        'span': 'test'
      rule.template = $('<div><span></span><a><span></span></a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span>test</span><a><span>test</span></a></div>')
    it "should set the contents of a complex selection", ->
      rule = new Rule
        'a span:nth-of-type(2)': 'test'
      rule.template = $('<div><a><span>a</span><h1>x</h1><span>b</span><span>c</span></a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a><span>a</span><h1>x</h1><span>test</span><span>c</span></a></div>')
    it "should set the attributes of a complex selection", ->
      rule = new Rule
        'a span:nth-of-type(2)@class': 'test'
      rule.template = $('<div><a><span>a</span><h1>x</h1><span>b</span><span>c</span></a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a><span>a</span><h1>x</h1><span class="test">b</span><span>c</span></a></div>')
    it "should return the template and the content added after it", ->
      rule = new Rule
        '+': 'test'
      rule.template = $('<div>a</div>')
      expect(asString rule.render()).to.be.eql asString $('<span><div>a</div>test</span>').html()
    it "should return the template and the content added before it", ->
      rule = new Rule
        '-': 'test'
      rule.template = $('<div>a</div>')
      expect(asString rule.render()).to.be.eql asString $('<span>test<div>a</div></span>').html()
    it "should add content in the right order and return the added siblings", ->
      rule = new Rule
        '+': 'e'
        '': 'c'
        '>': 'd'
        '<': 'b'
        '-': 'a'
      rule.template = $('<span>x</span>')
      expect(asString rule.render()).to.be.eql asString $('<div>a<span>bcd</span>e</div>').html()
    it "should replace the root of the template with the new content", ->
      rule = new Rule
        '=': 'test'
      rule.template = $('<div>a</div>')
      expect(asString rule.render()).to.be.eql asString $('<span>test</span>').html()
    it "should replace the root of the template with the new content and select off it", ->
      rule = new Rule
        '=': ->$('<a><span>a</span></a>')
        'span': 'test'
      rule.template = $('<div><a>b</a></div>')
      expect(asString rule.render()).to.be.eql asString $('<a><span>test</span></a>')
    it "should select into a new scope and apply a new rule object to it", ->
      rule = new Rule
        'a':
          'span': 'c'
      rule.template = $('<div><a><span>b</span></a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a><span>c</span></a></div>')
    it "should select into a new scope and not find the selection in the new context", ->
      rule = new Rule
        'a':
          'div': 'c'
      rule.template = $('<div><a><span>b</span></a><div></div></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a><span>b</span></a><div></div></div>')
    it "should not find the selection and do nothing", ->
      rule = new Rule
        'span': 'x'
      rule.template = $('<div><a></a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a></a></div>')
    it "should select into a new scope, replace it, then select off of it", ->
      rule = new Rule
        'a':
          '=': ->$('<span>')
        'span': 'b'
      rule.template = $('<div><a>b</a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span>b</span></div>')
    it "should set the contents to the result of an array of functions", ->
      rule = new Rule
        'span': [(->@a), (->@b), (->@c)]
      rule.template = $('<div><span></span></div>')
      expect(asString rule.render {a:'x',b:'y',c:'z'}).to.be.eql asString $('<div><span>xyz</span></div>')
    it "should set the contents to the result of a function that returns an array of functions", ->
      rule = new Rule
        'span': -> ((i)->i*@x).bind(@, i) for i in [1...5]
      rule.template = $('<div><span></span></div>')
      expect(asString rule.render {x: 2}).to.be.eql asString $('<div><span>2468</span></div>')
    it "should remove a selection then attempt to add to it", ->
      rule = new Rule
        'a':
          '=': ''
          '': 'c'
      rule.template = $('<div><a>b</a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div></div>')
    it "should replace a selection then add to it", ->
      rule = new Rule
        'a':
          '=': ->$('<span>')
          '': 'c'
      rule.template = $('<div><a>b</a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><span>c</span></div>')
    it "should add a sibling to a selection then add to the root", ->
      rule = new Rule
        'a':
          '+': ->$('<a>')
          '': 'c'
      rule.template = $('<div><a>b</a></div>')
      expect(asString rule.render()).to.be.eql asString $('<div><a>c</a><a></a></div>')
    it "shoud do nothing if selector is given an empty object", ->
      rule = new Rule
        '': {}
      rule.template = $('<div>')
      expect(asString rule.render()).to.be.eql asString $('<div></div>')