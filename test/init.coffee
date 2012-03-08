$ ->

  listRule.bind $ '#template .list'
  itemRule.bind $ '#template .item'

  ($ 'body').append listRule.build
    list: [{c: 'hello'}, {b: 'world'}, {}]

  rule.bind $ '#template .person'

  ($ 'body').append rule.build
    first: 'tim'
    last: 'etler'