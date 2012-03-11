@.Rule =
class Rule
  constructor: (rule) ->
    @rule = rule
  # Map the data object to the template and return a new element populated with data
  build: (data) =>
    @data = data ? {}
    # Use cloneNode instead of clone to support zepto
    element = $(@template[0].cloneNode(true))
    for selector, rule of @rule
      # Parse the selector for selection, position and attribute
      if position = (selector.slice -1).match /[-+=<>]/
        selector = selector.slice(0,-1)
      [selector, attribute] = selector.split('@', 2)
      selection = if selector is '' then element else element.find selector
      # Parse the rule to get the content object
      @selection = selection
      content = @parse rule
      delete @selection
      # Add the content to the element, do nothing if content is undefined
      if content?
        # Attribute is specified, so modify attribute
        if attribute
          if content.join? then content = content.join('')
          selection.attr attribute,
            if position is '-'
              content + (selection.attr attribute)
            else if position is '+'
              (selection.attr attribute) + content
            else content
        # Attribute not specified so modify selected element
        else
          # Concatenate array content into one object
          if content.reduce
            content = (content.reduce ((container, content) -> container.append content), $ '<div>').html()
          # Add the content to various positions
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
  # Determine what content to return for a rule
  # @data and @selection are temporarily bound to @ so we
  # don't have to pass the same values to parse repeatedly
  parse: (rule) ->
    if rule instanceof Function
      # Bind the function to the data and parse its results
      @parse rule.call @data
    else if rule instanceof Array
      # Parse each item in the array and return the array
      @parse item for item in rule
    else if rule instanceof Rule
      # Pass the data to the rule object, or if the rule object
      # is not bound parse on the underlying rule's rule
      if rule.template? then rule.build @data else @parse rule.rule
    else if rule instanceof HTMLElement or rule instanceof $ or !rule?
      # Return objects that can be added to the dom directly as is
      # If null or undefined return as is to be ignored
      rule
    else if rule.toString isnt Object::toString
      # If the object has a custom toString then use it
      rule.toString()
    else
      # If the object does not have a custom toString
      # create a new rule from the object
      $(((new Rule rule).bind @selection).build @data).html()
  # Set the rule's template
  bind: (template) ->
    @template = template
    @
  # Unset the rule's template
  unbind: ->
    delete @template
    @