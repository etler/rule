itemRule = new Rule
  '.content': ->@a ? @b ? @c ? 'default'

listRule = new Rule
  '.': ->itemRule.build item for item in @list

rule = new Rule
  '.name':
    '.first': ->@first
    '.last': ->@last