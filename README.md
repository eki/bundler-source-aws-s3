# Bundler-Source-Aws-S3

This is a bundler plugin which adds support for s3 as a source for gems.

## Installation

### Setup the aws cli

There are multiple ways to [install the aws
cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
(including [homebrew](https://formulae.brew.sh/formula/awscli)). This plugin
will use the aws cli to pull gems from your s3 source. There is an expectation
that if you want to use s3 as a gem source, you'll probably already have this
installed.

### Setup s3 as a gem source

First, you should already have gems in s3 and you should be able to install
them with Rubygems. Follow the [guide for using s3 as a gem
source](https://guides.rubygems.org/using-s3-source/).

For this plugin to work the aws cli should be able to fetch your gems. The
plugin will run a command like `aws s3 sync s3://your-source <local path>` and
you may want to verify that you have aws cli setup correctly (permissions,
etc) to be able to run that command.

### Add aws-s3 source to your Gemfile

In your Gemfile, add a source like this:

```ruby
plugin 'bundler-source-aws-s3'

source 's3://my-bucket/gems', type: 'aws-s3' do
  gem 'my-cool-gem'
end
```

For libraries, it can be normal to declare your dependencies in your gemspec
file. In those cases, your Gemfile will normall be mostly empty. You can still
use your s3 sourced gems in your gemspec if you add the plugin and source to
your Gemfile. For example:

```ruby
# In your gemspec you might have some dependencies like:

spec.add_development_dependency 'private-gem-in-my-s3'
spec.add_dependency 'another-private-gem-in-s3'

# And, your Gemfile would contain:

plugin 'bundler-source-aws-s3'

source 'https://rubygems.org'
source 's3://my-super-private-bucket-of-gems', type: 'aws-s3' do
  # It's okay to leave this empty. Unfortunately, bundler currently requires
  # the block for sources which have a `type`.
end

gemspec
```

## Development

We don't have a very good development story (there are no tests, yay!). You'll
want to fork this repository and use your own fork by adding this to a
`Gemfile` that you plan to use to test your fork:

```ruby
plugin 'bundler-source-aws-s3', git: 'https://github.com/<you>/bundler-source-aws-s3.git'
```

You may also want to wipe a few directories out as you test:

```
rm -rf ./.bundle/plugin
rm -rf ~/.bundle/bundler-source-aws-s3
```

You may also want to wipe out the `install_path` for the s3 uri you're testing
against. You can find that in irb by instantiating your plugin like:

```ruby
>> BundlerSourceAwsS3::S3Source.new(uri: 's3://vying-gems').send(:install_path)
```

Although this will only work if you're running irb in a directory with a
Gemfile and a `.bundle/` directory. These can be empty as of this writing.

It can also help to poke at the plugin in irb:

```
irb -I . -r bundler -r plugins.rb
```

## Other s3 source plugins

As of this writing there is another gem called
[bundler-source-s3](https://rubygems.org/gems/bundler-source-s3) that doesn't
work and you probably don't want to confuse with this gem. If you use type 's3'
(instead of 'aws-s3') in your Gemfile you'll get that plugin, not this one.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/eki/bundler-source-aws-s3.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
