module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :require_admin

    private

    def require_admin
      unless Current.user&.admin?
        redirect_to dashboard_path, alert: "Access denied."
      end
    end
  end
end
