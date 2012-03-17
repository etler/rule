@.Rule =
class Rule
  # Build a new rule with a rule object
  constructor: (rule) ->
    @rule = rule

  # Map the data object to the template and return a new
  # element populated with data Takes data and an optional template
  render: (data, element) ->
    element ?= @template
    element = $ element if not (element instanceof $)
    # Use cloneNode instead of clone to support zepto
    element = $ element[0].cloneNode true if @template?
    # Insure element is always within a container to support modification on the root element
    container = ($ '<div>').append element if element.parent().length is 0
    for selector, rule of @rule
      [selector, attribute, position] = Rule.split selector
      # Empty selector selects the root element
      selection = if selector is '' then element else element.find selector
      Rule.add (Rule.parse rule, data, selection), selection, attribute, position
      # If the element does not have a parent, it has been removed from the dom,
      # and all modifications on it will be trown away
      if element.parent().length is 0 then break
    return container?.html()

  # Parse the rule to get the content object
  @parse: (rule, data, selection) =>
    # If statments are used throughout instead of switches
    # because they compile to smaller javascript
    # Bind the function to the data and parse its results
    if rule instanceof Function
      Rule.parse (rule.call data), data, selection
    # Parse each item in the array and return the array
    else if rule instanceof Array
      Rule.parse item, data, selection for item in rule
    # Pass the data to the rule object, if the rule object
    # does not have a template then use the current selection
    # as the template and return its contents
    else if rule instanceof Rule
      if rule.template? then rule.render data else (rule.render data, selection).html()
    # Return objects that can be added to the dom directly as is
    # If null or undefined return as is to be ignored
    else if rule instanceof HTMLElement or rule instanceof $ or !rule? or rule is true or rule is false
      rule
    # If the object has a custom toString then use it
    else if rule.toString isnt Object::toString
      rule.toString()
    # If the object does not have a custom toString
    # create a new rule from the object
    else
      $((new Rule rule).render data, selection).html()

  # Add a content object to a selection or attribute
  # of a selection at the position specified
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