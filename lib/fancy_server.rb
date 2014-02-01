require "fancy_server/version"

module FancyServer
  def self.create_rest_server(handler, params = {})
    logger = params[:logger] || $stderr
    FancyServer::RestServer.create(handler)
  end
end
