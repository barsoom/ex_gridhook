defmodule ExGridhookWeb.Auth.JwtPlug do
  @moduledoc """
  Thin wrapper around AuctionetSingleSignOnPlug that reads config from
  application env. Skips authentication in dev when SSO_SECRET_KEY is not set.
  """

  def init(opts), do: opts

  def call(conn, _opts) do
    secret_key = Application.get_env(:ex_gridhook, :sso_secret_key)

    if is_nil(secret_key) do
      conn
    else
      opts =
        AuctionetSingleSignOnPlug.init(
          sso_secret_key: secret_key,
          sso_request_url: Application.get_env(:ex_gridhook, :sso_request_url)
        )

      AuctionetSingleSignOnPlug.call(conn, opts)
    end
  end
end
