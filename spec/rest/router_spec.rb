require "fancy_server/path_router.rb"

describe FancyServer::PathRouter do
  let(:router){FancyServer::PathRouter.new('/')}

  describe "#resiter" do
    describe "both value and block" do
      it{
        expect{
          router.register('/foo/bar/:hoge', 2){"block"}
        }.to raise_error FancyServer::PathRouter::DestinationDuplicated
      }
    end

    describe "twice" do
      before do
        router.register('/foo/bar', 1)
        router.register('/foo/bar', 2)
      end

      it { expect(router.routing('/foo/bar')).to eq [2, {}] }
    end
  end

  describe "#routing" do
    subject{router.routing(route)}

    describe "one depth path" do
      let(:route){'/foo'}

      before{router.register(route, 1)}
      it{ is_expected.to eq [1, {}]}
    end

    describe "two depth path" do
      let(:route){'/foo/bar'}

      before{router.register(route, 2)}
      it{ is_expected.to eq [2, {}]}
    end

    describe "param binding" do
      let(:route){'/foo/3'}

      before{router.register("/foo/:id", 3)}
      it{ is_expected.to eq [3, {id: "3"}]}
    end

    describe "longest match path" do
      let(:route){'/foo/bar/3'}

      before{
        router.register("/foo", 1)
        router.register("/foo/:id", 2)
        router.register("/foo/bar/:id", 3)
      }
      it{ is_expected.to eq [3, {id: "3"}]}
    end

    describe "register block" do
      let(:route){'/foo/bar/test'}
      before do
        router.register('/foo/bar/:hoge'){"block"}
      end
      it {
        expect(subject[0].call).to eq "block"
        expect(subject[1]).to eq ({:hoge => "test"})
      }
    end

    describe "path not found" do
      describe "no path defintion" do
        let(:route){'/foo/bar/3'}
        it{ expect{subject}.to raise_error(FancyServer::PathRouter::NoRouteMatched)}
      end

      describe "param path not match null" do
        let(:route){'/foo/bar/'}
        before do
          router.register('/foo/bar/:hoge', 2)
        end
        it{ expect{subject}.to raise_error(FancyServer::PathRouter::NoRouteMatched)}
      end

      describe "/foo/bar/ not match /foo/bar" do
        let(:route){'/foo/bar/'}
        before do
          router.register('/foo/bar', 2)
        end
        it{ expect{subject}.to raise_error(FancyServer::PathRouter::NoRouteMatched)}
      end

      describe "/foo/bar not match /foo/bar/" do
        let(:route){'/foo/bar'}
        before do
          router.register('/foo/bar/', 2)
        end
        it{ expect{subject}.to raise_error(FancyServer::PathRouter::NoRouteMatched)}
      end
    end
  end
end

