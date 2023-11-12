# frozen_string_literal: true

# Stubs as error or as success depending on `omniauth_response` type
module OmniauthStubs
  def self.included(klass)
    klass.around do |example|
      next unless defined? omniauth_response

      OmniAuth.config.test_mode = true
      ActionController::Base.allow_forgery_protection = false

      case omniauth_response
      when OmniAuth::AuthHash
        with_omniauth_success(omniauth_provider, omniauth_response) do
          example.run
        end
      when OmniAuth::Strategies::OAuth2::CallbackError
        with_omniauth_failure(omniauth_provider, omniauth_response) do
          example.run
        end
      else
        raise ArgumentError, "don't know how to handle omniauth_response: #{omniauth_response.inspect}"
      end
    end
  end

  def with_omniauth_success(provider, callback)
    previous = OmniAuth.config.mock_auth[provider]
    OmniAuth.config.mock_auth[provider] = callback
    yield
    OmniAuth.config.mock_auth[provider] = previous
  end

  def with_omniauth_failure(provider, callback_error)
    OmniAuth.config.mock_auth[provider] = callback_error.message.to_sym

    default_failure_handler = OmniAuth.config.on_failure

    local_failure_handler = proc do |env|
      env["omniauth.error"] = callback_error
      env
    end
    # here we compose the two handlers into a single function,
    # the result will be global_failure_handler(local_failure_handler(env))
    failure_handler = default_failure_handler << local_failure_handler

    OmniAuth.config.on_failure = failure_handler

    yield

    OmniAuth.config.on_failure = default_failure_handler
  end
end
