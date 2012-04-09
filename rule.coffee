# Rule v0.1.0
# templating library
# http://rulejs.com
# http://github.com/etler/rule
#
# Copyright 2012, Tim Etler
# Licensed under the MIT or GPL Version 2 licenses.

@.Rule =
class Rule
  # Build a new rule with a rule object
  constructor: (rule, template) ->
    @rule = rule
    @template = template

  # Map the data object to the template and return a new element populated with data
  # Optionally takes an element and applies modifications directly to that element
  render: (data, parent) ->
    toElementArray = (element) ->
      if $.fn.isPrototypeOf(element) then element.get() else if element instanceof Node then [element] else element
    parent = toElementArray parent
    # Set parent to a copy of the template if it is not already set
    if !parent?
      parent = (subparent.cloneNode true for subparent in toElementArray @template)
    # scope is used to encapsulate any content added outside of the parent
    scope = parent[0..]
    for key, rule of @rule
      for subparent in parent[0..]
        [selector, attribute, position] = Rule.split key
        # Empty selector selects the parent
        if selector?
          selection = []
          selection.push element for element in subparent.querySelectorAll(selector)
        else
          selection = [subparent]
        # Add will return the elements that were added to the selection
        result = Rule.add (Rule.parse rule, data, selection), selection, attribute, position
        # If we are manipulating the parent and siblings
        if !selector?
          index = scope.indexOf subparent
          scope.splice index, 1, result...
          parent.splice (parent.indexOf subparent), 1, result... if position is '='
    return scope

  # Parse the rule to get the content object
  @parse: (rule, data, selection) ->
    # If statments are used throughout instead of switches
    # because they compile to smaller javascript
    # Bind the function to the data and parse its results
    if rule instanceof Function
      Rule.parse (rule.call data, selection), data, selection
    # Parse each item in the array and return the array
    else if rule instanceof Array
      Rule.parse item, data, selection for item in rule
    # Pass the data to the rule object, if the rule object
    # does not have a template then use the current selection
    # and apply changes directly to it. Return undefined in that case so
    else if rule instanceof Rule
      if rule.template?
        rule.render data
      else
        rule.render data, selection
        return undefined
    # Return objects that can be added to the dom directly as is
    # If null or undefined return as is to be ignored
    else if rule instanceof Node or !rule?
      rule
    else if $.fn.isPrototypeOf(rule)
      if rule.length is 1 then rule.get(0) else rule.get()
    # If the object has a custom toString then use it
    else if rule.toString isnt Object::toString
      rule.toString()
    # If the object does not have a custom toString
    # create a new rule from the object
    else if Object::isPrototypeOf rule
      Rule.parse (new Rule rule), data, selection

  # Add a content object to a selection or attribute
  # of a selection at the position specified
  @add: (content, selections, attribute, position) ->
    return selections if not (content?)
    # Attribute is specified, so modify attribute
    if attribute
      for selection in selections
        content = content.join('') if content instanceof Array
        previous = (selection.getAttribute attribute) ? ''
        selection.setAttribute attribute,
          if position is '-' then content + previous
          else if position is '+' then previous + content
          else content
      return selections
    # Attribute not specified so modify selected element
    else
      result = []
      for selection in selections
        # Add the content to various positions
        parent = target = selection
        if position is '-'
          parent = selection.parentElement
        else if position is '+'
          parent = selection.parentElement
          target = selection.nextSibling
        else if position is '='
          parent = selection.parentElement
        else if position is '<'
          target = selection.firstChild
        else if position is '>'
          target = null
        else
          selection.removeChild selection.firstChild while selection.firstChild?
          target = null
        # Concatenate array content into one object
        content = [content] if !(content instanceof Array)
        for element in content
          element = if !(element instanceof Node) then document.createTextNode element else element.cloneNode(true)
          result.push selection if position is '+'
          result.push element
          result.push selection if position is '-'
          if parent instanceof HTMLElement
            parent.insertBefore element, target
        parent?.removeChild target if position is '='
      return if position in ['-', '+', '='] then result else selections

  # Parse the selector for selection, position and attribute
  @split: (selector) ->
    position = selector[-1...]
    position = undefined if position isnt '-' and position isnt '+' and position isnt '=' and position isnt '<' and position isnt '>'
    # Splits selector[@][-<=>+] to selector, position = selector[@], [-<=>+]
    selector = selector[0...-1] if position?
    [selector, attribute] = selector.split('@', 2)
    selector = undefined if selector is ''
    [selector, attribute, position]