require "test/unit"
require "fancy_server/path_router.rb"

class PathRouterTest < Test::Unit::TestCase
  def setup
    @router = FancyServer::PathRouter.new('/')
  end

  def test_one_depth_path
    @router.register('/foo', 1)
    assert_equal([1, {}], @router.routing('/foo'))
  end

  def test_two_depth
    @router.register('/foo/bar', 2)
    assert_equal([2, {}], @router.routing('/foo/bar'))

    @router.register('/foo/bar/', 3)
    assert_equal([3, {}], @router.routing('/foo/bar/'))
  end

  def test_param_binding
    @router.register('/foo/bar/:id', 2)
    assert_equal([2, {:id => "1"}], @router.routing('/foo/bar/1'))

    @router.register('/foo/:bar/:hoge', 3)
    assert_equal([3, {:bar => "2", :hoge => "1"}], @router.routing('/foo/2/1'))
  end

  def test_register_value_and_block
    assert_raise(FancyServer::PathRouter::DestinationDuplicated) do
      @router.register('/foo/bar/:hoge', 2){"block"}
    end
  end

  def test_register_block
    @router.register('/foo/bar/:hoge'){"block"}
    found, params = @router.routing('/foo/bar/test')
    assert_equal("block", found.call)
    assert_equal({:hoge => "test"}, params)
  end

  def test_register_path_twice
    @router.register('/foo/bar', 1)
    @router.register('/foo/bar', 2)
    assert_equal([2, {}], @router.routing('/foo/bar'))
  end

  def test_path_not_found
    assert_raise(FancyServer::PathRouter::NoRouteMatched) do
      @router.routing('/bar')
    end

    @router.register('/foo/bar/:hoge', 2)
    assert_raise(FancyServer::PathRouter::NoRouteMatched) do
      puts @router.routing('/foo/bar/')
    end

    @router.register('/foo', 2)
    assert_raise(FancyServer::PathRouter::NoRouteMatched) do
      @router.routing('/foo/')
    end
  end
end
