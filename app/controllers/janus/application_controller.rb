# frozen_string_literal: true

module Janus
  class ApplicationController < ActionController::Base
    skip_before_action :verify_authenticity_token

    rescue_from Janus::SwitchError, with: :render_switch_error
    before_action :ensure_enabled

    private

    def ensure_enabled
      return if Janus::DbSwitcher.enabled?

      render json: { error: 'Janus disabled', success: false }, status: :forbidden
    end

    def render_switch_error(exception)
      render json: { error: exception.message, success: false }, status: :internal_server_error
    end
  end
end
