
module FancyServer
  class PathRouter

    def initialize(delimiter)
      @delimiter = delimiter
      @routes = {}
    end

    def register(format, val = nil, &bk)
      raise DestinationDuplicated.new if val && bk
      path = format.split(@delimiter, -1)

      param_pattern = path.find_all do |pat|
        pat =~ /^:(.+)$/
      end
      raise ParamPatternDuplicated.new if param_pattern.uniq!
      @routes[path] = val || bk
    end

    # @return [Array<Proc, Hash>] [routing desitination, parameter bindings]
    # @raise [NoRouteMatched] specified path not match any routes
    # @raise [PathDuplicated] some routes match specified path
    def routing(path)
      matched = []

      splited = path.split(@delimiter, -1)
      @routes.each do |route, val|
        next unless splited.size == route.size
        params = matched_params(route, splited)
        next unless params
        matched << [route, val, params]
      end

      case matched.size
      when 0 then raise NoRouteMatched.new("#{path} does not match any routes")
      when 1 
        matched.first[1..2]
      else
        msg = matched.map{|i| i.first}.join(', ')
        raise PathDuplicated.new("path:#{path} matched #{msg}") if matched.size > 1
      end
    end

    private
    def matched_params(route, splited)
      params = {}
      route.zip(splited) do |pat, s|
        if pat =~ /^:(.+)$/
          return nil if s.empty?
          params[$1.to_sym] = s
        else
          return nil unless pat === s
        end
      end
      return params
    end

    class DestinationDuplicated < Exception;end
    class PathDuplicated < Exception;end
    class ParamPatternDuplicated < Exception;end
    class NoRouteMatched < Exception;end
  end
end
