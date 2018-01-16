# ExGridhook

ExGridhook is an app to recieve and persist sendgrid webhook events.

## Endpoints

* "/" shows a friendly message.
* "/revision" returns the current git revison of the app.
* …

## TODO

* [ ] Complete tests for event.ex
* [ ] Configure CircleCI
* [ ] Deploy to heroku
* [ ] Prevent duplication
* [ ] …

## Development

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Production

**For non Auctionet.com users**

If you want to use this app you should probably fork this repo and change how you persist data.

### Generate secret key base

    mix phoenix.gen.secret

Set `SECRET_KEY_BASE` as an env.

## Useful links

* https://sendgrid.com/docs/API_Reference/Webhooks/event.html
