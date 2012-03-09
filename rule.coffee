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
      @add selector, element, result
    delete @data
    element[0]
  parse: (rule) ->
    switch @type rule
      when 'Function' then @parse (_.bind rule, @data)()
      when 'Array' then @parse item for item in rule
      when 'String' then rule.toString()
      when 'Object' then $(((new Rule rule).bind @template.find @selector).build @data).children()
      else rule
  add: (selector, element, content) ->
    [selector, attribute, position] = (selector.match /([^@]*[^-+=<>@])@?([^-+=<>]+)?([-+=<>])?/)[1..3]
    console.log selector
    console.log element
    console.log content
    selection = if selector is '.' then element else (element.find selector)
    if (@type content) is 'Array'
      if attribute
        content = content.join()
      else
        temp = $('<div>')
        temp.append item for item in content
        content = temp.contents()
    if attribute
      selection.attr attribute,
        switch position
          when '-' then content + (selection.attr attribute)
          when '+' then (selection.attr attribute) + content
          else content
    else
      switch position
        when '-' then selection.before content
        when '+' then selection.after content
        when '=' then selection.replaceWith content
        when '<' then selection.prepend content
        when '>' then selection.append content
        else selection.html content
  type: (object) ->
    regex = /\[object ([^\]]+)\]/
    ((Object::toString.call object).match regex)?[1]
  bind: (template) ->
    @template = template
    @
