class DashboardController < ApplicationController
  def index
    @layout = User::default_layout
  end
end
