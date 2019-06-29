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

### Add aws-s3 source to your Gemfile

In your Gemfile, add a source like this:

```ruby
source('s3://my-bucket/gems', type: 'aws-s3') do
  gem 'my-cool-gem'
end
```

When Bundler sees the `type: 'aws-s3'` it will automatically install and use
this plugin to install gems from your s3 source.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/eki/bundler-source-aws-s3.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
