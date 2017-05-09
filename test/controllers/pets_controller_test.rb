require 'test_helper'

class PetsControllerTest < ActionDispatch::IntegrationTest

  KEYS = %w(age human id name)

  describe "index" do
    # These tests are a little verbose - yours do not need to be
    # this explicit.
    it "is a real working route" do
      get pets_url
      must_respond_with :success
    end

    it "returns json" do
      get pets_url
      response.header['Content-Type'].must_include 'json'
    end

    it "returns an Array" do
      get pets_url

      body = JSON.parse(response.body)
      body.must_be_kind_of Array
    end

    it "returns all of the pets" do
      get pets_url

      body = JSON.parse(response.body)
      body.length.must_equal Pet.count
    end

    it "returns pets with exactly the required fields" do
      get pets_url
      body = JSON.parse(response.body)
      body.each do |pet|
        pet.keys.sort.must_equal KEYS
      end
    end
  end

  describe "show" do
    # This bit is up to you!
    it "can get a pet" do
      get pet_path(pets(:two).id)
      must_respond_with :success

      body = JSON.parse(response.body)
      body.must_be_instance_of Hash
      body.keys.sort.must_equal KEYS
    end

    it "errors gracefully when pet not found" do
      get pet_path(Pet.all.last.id+1)
      must_respond_with :not_found

      body = JSON.parse(response.body)
      body.must_equal "nothing" => true
    end

    it "must get the correct pet" do
      get pet_path(pets(:one).id)
      must_respond_with :success
      body = JSON.parse(response.body)


      KEYS.each do |key|
        body[key].must_equal pets(:one)[key]
      end
    end

    it "must return the correct data" do
      get pet_path(pets(:one).id)
      must_respond_with :success
      body = JSON.parse(response.body)
      body.keys.sort.must_equal KEYS
    end
  end

  describe "create" do
    let(:pet_data) {
      { pet: {
        name: "Jack",
        age: 7,
        human: "Captain Barbossa"
      } }
    }

    it "can create a new pet" do
      proc {
        post pets_path, params: pet_data
      }.must_change 'Pet.count', 1
      must_respond_with :success

    end

    it "returns the correct data for a successful create" do
      post pets_path, params: pet_data
      body = JSON.parse(response.body)
      body["id"].must_equal Pet.find_by_name("Jack").id
    end

    it "won't change DB if missing data" do
      proc {
        post pets_path, params: { pet: { "age": 3, "human": "Felicity"}}
      }.must_change 'Pet.count', 0
      must_respond_with :bad_request

      body = JSON.parse(response.body)
      body.must_equal  "errors" => { 'name' => ["can't be blank"]}
    end




    # it "Creates a new pet" do
    #   assert_difference "Pet.count", 1 do
    #     post pets_url, params: { pet: pet_data }
    #     assert_response :success
    #   end
    #
    #   body = JSON.parse(response.body)
    #   body.must_be_kind_of Hash
    #   body.must_include "id"
    #
    #   # Check that the ID matches
    #   Pet.find(body["id"]).name.must_equal pet_data[:name]
    # end
    #
    # it "Returns an error for an invalid pet" do
    #   bad_data = pet_data.clone()
    #   bad_data.delete(:name)
    #   assert_no_difference "Pet.count" do
    #     post pets_url, params: { pet: bad_data }
    #     assert_response :bad_request
    #   end
    #
    #   body = JSON.parse(response.body)
    #   body.must_be_kind_of Hash
    #   body.must_include "errors"
    #   body["errors"].must_include "name"
    # end
  end
end
