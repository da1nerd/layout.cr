# layout
[![GitHub release](https://img.shields.io/github/release/da1nerd/layout.cr.svg)](https://github.com/da1nerd/layout.cr/releases)
[![Build Status](https://travis-ci.org/da1nerd/layout.cr.svg?branch=main)](https://travis-ci.org/da1nerd/layout.cr)

This is a constraint based layout framework. Or more simply put, this generates the measurements for a visual layout which could then be used for:

* Positioning things on a PDF
* Drawing objects in a UI toolkit

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  layout:
    github: da1nerd/layout.cr
```

2. Run `shards install`

## Usage

```crystal
require "layout"

screen = Layout::Block.new
screen.width.eq 300
screen.height.eq 300

top_block = Layout::Block.new
top_block.height.eq 100
top_block.width.eq screen.width

bottom_block = Layout::Block.new
bottom_block.top.eq top_block.bottom
bottom_block.width.eq screen.width
bottom_block.bottom.eq screen.bottom

screen.children = [top_block, bottom_block]

Layout.solve(screen)

# go use the calculated dimensions!
bottom_block.height.value # => 200
```

With the above code you'd have all the necessary dimensions to draw this stack of blocks.

![image](https://user-images.githubusercontent.com/166412/95360139-2ecb0980-08f5-11eb-9b1a-d8bf144d52d7.png)

> Note: there's nothing special about `screen.children = [top_block, bottom_block]`
This simply combines the blocks into a single one so we can easily pass it to the solver.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/da1nerd/layout.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Joel Lonbeck](https://github.com/da1nerd) - creator and maintainer
