@.Rule =
class Rule
  constructor: (rule) ->
    @rule = rule
  # Map the data object to the template and return a new element populated with data
  build: (data) =>
    # @data and @selection are used so they don't have to be repeatedly passed to @parse
    # They are deleted before the end of this function
    @data = data ? {}
    # Use cloneNode instead of clone to support zepto
    element = $(@template[0].cloneNode(true))
    for selector, rule of @rule
      # Parse the selector for selection, position and attribute
      selector = selector[0...-1] if position = (selector[-1...]).match /[-+=<>]/
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
    delete @data
    element
  # Determine what content to return for a rule
  # @data and @selection are temporarily bound to @ so we
  # don't have to pass the same values to parse repeatedly
  # If statments are used throughout instead of switches
  # because they compile to smaller javascript
  parse: (rule) ->
    # Bind the function to the data and parse its results
    if rule instanceof Function then @parse rule.call @data
    # Parse each item in the array and return the array
    else if rule instanceof Array then @parse item for item in rule
    # Pass the data to the rule object, or if the rule object
    # is not bound parse on the underlying rule's rule
    else if rule instanceof Rule then (if rule.template? then rule.build @data else @parse rule.rule)
    # Return objects that can be added to the dom directly as is
    # If null or undefined return as is to be ignored
    else if rule instanceof HTMLElement or rule instanceof $ or !rule? then rule
    # If the object has a custom toString then use it
    else if rule.toString isnt Object::toString then rule.toString()
    # If the object does not have a custom toString
    # create a new rule from the object
    else $(((new Rule rule).bind @selection).build @data).html()
  # Set the rule's template
  bind: (template) ->
    @template = template
    @
  # Unset the rule's template
  unbind: ->
    delete @template
    @