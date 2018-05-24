require "spec_helper"

describe "LiveObs Docker image - Application" do
  before(:all) do
    set :os, family: :debian
    set :backend, :docker
    set :docker_image, image
  end

  describe file('/opt/odoo/liveobs_addons') do
    it{ should be_directory }
  end

  describe file('/opt/odoo/liveobs_addons/nh_odoo_fixes') do
    it{ should be_directory }
  end

  describe file('/opt/odoo/liveobs_addons/nh_activity') do
    it{ should be_directory }
  end

  describe file('/opt/odoo/liveobs_addons/nh_clinical') do
    it{ should be_directory }
  end

  describe file('/opt/odoo/liveobs_addons/nh_observations') do
    it{ should be_directory }
  end

  describe file('/opt/odoo/liveobs_addons/nh_ews') do
    it{ should be_directory }
  end

  describe file('/opt/odoo/liveobs_addons/nh_eobs') do
    it{ should be_directory }
  end

  describe file('/opt/odoo/liveobs_addons/nh_eobs_mental_health') do
    it{ should be_directory }
  end

  describe file('/opt/odoo/liveobs_addons/nh_eobs_mobile') do
    it{ should be_directory }
  end

  describe file('/opt/odoo/liveobs_addons/nh_eobs_api') do
    it{ should be_directory }
  end

  describe file('/opt/odoo/liveobs_addons/nh_eobs_slam') do
    it{ should be_directory }
  end

  describe file('/opt/nh/venv/lib/python2.7/site-packages/werkzeug/wsgi.py') do
    it{ should be_file }
  end

end
