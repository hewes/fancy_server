# FancyServer

FancyServer is library for building mock server.
Enable to build mock server with less procedure.

## Installation

Add this line to your application's Gemfile:

    gem 'fancy_server'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fancy_server

## Usage

### build http server with REST API

FancyServer uses [Rack](http://rack.github.io/) and WEBrick for building http server.
Example for building simple http server with REST API.

    require "fancy_server/rest_server"

    handler = FancyServer::RestServer::Handler.new
    handler.get('/', "this is top")
    handler.get('/foo/:bar') do
      "specified parameter for :bar is #{params[:bar]}"
    end
    server = FancyServer::RestServer.create(handler)
    server.run
    # In default, server runs at http://0.0.0.0:8080. When specify option (same as WEBRick option) to server#run
    # When access http://localhost:8080/, response with status 200, body is "this is top"
    # When access http://localhost:8080/foo/test, response with status 200, body is "specified parameter for :bar is test}"

## Contributing

1. Fork it ( http://github.com/hewes/fancy_server/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
