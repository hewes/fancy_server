require "rack"
require "fancy_server"
require "fancy_server/path_router"

module FancyServer
  class RestServer

    # create new http Server for rest
    # @arg handler [FancyServer::RestServer::Handler] request handler
    # @return [HFancyServer::RestServer::ttpServer] new http server
    def self.create(handler)
      Class.new(HttpServer) do |c|
        @handler = handler
      end
    end

    class HttpServer
      class << self

        # @return [Rack::Response]
        def call(env)
          context = HandlerContext.new(env)
          processed = @handler.process(context)
          context.update_response(processed)
          context.response
        end

        def run(options = {})
          Rack::Handler::WEBrick.run(self, options)
        end

        def shutdown_with_signal(*signals)
          signals.each do |signal|
            Signal.trap(signal) do
              Rack::Handler::WEBrick.shutdown
            end
          end
        end
      end
    end

    class HandlerContext
      def initialize(env)
        @request  = Rack::Request.new(env)
        @params   = @request.params.dup
        @request_body = @request.env['rack.input'].read
        @response = Rack::Response.new()
      end
      attr_reader :request, :params, :response, :request_body

      # update response information with specified value
      # @arg processed [Integer, String, Array<Integer, Hash, String>] 
      #                 http status code or
      #                 http rsponse body or
      #                 response status code and response headers and response body
      def update_response(processed)
        case processed
        when Integer then response.status = processed
        when String,NilClass then response.body << processed.to_s
        when Array
          response.status = processed[0].to_i
          if response.respond_to?(:headers=)
            response.headers = processed[1]
          else
            processed[1].each do |key, value|
              response[key] = value
            end
          end
          response.body = processed[2].respond_to?(:each) ? processed[2] : [processed[2]]
        when Hash
          response.status = processed[:status].to_i if processed.key?(:status)
          response.headers.update(processed[:headers]) if processed.key?(:headers)
          response.body = processed[:body].respond_to?(:each) ? processed[:body] : [processed[:body]] if processed.key?(:body)
        end
      end

      # helper method to return http status 200 and any body
      def ok(body = "")
        [200, {}, body]
      end
    end

    # request handler
    # call following methods to register request processor
    # - post
    # - get
    # - put
    # - delete
    # see HandlerContext for helper methods in processor
    class Handler
      def initialize
        @processor_map = {}
        self.class.capable_methods.each do |http_method|
          @processor_map[http_method] = PathRouter.new('/')
        end
      end

      @capable_methods = []

      class << self
        attr_reader :capable_methods

        private
        def define_http_method(method)
          @capable_methods << method
          define_method(method) do |uri, val = nil, &bk|
            @processor_map[method].register(uri, val, &bk)
          end
        end
      end

      define_http_method :get
      define_http_method :put
      define_http_method :delete
      define_http_method :post

      # process http request
      # 1. routing with registered route using request method and uri.
      # 2. When route is found registred handler processes request and returns the result,
      #    otherwise returns 404.
      # @arg env [HandlerContext]
      # @return [Integer] http response Status Value. ex)200
      # @return [String] http response Body. http response status code is 200.
      # @return [Array<Integer,Hash,String>] [http response Status Value, Headers, Body]
      def process(context)
        request = context.request

        router = @processor_map[request.request_method.downcase.to_sym]
        return 404 unless router
        begin
          processor, params = router.routing(request.path)
        rescue FancyServer::PathRouter::NoRouteMatched
          return 404
        rescue FancyServer::PathRouter::DestinationDuplicated => ex
          return {:status => 503, :body => ex.message}
        end
        return 404 unless processor
        context.params.merge!(params)
        processor.respond_to?(:to_proc) ? context.instance_eval(&processor) : processor
      end
    end
  end
end

