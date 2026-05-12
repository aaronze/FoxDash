# frozen_string_literal: true

class User < ApplicationRecord
  has_one :dashboard_layout, dependent: :destroy

  after_create :create_dashboard_layout

  def self.default_layout
    {
      type: 'column',
      width: '100%',
      children: [
        {
          type: 'row',
          height: '50%',
          children: [
            { type: 'widget', id: 'solar', width: '50%' },
            { type: 'widget', id: 'battery', width: '50%' }
          ]
        },
        {
          type: 'row',
          height: '50%',
          children: [
            { type: 'widget', id: 'weather', width: '33%' },
            { type: 'widget', id: 'home', width: '33%' },
            { type: 'widget', id: 'security', width: '34%' }
          ]
        }
      ]
    }
  end

  private

  def create_default_dashboard_layout
    self.create_dashboard_layout(layout: User::default_layout)
  end
end
