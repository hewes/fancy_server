require "fancy_server/rest_server.rb"
require "ostruct"

describe FancyServer::RestServer::Handler do
  let(:handler){FancyServer::RestServer::Handler.new}

  class ContextMock
    def initialize(method, uri, params = {}, headers = {})
      @params = {}
      @request = OpenStruct.new(:request_method => method, :path => uri, :params => params, :headers => headers)
    end
    attr_reader :params, :request
  end

  describe "#process" do
    subject{handler.process(context)}

    describe "match" do
      let(:process_result){1}

      before do
        handler.get("/foo/:id", process_result)
        handler.get("/foo", process_result)
      end

      describe "path is static" do
        let(:context){ContextMock.new(:get, "/foo")}

        it {is_expected.to be process_result}
      end

      describe "path contains parameter" do
        let(:context){ContextMock.new(:get, "/foo/1")}

        it {is_expected.to be process_result}
      end
    end

    describe "undefined method" do
      let(:context){ContextMock.new(:invalid_method, "/not/found")}
      it {is_expected.to be 404}
    end

    describe "no route match" do
      let(:context){ContextMock.new(:get, "/not/found")}
      it {is_expected.to be 404}
    end

    describe "http methods" do
      [:put, :post, :delete].each_with_index do |method, i|
        describe method do
          before do
            handler.send(method, "/foo", i)
          end
          let(:context){ContextMock.new(method, "/foo")}
          it {is_expected.to be i}
        end
      end
    end
  end
end

