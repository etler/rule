@.Rule =
class Rule
  constructor: (rule) ->
    @rule = rule
  build: (data) =>
    @data = data ? {}
    element = $(@template[0].cloneNode(true))
    for selector, rule of @rule
      @selector = selector
      result = @parse rule
      delete @selector
      if result? then @add selector, element, result
    delete @data
    element
  parse: (rule) ->
    switch @type rule
      when 'Function' then @parse rule.call @data
      when 'Array' then @parse item for item in rule
      when 'Rule' then (if rule.template? then rule.build @data else @parse rule.rule)
      when 'HTMLElement', '$', 'Undefined', 'Null' then rule
      when 'Object' then $(((new Rule rule).bind @template.find @selector).build @data).html()
      else rule.toString()
  add: (selector, element, content) ->
    if position = (selector.slice -1).match /[-+=<>]/
      selector = selector.slice(0,-1)
    [selector, attribute] = selector.split('@', 2)
    selection = if selector is '' then element else (element.find selector)
    if content instanceof Array
      if attribute
        content = content.join()
      else
        temp = $('<div>')
        temp.append item for item in content
        content = temp.html()
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
    if object instanceof HTMLElement
      'HTMLElement'
    else if object instanceof $
      '$'
    else if object instanceof Rule
      'Rule'
    else
      (Object::toString.call object).slice 8, -1
  bind: (template) ->
    @template = template
    @
  unbind: ->
    delete @template
    @