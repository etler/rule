class Rule
  constructor: (rule) ->
    @rule = rule
  build: (data) =>
      @data = data ? {}
      element = @template.clone()
      for selector, rule of @rule
        @selector = selector
        result = @parse rule
        delete @selector
        selection = if selector is '.' then element else (element.find selector)
        if (@type result) is 'Array'
          selection.html ''
          selection.append item for item in result
        else
          selection.html result
      delete @data
      element[0]
  parse: (rule) ->
    switch @type rule
      when 'Function' then @parse (_.bind rule, @data)()
      when 'Array' then @parse item for item in rule
      when 'String' then rule.toString()
      when 'Object' then $(((new Rule rule).bind @template.find @selector).build @data).children()
      else rule
  type: (object) ->
    regex = /\[object ([^\]]+)\]/
    ((Object::toString.call object).match regex)?[1]
  bind: (template) ->
    @template = template
    @
