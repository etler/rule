$ ->
  simple.bind $ '#template > .simple'
  ($ 'body').append simple.build
    content: 'test'

  book.bind $ '#template > .book'

  ($ 'body').append book.build
    title: 'The Hobbit'
    author:
      first: 'J. R. R.'
      last: 'Tolkien'

  listRule.bind $ '#template > .list'
  itemRule.bind $ '#template > .list > .item'

  ($ 'body').append listRule.build
    list: [{c: 'hello'}, {b: 'world'}, {}]

  recursive.bind $ '#template > .recursive'

  ($ 'body').append recursive.build
    location: 'USA'
    list:
      [
        {
          location: 'California'
          list:
            [
              { location: 'San Diego' }
              { location: 'San Francisco' }
              { location: 'San Jose' }
            ]
        }
        {
          location: 'Nevada'
          list:
            [
              { location: 'Reno' }
              { location: 'Las Vegas' }
            ]
        }
      ]