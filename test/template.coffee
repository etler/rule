simple = new Rule
  '.content': ->@content

# Embedded Object Example
book = new Rule
  '.title': ->@title
  '.author':
    '.name':
      '.first': ->@author.first
      '.last': ->@author.last



# Iteration Example
itemRule = new Rule
  '.content': ->@a ? @b ? @c ? 'default'

listRule = new Rule
  '.': ->itemRule.build item for item in @list

# Recursion Example
recursive = new Rule
  '.location': ->@location
  '.list=': ->if @list then recursive.build item for item in @list