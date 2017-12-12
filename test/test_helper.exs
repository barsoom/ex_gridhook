ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(ExGridhook.Repo, :manual)

ExUnit.configure(exclude: [error_view_case: true])
