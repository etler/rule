itemRule = new Rule
  '.content': ->@a ? @b ? @c ? 'default'

rule = new Rule
  '.': ->itemRule.build item for item in @list