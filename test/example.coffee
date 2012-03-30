$ ->
  console.time('simple')
  simple = new Rule
    '.content': ->@content

  simple.render
    content: 'simple',
    $ '.simple'
  console.timeEnd('simple')


  console.time('book')
  book = new Rule
    '.title': ->@title
    '.author':
      '.name':
        '.first': ->@author.first
        '.last': ->@author.last

  book.render
    title: 'The Hobbit'
    author:
      first: 'J. R. R.'
      last: 'Tolkien',
    $ '.book'
  console.timeEnd('book')


  console.time('list')
  itemRule = new Rule
    '.content': ->@content ? 'default',
    $ '.list li'
  listRule = new Rule
    '': ->itemRule.render item for item in @list

  listRule.render
    list: [{content: 'hello'}, {content: 'world'}, {}],
    $ '.list'
  console.timeEnd('list')


  console.time('recursive')
  recursive = new Rule
    '.location': ->@location
    '>': ->if @list then recursive.render item for item in @list else ''
    $ '.recursive'

  recursive.render
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
    $ '.recursive'
  console.timeEnd('recursive')