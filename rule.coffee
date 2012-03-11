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
            if position is '-'
              content + (selection.attr attribute)
            else if position is '+'
              (selection.attr attribute) + content
            else content
        else
          if content.reduce
            content = (content.reduce ((container, content) -> container.append content), $ '<div>').html()
          if position is '-'
            selection.before content
          else if position is '+'
            selection.after content
          else if position is '='
            selection.replaceWith content
          else if position is '<'
            selection.prepend content
          else if position is '>'
            selection.append content
          else selection.html content
    delete @data
    element
  parse: (rule) ->
    if rule instanceof Function
      @parse rule.call @data
    else if rule instanceof Array
      @parse item for item in rule
    else if rule instanceof Rule
      if rule.template? then rule.build @data else @parse rule.rule
    else if rule instanceof HTMLElement or rule instanceof $ or !rule?
      rule
    else if rule.toString isnt Object::toString
      rule.toString()
    else
      $(((new Rule rule).bind @selection).build @data).html()
  bind: (template) ->
    @template = template
    @
  unbind: ->
    delete @template
    @