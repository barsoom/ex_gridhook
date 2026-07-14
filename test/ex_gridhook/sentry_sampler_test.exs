defmodule ExGridhook.SentrySamplerTest do
  use ExUnit.Case, async: true

  defp sample(attributes \\ %{}) do
    ExGridhook.SentrySampler.sample(%{transaction_context: %{attributes: attributes}})
  end

  test "drops the k8s probe and samples SendGrid webhooks hard" do
    assert sample(%{"url.path": "/revision"}) == 0.0
    assert sample(%{"url.path": "/events"}) == 0.01
  end

  test "samples everything else when there is no incoming trace" do
    assert sample(%{"url.path": "/login/sso"}) == 1.0
    assert sample() == 1.0
  end

  test "respects the parent sampling decision from an incoming sentry-trace header" do
    :otel_ctx.set_value(
      :"sentry-trace",
      {"8ea7ebdd71be4f29bc23434711a631ee", "a2270a7527074cdb", true}
    )

    assert sample(%{"url.path": "/login/sso"}) == 1.0

    :otel_ctx.set_value(
      :"sentry-trace",
      {"8ea7ebdd71be4f29bc23434711a631ee", "a2270a7527074cdb", false}
    )

    assert sample(%{"url.path": "/login/sso"}) == 0.0
  end
end
