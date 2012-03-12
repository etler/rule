@.Rule =
class Rule
  constructor: (rule) ->
    @rule = rule
  # Map the data object to the template and return a new element populated with data
  build: (data, template) ->
    template ?= @template
    if not template instanceof $ then template = $(template)
    # Use cloneNode instead of clone to support zepto
    element = $(@template?[0].cloneNode(true))
    for selector, rule of @rule
      [selector, attribute, position] = Rule.split selector
      selection = if selector is '' then element else element.find selector
      Rule.add (Rule.parse rule, data, selection), selection, attribute, position
      # Add the content to the element, do nothing if content is undefined
    return element
  # Set the rule's template
  bind: (template) ->
    @template = template
    return @
  # Unset the rule's template
  unbind: ->
    delete @template
    return @
  # Parse the rule to get the content object
  @parse: (rule, data, selection) =>
    # If statments are used throughout instead of switches
    # because they compile to smaller javascript
    # Bind the function to the data and parse its results
    if rule instanceof Function then Rule.parse (rule.call data), data, selection
    # Parse each item in the array and return the array
    else if rule instanceof Array then Rule.parse item, data, selection for item in rule
    # Pass the data to the rule object, or if the rule object
    # is not bound parse on the underlying rule's rule
    else if rule instanceof Rule then (if rule.template? then rule.build data else Rule.parse rule.rule, data, selection)
    # Return objects that can be added to the dom directly as is
    # If null or undefined return as is to be ignored
    else if rule instanceof HTMLElement or rule instanceof $ or !rule? then rule
    # If the object has a custom toString then use it
    else if rule.toString isnt Object::toString then rule.toString()
    # If the object does not have a custom toString
    # create a new rule from the object
    else $(((new Rule rule).bind selection).build data).html()
  @add: (content, selection, attribute, position) =>
    if content?
      # Attribute is specified, so modify attribute
      if attribute
        content = content.join('') if content.join?
        selection.attr attribute,
          if position is '-' then content + (selection.attr attribute)
          else if position is '+' then (selection.attr attribute) + content
          else content
      # Attribute not specified so modify selected element
      else
        # Concatenate array content into one object
        if content.reduce
          # Appending to a div is insted of after to an empty $() because zepto does not support that
          content = (content.reduce ((container, content) -> container.append content), $ '<div>').html()
        # Add the content to various positions
        if position is '-' then selection.before content
        else if position is '+' then selection.after content
        else if position is '=' then selection.replaceWith content
        else if position is '<' then selection.prepend content
        else if position is '>' then selection.append content
        else selection.html content
    return selection
  # Parse the selector for selection, position and attribute
  @split: (selector) =>
    selector = selector[0...-1] if position = (selector[-1...].match /[-+=<>]/)?[0]
    [selector, attribute] = selector.split('@', 2)
    [selector, attribute, position]