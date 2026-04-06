class PagesController < ApplicationController
  allow_unauthenticated_access
  layout "application"

  def landing
    # Public landing page — no auth required
  end
end
