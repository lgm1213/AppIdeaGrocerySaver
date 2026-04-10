class SendDealAlertsJob < ApplicationJob
  queue_as :default

  def perform
    User.includes(:stores, :user_recipe_preferences).find_each do |user|
      Deals::AlertDigest.new(user).deliver
    end
  end
end
