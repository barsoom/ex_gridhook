defmodule ExGridhook.SentrySampler do
  @moduledoc false

  # /events takes ~330k SendGrid webhook posts/day (as of 2026-07), so we sample it hard; /revision is the k8s readiness probe.
  def sample(%{transaction_context: %{attributes: attributes}}) do
    case attributes[:"url.path"] do
      "/revision" -> 0.0
      "/events" -> 0.01
      _ -> 1.0
    end
  end
end
