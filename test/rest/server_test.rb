require "test/unit"
require "rack/test"
require "fancy_server/rest_server.rb"

class RestServerTest
  class ServerTest < Test::Unit::TestCase
    def setup
      @handler = FancyServer::RestServer::Handler.new
      server = FancyServer::RestServer.create(@handler)
      @browser = Rack::Test::Session.new(Rack::MockSession.new(server))
    end
    attr_reader :handler, :browser

    def test_get_root
      handler.get("/", 503)
      browser.get "/"
      assert_equal(503, browser.last_response.status)
    end

    def test_get_with_query_param_and_uri_param
      handler.get("/foo/:bar") do
        params[:bar].to_s + params["hoge"].to_s
      end
      browser.get "/foo/test?hoge=fuga"
      assert_equal(200, browser.last_response.status)
      assert_equal("testfuga", browser.last_response.body)
    end

    def test_get_with_uri_param
      handler.get("/foo/:bar") do
        params[:bar].to_s
      end
      browser.get "/foo/test"
      assert_equal(200, browser.last_response.status)
      assert_equal("test", browser.last_response.body)
    end

    def test_not_exist_path
      browser.get "/foo/test"
      assert_equal(404, browser.last_response.status)
    end
  end
end
