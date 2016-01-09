# Rule v0.2.12
# templating library
# http://rulejs.com
# http://github.com/etler/rule
#
# Copyright 2014, Tim Etler (tmetler@gmail.com)
# Licensed under the MIT or GPL Version 2 licenses.

class Rule
  # Build a new Rule with a rule object and optional template
  constructor: (rule, template) ->
    @rule = rule if rule
    @template = template if template

  # Apply a rule to a cloned template, taking data that is passed to rule functions
  # Optionally takes an element and applies modifications directly to that element
  render: (data, parent) ->
    env = @constructor.env or Rule.env
    # Insures optional passed in parent element is an array of Nodes
    parent = toElementArray parent
    # Set parent to a copy of the template if it is not already set
    if !parent
      parent = (subparent.cloneNode true for subparent in toElementArray @template)
    # scope is used to encapsulate any content added outside of the parent
    # parent array is duplicated
    scope = parent[0..]
    # If the object property 'rule' is set, do not use the inherited rules
    if @hasOwnProperty 'rule'
      rules = @rule
    else
      rules = combineRules @
    for key, rule of rules
      # Apply each rule to each parent object.
      # Applied to a copy of parent because parent may change during application
      for subparent in parent[0..]
        continue if subparent not instanceof env.Element
        [selector, attribute, position] = @constructor.split key
        # Empty selector selects the parent as an array
        if selector?
          if simpleSelector = toSimpleTag(selector)
            selection = (element for element in subparent.getElementsByTagName(simpleSelector))
          else if simpleSelector = toSimpleClass(selector)
            selection = (element for element in subparent.getElementsByClassName(simpleSelector))
          else if subparent.querySelectorAll?
            selection = (element for element in subparent.querySelectorAll selector)
          else
            selection = (element for element in querySelectorAll.call subparent, selector)
        else
          selection = [subparent]
        # Add will return the selection and sibling elements
        generator = (selector) =>
          # A singular rule failing should not crash the entire program
          try
            @constructor.parse rule, data, selector, @
          catch error
            console.error 'RuleError: ', error.stack
            # If there is an error, we want to skip it, so return undefined
            return
        result = @constructor.add generator, selection, attribute, position
        # If we are manipulating the parent and siblings update scope and
        # parent to reflect change in top level structure
        if !selector? and result.length
          scope.splice (indexOf.call scope, subparent), 1, result...
          parent.splice (indexOf.call parent, subparent), 1, result... if position is '='
    return scope

  # Parse the rule to get the content object
  @parse: (rule, data, selector, context) ->
    env = @constructor.env or Rule.env
    # Bind the function to the data and current selector and parse its results
    if rule instanceof Function
      @parse (rule.call data, selector, context), data, selector, context
    # Parse each item in the array and return a flat array
    else if rule instanceof Array
      result = []
      result = result.concat (@parse item, data, selector, context) for item in rule
      return result
    # Pass the data to the rule object, if the rule object
    # does not have a template then use the current selector
    # and apply changes directly to it.
    # Return undefined in that case so it is not added twice.
    else if rule instanceof Rule
      if rule.hasOwnProperty 'template'
        rule.render data
      else
        rule.render data, selector.selection
        return undefined
    # Return objects that can be added to the dom directly as is
    # If null or undefined return as is to be ignored
    else if rule instanceof env.Node or !rule?
      rule
    # A helper case for jQuery style objects.
    else if env.$?.fn.isPrototypeOf(rule)
      rule.get()
    # If the object has a custom toString then use it
    else if rule.toString isnt Object::toString
      rule.toString()
    # If the object does not have a custom toString
    # create a new rule from the object
    else if Object::isPrototypeOf rule
      newRule = (new @ rule)
      newRule.parent = context
      @parse.call @, newRule, data, selector, context

  # Add a content object to an array of selection or attributes
  # of the selections at the position specified
  # Returns the selections and any siblings as an array of Nodes
  @add: (generator, selections, attribute, position) ->
    env = @constructor.env or Rule.env
    result = []
    # Make sure content generator is always a generator
    if !(generator instanceof Function)
      # The generator value is bound so the value within the closure
      # will not be overwritten
      generator = ((value) -> value).bind(@, generator)
    for selection in selections
      content = generator
        selection: selection
        attribute: attribute
        position: position
      # Nothing to do here
      continue unless content? and selection instanceof env.Element
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
            if !(element instanceof env.Node) then env.document.createTextNode element else element
          # Add selection either before or after in the right order
          result.push selection if position is '+'
          result.push element
          result.push selection if position is '-'
          # Parent must be an HTMLElement to insure we can add to it
          # We can assume parent is a Node, but not all Nodes can be added too
          if parent instanceof env.HTMLElement
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

  # Compatibility fallbacks for certain browsers that don't support indexOf and querySelectorAll
  indexOf = Array::indexOf ? (item) ->
    for value, index in @
      if index of @ and value is item
       return index
      return -1
  querySelectorAll = ((query) ->
    env = @constructor.env or Rule.env
    # Hack to support IE8, does not support accessing DOM constructors
    querySelectorAll = env.document.createElement('div').querySelectorAll ? (query) -> ((env.$ @).find query).get()
    querySelectorAll(query)
  ).bind(@)
  # Shim to support IE8, does not support getObjectPrototype
  getPrototypeOf = Object.getPrototypeOf ? (object) ->
    prototype = object.constructor.prototype
    # Someone has put a constructor property on an object instance.
    # How dumb.
    # (Even dumber is if someone overwrote the prototype's constructor
    #  property, but you can also overwrite Object.getPrototypeOf, so we
    #  can only handle so much.)
    if (object.hasOwnProperty 'constructor' and object isnt prototype) or
        # Or object is already the prototype
        object is prototype
      # If the object is currently the prototype, delete its constructor to
      # expose the prototype's prototype's constructor which contains the
      # prototype's prototype. Then put the constructor back where it was.
      constructor = object.constructor
      delete object.constructor
      prototype = object.constructor.prototype
      object.constructor = constructor
    return prototype
  # Converts a single Node object, or a jQuery style object
  # object to a javascript array of Node objects
  toElementArray = ((element) ->
    env = @constructor.env or Rule.env
    # Using $.fn instead of instanceof $ because zepto does not support latter
    if env.$?.fn.isPrototypeOf(element)
      element.get()
    else if element instanceof Function
      toElementArray do element
    else if element instanceof env.Node
      [element]
    else element
  ).bind(@)

  # A recursive function to combine all prototype rules so they are
  # applied with the oldest prototype rules first.
  combineRules = (object) ->
    if (object.hasOwnProperty 'constructor') and (object.constructor is Rule)
      return {}
    rules = combineRules getPrototypeOf object
    if object.hasOwnProperty 'rule'
      for key, rule of object.rule
        delete rules[key]
        rules[key] = rule
    return rules

  toSimpleClass = (selector) ->
    if selector[0] isnt '.'
      return false
    selector = selector[1..]
    for character, index in selector
      if character in [' ', ',', '[', ']', '#', '*', ':', '>', '+', '~', '(', ')']
        return false
      else if character is '.'
        selector = selector.replace '.', ' '
    return selector

  toSimpleTag = (selector) ->
    firstCharCode = selector.charCodeAt(0)
    # Valid tag string first char must match [a-zA-Z_]
    unless 65 <= firstCharCode <= 90 or 97 <= firstCharCode <= 122 or firstCharCode is 95
      return false
    for index in [1...selector.length]
      charCode = selector.charCodeAt(index)
      unless 65 <= charCode <= 90 or 97 <= charCode <= 122 or 48 <= charCode <= 57 or charCode in [45, 95]
        return false
    return selector

# Test if the javascript environment is node, or the browser
# In node module is defined within the global closure,
# but 'this' is an empty object
if module? and @module isnt module
  module.exports = Rule
else
  window.Rule = Rule

return Rule
