class InstallationController < ApplicationController
  skip_authorization_check

  def details
    respond_to do |format|
      format.any { render json: consul_installation_details.to_json, content_type: "application/json" }
    end
  end

  private

    def consul_installation_details
      { release: "2.0.1" }.merge(features: settings_feature_flags)
    end

    def settings_feature_flags
      Setting.where("key LIKE 'process.%'").each_with_object({}) { |x, n| n[x.key.remove("process.")] = x.value }
    end
end
