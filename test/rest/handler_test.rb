require "test/unit"
require "fancy_server/rest_server.rb"

class RestServerTest
  class ContextMock
    def initialize(method, uri, params = {}, headers = {})
      @params = {}
      @request = Struct.new(:request_method => method, :path => uri, :params => params, :headers => headers)
    end

    class Struct
      def initialize(hash = {})
        hash.each do |key, value|
          (class << self;self;end).send(:define_method, key){value}
        end
      end
    end
    attr_reader :params, :request
  end

  class HandlerTest < Test::Unit::TestCase
    def setup
      @handler = FancyServer::RestServer::Handler.new
    end

    def test_get_method_routing
      @handler.get("/foo", 1)
      context = ContextMock.new(:get, "/foo")
      assert_equal(1, @handler.process(context))
    end

    def test_parameter_path
      @handler.get("/foo/:id", 1)
      context = ContextMock.new(:get, "/foo/1")
      assert_equal(1, @handler.process(context))
    end

    def test_http_methods
      val = 0
      [:put, :post, :delete].each do |method|
        @handler.send(method, "/foo", val += 1)
        context = ContextMock.new(method, "/foo")
        assert_equal(val, @handler.process(context))
      end
    end
  end
end

