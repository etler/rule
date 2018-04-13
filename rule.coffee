# Rule v1.0.3
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
    # Set parent to a copy of the template if it is not already set
    # Normalize to ensure parent is a DOM Element
    if parent
      parent = normalizeElement(parent)
    else
      parent = normalizeElement(@template).cloneNode(true)
    # Pre-calculate classes to dictionary for fast lookup
    lookup = splatify(parent, {})
    # If the object property 'rule' is set, do not use the inherited rules
    if @hasOwnProperty 'rule'
      rules = @rule
    else
      rules = combineRules @
    for key, rule of rules
      # Apply each rule to the parent object.
      [selector, attribute, position] = @constructor.split key
      # Lookup tag names are stored as uppercase strings
      if selector and selector[0] not in ['#', '.']
        selector = selector.toUpperCase()
      # Match selector string to css lookup table
      if selector
        selection = lookup[selector] or []
        # Need to iterate backwards so splice does not invalidate array bounds
        for index in [selection.length - 1..0] by -1
          value = selection[index]
          # Remove child from selection if it was removed
          if not isChildOf(parent, value)
            selection.splice(index, 1)
      # Empty selector selects the parent as an array
      else
        selection = [parent]
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
    return parent

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
  # object to a javascript Node object
  normalizeElement = ((element) ->
    env = @constructor.env or Rule.env
    # Using $.fn instead of instanceof $ because zepto does not support latter
    if env.$?.fn.isPrototypeOf(element)
      element.get(0)
    else if element instanceof Function
      normalizeElement do element
    else if element[0]
      element[0]
    else
      element
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

  # Convert an element tree into a dictionary of classes that reference the
  # child elements within the tree
  splatify = (element, hash = {}) ->
    child = element.firstElementChild
    while (child)
      # If no class name you can skip setting up the dictionary
      if child.getAttribute('class') isnt ''
        for elementKey in child.getAttribute('class').split(' ')
          elementKey = '.' + elementKey
          # Check existing dictionary array
          elementArray = hash[elementKey] ? hash[elementKey] = []
          # Push is used for speed
          elementArray.push(child)
      # Index id
      if (child.id isnt '')
        elementKey = '#' + child.id
        elementArray = hash[elementKey] ? hash[elementKey] = []
        elementArray.push(child)
      # Index tag names
      elementKey = child.tagName
      elementArray = hash[elementKey] ? hash[elementKey] = []
      elementArray.push(child)
      # Recurse
      splatify(child, hash)
      # Use nextElementSibling for browser speed optimization
      child = child.nextElementSibling
    return hash

  isChildOf = (parent, child) ->
    nextParent = child
    while nextParent = nextParent.parentElement
      return true if nextParent is parent
    return false

# Check if the javascript environment is node, or the browser
# In node module is defined within the global closure,
# but 'this' is an empty object
if module? and @module isnt module
  module.exports = Rule
else
  window.Rule = Rule

return Rule
