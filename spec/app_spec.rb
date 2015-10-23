require File.expand_path '../spec_helper.rb', __FILE__

describe "App" do

  it "serve homepage on index" do
    get '/'
      expect(last_response).to be_ok
  end
end

