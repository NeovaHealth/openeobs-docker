require "spec_helper"

describe "LiveObs Docker image - Database Initialisation" do
  before(:all) do
    set :os, family: :debian
    set :backend, :docker
    set :docker_image, image
  end

  describe file('/opt/odoo/db_init') do
    it{ should be_directory }
  end

  describe file('/opt/odoo/createdb.sh') do
    it{ should exist }
    it{ should be_executable }
  end

  describe file('/opt/odoo/db_init/demo/demo.py') do
    it{ should exist }
  end

  describe file('/opt/nh/venv/bin/invoke') do
    it{ should exist }
    it{ should be_executable }
  end

end
