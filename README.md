# layout

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
screen.width = 100f64
screen.height = 300f64
screen.x = 0f64
screen.y = 0f64

top_block = Layout::Block.new
top_block.height = 50f64

bottom_block = Layout::Block.new

screen.children = [top_block, bottom_block]

Layout.solve(screen)

# go use the calculated dimensions!
bottom_block.height.value # => 250f64
```

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
