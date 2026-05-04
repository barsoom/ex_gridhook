defmodule ExGridhookWeb.Auth.SsoOnMount do
  @moduledoc false


  def on_mount(:default, _params, session, socket) do
    sso_employee_id = session["sso_employee_id"]

    {_session_ids, claims} =
      AuctionetSingleSignOnPlug.PersistSsoSessionsInMemory.active_sso_session_ids_and_data(
        sso_employee_id
      )

    current_user = claims && claims.user

    {:cont, Phoenix.Component.assign(socket, :current_user, current_user)}
  end
end
