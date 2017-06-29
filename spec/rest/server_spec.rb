require "fancy_server/rest_server.rb"
require "rack/test"

describe "server" do
  let(:handler){FancyServer::RestServer::Handler.new}
  let(:browser){Rack::Test::Session.new(Rack::MockSession.new(FancyServer::RestServer.create(handler)))}

  subject{[browser.last_response.status, browser.last_response.body]}

  shared_examples "responder" do |code, body = ""|
    it {is_expected.to eq [code, body]}
  end

  describe "get root" do
    before do
      handler.get("/", 503)
      browser.get "/"
    end
    it_behaves_like "responder", 503
  end

  describe "get" do
    describe "with query_param" do
      before do
        handler.get("/"){params["foo"]}
        browser.get "/?foo=bar"
      end
      it{ is_expected.to eq [200, "bar"]}
    end

    describe "with uri_param" do
      before do
        handler.get("/:foo"){params[:foo]}
        browser.get "/bar"
      end
      it_behaves_like "responder", 200, "bar"
    end

    describe "with query_param and uri_param" do
      before do
        handler.get("/foo/:bar") do
          params[:bar].to_s + params["hoge"].to_s
        end
        browser.get "/foo/test?hoge=fuga"
      end

      it_behaves_like "responder", 200, "testfuga"
    end
  end

  describe "not found" do
    before do
      browser.get "/foo/test"
    end
    it_behaves_like "responder", 404
  end

  describe "post" do
    describe "with body" do
      before do
        handler.post("/foo/:bar") do
          [201, {"Key": "Value"}, "#{params[:bar]}:#{request_body}"]
        end
        browser.post "/foo/foobar", "this is body"
      end
      it_behaves_like "responder", 201, "foobar:this is body"
      it{
        expect(browser.last_response.headers).to eq (
          {"Content-Length" => "foobar:this is body".bytesize.to_s, :Key => "Value"}
        )
      }
    end
  end
end

