require 'spec_helper'

describe "Pages" do
  describe "GET /pages" do
    it "should be OK with status 200" do
      get pages_path
      response.status.should be(200)
    end
  end
end
