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
    it "should return the result of the rule's build function", ->
      rule = new Rule
        '.a': ->@
      selection = $ '<div><span class="a"></div>'
      expect(asString Rule.parse rule, 'b', selection).to.be.eql asString $ '<span class="a">b</span>'
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
      expect(asString Rule.parse rule, 'b', selection).to.be.eql asString $ '<span class="a">b</span>'
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
      e = $('<div class="b">')
      expect(asString Rule.add 'a', e, 'class', null).to.be.eql asString $('<div class="a">')
    it "should add content before selection", ->
      e = $('<div>')
      expect(asString Rule.add 'a', e, null, '-').to.be.eql asString $('a<div></div>')
    it "should add content after selection", ->
      e = $('<div>')
      expect(asString Rule.add 'a', e, null, '+').to.be.eql asString $('<div></div>a')
    it "should add content as the first child of selection", ->
      e = $('<div>')
      f = $('<span>').appendTo e
      expect(asString Rule.add 'a', e, null, '<').to.be.eql asString $('<div>a<span></span></div>')
    it "should add content as the last child of selection", ->
      e = $('<div>')
      f = $('<span>').appendTo e
      expect(asString Rule.add 'a', e, null, '>').to.be.eql asString $('<div><span></span>a</div>')
    it "should set content to replace selection", ->
      e = $('<div>')
      expect(asString Rule.add '<span>', e, null, '=').to.be.eql asString $('<span>')
    it "should set content as the only child of selection", ->
      e = $('<div>')
      expect(asString Rule.add 'a', e).to.be.eql asString $('<div>a</div>')
  describe '.render', ->
    it "should return a jQuery object", ->
      # Test what happens if you set the current selection to nothing, then select off of it after
      rule = new Rule
        'select':
          '=': -> if not @options? then ''
          'option': -> option.value for option in @options?
      template = $('''
          <div>
            <select>
              <option>
              </option>
            </select>
          </div>
        ''')
      expect(asString rule.render {}, template).to.be.eql asString $('<div></div>')