# Rule v0.2.0
# templating library
# http://rulejs.com
# http://github.com/etler/rule
#
# Copyright 2012, Tim Etler (tmetler@gmail.com)
# Licensed under the MIT or GPL Version 2 licenses.

class Rule
  # Build a new Rule with a rule object and optional template
  constructor: (rule, template) ->
    if rule? then @rule = rule
    if template then @template = template

  # Apply a rule to a cloned template, taking data that is passed to rule functions
  # Optionally takes an element and applies modifications directly to that element
  render: (data, parent) ->
    env = @constructor.env
    # Compatibility fallbacks for certain browsers that don't support indexOf and querySelectorAll
    indexOf = Array::indexOf ? (item) ->
      for value, index in @
        if index of @ and value is item
         return index
        return -1
    # Hack to support IE8, does not support accessing DOM constructors
    querySelectorAll = env.document.createElement('div').querySelectorAll ? (query) ->
      ((env.$ @).find query).get()
    # Converts a single Node object, or a jQuery style object
    # object to a javascript array of Node objects
    toElementArray = (element) ->
      # Using $.fn instead of instanceof $ because zepto does not support latter
      if env.$?.fn.isPrototypeOf(element)
        element.get()
      else if element instanceof env.Node
        [element]
      else element
    # Insures optional passed in parent element is an array of Nodes
    parent = toElementArray parent
    # Set parent to a copy of the template if it is not already set
    if !parent?
      parent = (subparent.cloneNode true for subparent in toElementArray @template)
    # scope is used to encapsulate any content added outside of the parent
    scope = parent[0..]
    for key, rule of @rule
      # Apply each rule to each parent object.
      # Applied to a copy of parent because parent may change during application
      for subparent in parent[0..]
        [selector, attribute, position] = @constructor.split key
        # Empty selector selects the parent as an array
        if selector?
          if subparent.querySelectorAll?
            selection = (element for element in subparent.querySelectorAll selector)
          else
            selection = (element for element in querySelectorAll.call subparent, selector)
        else
          selection = [subparent]
        # Add will return the selection and sibling elements
        result = @constructor.add (@constructor.parse.bind @constructor, rule, data, selection, @), selection, attribute, position
        # If we are manipulating the parent and siblings update scope and
        # parent to reflect change in top level structure
        if !selector?
          scope.splice (indexOf.call scope, subparent), 1, result...
          parent.splice (indexOf.call parent, subparent), 1, result... if position is '='
    return scope

  # Parse the rule to get the content object
  @parse: (rule, data, selection, context) ->
    # If statments are used throughout instead of switches
    # because they compile to smaller javascript
    # Bind the function to the data and current selection and parse its results
    if rule instanceof Function
      @parse (rule.call data, selection, context), data, selection, context
    # Parse each item in the array and return a flat array
    else if rule instanceof Array
      result = []
      result = result.concat (@parse item, data, selection, context) for item in rule
      return result
    # Pass the data to the rule object, if the rule object
    # does not have a template then use the current selection
    # and apply changes directly to it.
    # Return undefined in that case so it is not added twice.
    else if rule instanceof Rule
      if rule.template?
        rule.render data
      else
        rule.render data, selection
        return undefined
    # Return objects that can be added to the dom directly as is
    # If null or undefined return as is to be ignored
    else if rule instanceof @env.Node or !rule?
      rule
    # A helper case for jQuery style objects.
    else if $?.fn.isPrototypeOf(rule)
      rule.get()
    # If the object has a custom toString then use it
    else if rule.toString isnt Object::toString
      rule.toString()
    # If the object does not have a custom toString
    # create a new rule from the object
    else if Object::isPrototypeOf rule
      @parse (new Rule rule), data, selection, context

  # Add a content object to an array of selection or attributes
  # of the selections at the position specified
  # Returns the selections and any siblings as an array of Nodes
  @add: (generator, selections, attribute, position) ->
    result = []
    # Make sure content generator is always a generator
    if !(generator instanceof Function)
      # The generator value is bound so the value within the closure
      # will not be overwritten
      generator = ((value) -> value).bind(@, generator)
    for selection in selections
      content = do generator
      # Nothing to do here
      continue unless content?
      # Attribute is specified, so modify attribute
      if attribute? and content?
        content = content.join('') if content instanceof Array
        previous = (selection.getAttribute attribute) ? ''
        selection.setAttribute attribute,
          if position is '<' then content + previous
          else if position is '>' then previous + content
          else if position is '-' then content + ' ' + previous
          else if position is '+' then previous + ' ' + content
          else content
      # Attribute not specified so modify selected element
      else
        # Add the content to various positions
        parent = target = selection
        # Content is being added to the top level position
        if position in ['-', '+', '=']
          parent = selection.parentElement
        # To insert after the selection
        if position is '+'
          target = selection.nextSibling
        # To insert at the start
        if position is '<'
          target = selection.firstChild
        # To insert at the end
        if position is '>' or !position?
          target = null
        # Remove all children
        if !position?
          selection.removeChild selection.firstChild while selection.firstChild?
        content = [content] if !(content instanceof Array)
        for element in content
          # If content is not a DOM Node already, always convert to a TextNode
          element =
            if !(element instanceof @env.Node) then @env.document.createTextNode element else element
          # Add selection either before or after in the right order
          result.push selection if position is '+'
          result.push element
          result.push selection if position is '-'
          # Parent must be an HTMLElement to insure we can add to it
          # We can assume parent is a Node, but not all Nodes can be added too
          if parent instanceof @env.HTMLElement
            parent.insertBefore element, target
        # If position is =, the old selection must be removed
        parent?.removeChild target if position is '='
    # Only return result array if we are adding siblings, otherwise return the top level selections
    return if position in ['-', '+', '='] and !attribute? then result else selections

  # Parse the selector for selection, attribute, and position
  @split: (key) ->
    # Splits [(selector)][@(attribute)][(-<=>+)]
    # Regexes are not used for speed
    position = key[-1...]
    if position in ['-','+','<','>','='] then key = key[0...-1] else position = undefined
    [selector, attribute] = key.split('@', 2)
    selector = undefined if selector is ''
    return [selector, attribute, position]

  @env: window ? undefined

# Test if the javascript environment is node, or the browser
# In node module is defined within the global closure,
# but 'this' is an empty object
if module? and @module isnt module
  exports.Rule = Rule
else
  window.Rule = Rule

return Rule
