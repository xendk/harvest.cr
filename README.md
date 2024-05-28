# Harvest.cr

Minimal client for the Harvest time tracing service, developed for Combine.

Note: Currently only tested with the "Timer mode" company preference
set to "Track time via duration". If you're using "Track time via
start and end time", you'll have to test thoroughly.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     harvest:
       github: xendk/harvest.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "harvest"
```

Basic usage:

```
harvest = Harvest.new(account_id, token)
pp harvest.time_entries(from: from_date, to: to_date)
```

See `src/cli.cr` for an small example. It can be built with `shards
build` and is handy for testing.

## Contributing

1. Fork it (<https://github.com/xendk/harvest/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Thomas Fini Hansen](https://github.com/xendk) - creator and maintainer
