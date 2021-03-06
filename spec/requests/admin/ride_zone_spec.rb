require 'rails_helper'

RSpec.describe "RideZones", type: :request do

  describe "GET /admin/ride_zones" do

    it "redirects if you're not logged in" do
      get admin_ride_zones_path
      expect(response).to have_http_status(302)
    end

    it "redirects ride zone page if you're logged in as a non-admin" do
      user = create(:user)
      sign_in user

      get admin_ride_zones_path
      expect(response).to have_http_status(302)
    end

    it "ride zone page succeeds if you're logged in as an admin" do
      user = create(:admin_user)
      sign_in user

      get admin_ride_zones_path
      expect(response).to be_successful
    end

    it "redirects ride zones if you're not logged in" do
      ride_zone = create(:ride_zone)
      get admin_ride_zone_path(ride_zone)
      expect(response).to have_http_status(302)
    end

    it "redirects ride zones if you're logged in but not a dispatcher" do
      user = create(:user)
      sign_in user

      ride_zone = create(:ride_zone)
      get admin_ride_zone_path(ride_zone)
      expect(response).to have_http_status(302)
    end

    it "redirects ride zones if you're a dispatcher for it" do
      ride_zone = create(:ride_zone)
      user = create(:user)
      user.add_role(:dispatcher, ride_zone)

      sign_in user

      get admin_ride_zone_path(ride_zone)
      expect(response).to have_http_status(302)
    end

    it "lets you view a ride zone if you're an admin" do
      user = create(:user)
      user.add_role(:admin)
      ride_zone = create(:ride_zone)

      sign_in user

      get admin_ride_zone_path(ride_zone)
      expect(response).to be_successful
    end

  end
end
