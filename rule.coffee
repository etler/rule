@.Rule =
class Rule
  constructor: (rule) ->
    @rule = rule
  build: (data) =>
    @data = data ? {}
    element = $(@template[0].cloneNode(true))
    for selector, rule of @rule
      # Parse the selector
      if position = (selector.slice -1).match /[-+=<>]/
        selector = selector.slice(0,-1)
      [selector, attribute] = selector.split('@', 2)
      selection = if selector is '' then element else element.find selector
      # Parse the rule
      @selection = selection
      content = @parse rule
      delete @selection
      # Add the content
      if content?
        if attribute
          if content.join? then content = content.join('')
          selection.attr attribute,
            switch position
              when '-' then content + (selection.attr attribute)
              when '+' then (selection.attr attribute) + content
              else content
        else
          if content.reduce
            content = (content.reduce ((container, content) -> container.append content), $ '<div>').html()
          switch position
            when '-' then selection.before content
            when '+' then selection.after content
            when '=' then selection.replaceWith content
            when '<' then selection.prepend content
            when '>' then selection.append content
            else selection.html content
    delete @data
    element
  parse: (rule) ->
    type =
      if rule instanceof HTMLElement
        'HTMLElement'
      else if rule instanceof $
        '$'
      else if rule instanceof Rule
        'Rule'
      else
        (Object::toString.call rule).slice 8, -1
    switch type
      when 'Function' then @parse rule.call @data
      when 'Array'    then @parse item for item in rule
      when 'Rule'     then (if rule.template? then rule.build @data else @parse rule.rule)
      when 'Object'   then $(((new Rule rule).bind @selection).build @data).html()
      when 'HTMLElement', '$', 'Undefined', 'Null' then rule
      else rule.toString()
  bind: (template) ->
    @template = template
    @
  unbind: ->
    delete @template
    @