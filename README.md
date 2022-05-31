
this is jekyll plugin for no-style-please2 theme

## Feature
 + tag support， this plugin will create tag page if you add tags in your post
 + liquid tags 
   + post_link ,link to post via title
   + img_link ,link to a image
   + asset_img insert a picture into the post content
 + encryption support. encrypt the post content. you can set password for tag, or set a password in the post front matter. password will be encrypted by ECC cryption.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add no-style-please2-plugins

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install no-style-please2-plugins

## Usage

see this [demo](https://vitock.ink/no-style-please-demo/)

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vitock/no-style-please2-plugins.
