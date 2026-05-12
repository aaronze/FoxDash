# frozen_string_literal: true

class DashboardLayout < ApplicationRecord
  belongs_to :user

  validates :layout, presence: true

  def update_layout(layout)
    self.layout = layout
    save
  end
end
