@.Rule =
class Rule
  # Build a new rule with a rule object
  constructor: (rule) ->
    @rule = rule

  # Map the data object to the template and return a new element populated with data
  # Optionally takes an element and applies modifications directly to that element
  render: (data, element) ->
    # Set element to a copy of the template if it is not already set
    element = $ (element ?= ($ @template)[0].cloneNode(true))
    # Insure element is always within a container to support modification on the root element
    ($ '<div>').append(element) if not element.parent().length
    # scope is used to encapsulate any content added outside of the main element
    scope = element
    for selector, rule of @rule
      [selector, attribute, position] = Rule.split selector
      # Empty selector selects the root element
      selection = if selector is '' then element else element.find selector
      # Add will return the elements that were added to the selection
      selection = Rule.add (Rule.parse rule, data, selection), selection, attribute, position
      # If we are manipulating the root template element and siblings
      if selector is '' and position in ['=','+','-']
        # Increase the scope for manipulated siblings
        scope = scope.add selection
        if position is '='
          scope = scope.not element
          # If we replaced the element then it should become the new content
          element = selection
    return scope

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
    # and apply changes directly to it. Return undefined in that case so
    else if rule instanceof Rule
      if rule.template? then rule.render data else rule.render data, selection; undefined
    # Return objects that can be added to the dom directly as is
    # If null or undefined return as is to be ignored
    else if rule instanceof HTMLElement or
      rule instanceof $ or
      !rule? or
      rule is true or
      rule is false
        rule
    # If the object has a custom toString then use it
    else if rule.toString isnt Object::toString
      rule.toString()
    # If the object does not have a custom toString
    # create a new rule from the object
    else
      Rule.parse (new Rule rule), data, selection

  # Add a content object to a selection or attribute
  # of a selection at the position specified
  @add: (content, selection, attribute, position) =>
    return selection if not (content?)
    # Attribute is specified, so modify attribute
    if attribute
      content = content.join('') if content instanceof Array
      selection.attr attribute,
        if position is '-' then content + (selection.attr attribute)
        else if position is '+' then (selection.attr attribute) + content
        else content
    # Attribute not specified so modify selected element
    else
      # Concatenate array content into one object
      if content instanceof Array
        content = (content.reduce ((container, content) -> container.append content), $ '<div>').contents()
      content = (container = ($ '<div>').append content).contents()
      # Add the content to various positions
      if position is '-' then content.insertBefore selection
      else if position is '+' then content.insertAfter selection
      else if position is '=' then content.replaceAll selection
      else if position is '<' then content.prependTo selection
      else if position is '>' then content.appendTo selection
      else content.appendTo selection.empty()

  # Parse the selector for selection, position and attribute
  @split: (selector) =>
    selector = selector[0...-1] if position = (selector[-1...].match /[-+=<>]/)?[0]
    [selector, attribute] = selector.split('@', 2)
    [selector, attribute, position]