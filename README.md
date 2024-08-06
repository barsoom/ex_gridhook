# ExGridhook

[![CircleCI](https://circleci.com/gh/barsoom/ex_gridhook.svg?style=svg&circle-token=fc0c22ab268d4f8a9a2f9c5aeac964bc815ef5cd)](https://app.circleci.com/pipelines/github/barsoom/ex_gridhook)

ExGridhook is an app to receive and persist SendGrid webhook events.

We built this app since our previous solution couldn't handle the amount of events we receive from SendGrid.
This app should scale better. We haven't seen any issues so far.

## Endpoints

* "/"         shows a friendly message.
* "/revision" returns the current git revison of the app.
* "/events"   receives SendGrid events and persists them.

## Development

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start the Phoenix endpoint with `mix phx.server`

Now you can navigate to [`localhost:4000`](http://localhost:4000).

## Production

[Phoenix Framework's "Introduction to Deployment" guide](https://hexdocs.pm/phoenix/deployment.html)

This app deploys to Stack via Github Actions.

[GitHub Actions configuration](.github/workflows/ci.yml).

Deploys intentionally *do not* run migrations, because [Gridlook](https://github.com/barsoom/gridlook) is responsible for the production database structure. Migrations are only for dev/tests.

**For non-Auctionet.com users**

If you want to use this app, you should probably fork this repo and change how you persist data, CircleCI configuration and so on…

### Basic auth

In order to have some sort of security, this app uses basic auth for the `/events` endpoint.

    BASIC_AUTH_USERNAME=<username you want to use>
    BASIC_AUTH_PASSWORD=<password of your choosing>

### Generate secret key base

    SECRET_KEY_BASE=$(mix phoenix.gen.secret)

## Update Erlang/Elixir versions

We use hexpm/elixir for Elixir/Erlang support in Dockerfile.

Edit `elixir_buildpack.config` and change the version numbers.

You can find supported tags in the [dockerhub repo](https://hub.docker.com/r/hexpm/elixir/tags).

## Useful links

* [SendGrid event webhooks docs](https://sendgrid.com/docs/for-developers/tracking-events/event/)
