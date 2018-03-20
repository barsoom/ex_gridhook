# ExGridhook

ExGridhook is an app to recieve and persist sendgrid webhook events.

We built this app since our previous solution couldn't handle the amount of event we receive from Sendgrid.
This app should scale better (we haven't seen any issues so far).

## Endpoints

* "/"         shows a friendly message.
* "/revision" returns the current git revison of the app.
* "/events"   receives sendgrid events and persists them.

## TODO

* [x] Configure CircleCI
* [x] Deploy to heroku
* [x] Update this file with steps on how to deploy to heroku.
* [ ] Complete tests for event.ex
* [ ] Prevent duplication
* [ ] …

## Development

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Production

This app deploys to heroku via circleci.

[circleci configuration](.circleci/config.yml).

**For non Auctionet.com users**

If you want to use this app you should probably fork this repo and change how you persist data, circleci configuration and so on…

### Basic auth

In order to have some sort of security, this app uses basic auth for the /events endpoint.

    heroku config:set BASIC_AUTH_USERNAME=<username you want to use> BASIC_AUTH_PASSWORD=<password of your choosing>

### Generate secret key base

    heroku config:set SECRET_KEY_BASE=$(mix phoenix.gen.secret)

### Heroku build packs

    heroku buildpacks:add https://github.com/barsoom/heroku-buildpack-shell-tools.git
    heroku buildpacks:add https://github.com/HashNuke/heroku-buildpack-elixir

## Useful links

* [Sendgrid event webhooks docs](https://sendgrid.com/docs/API_Reference/Webhooks/event.html)
* [Basic Auth repo](https://github.com/CultivateHQ/basic_auth)
