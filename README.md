# Niacademy

This is a single-user web app to help out with drawing practice.

The basic idea is to try to alleviate some of the anxiety and paralyzing lack of direction when it comes to practicing drawing. This program attempts to organize the massive amount of things you could possibly learn or do with drawing into structured, trackable blocks of time that require as little human-computer interaction as possible to successfully complete. Getting started practicing each day should be as frictionless as opening a webpage and clicking a link.

The webapp also balances out the time you spend learning from tutorials and drawing the important things you want to draw, making sure they hover around a 1:1 ratio. The hope is that you won't have to spend mental energy manually recording the time you spend practicing every day or scheduling things when the computer can take care of it all.

## Dependencies

- `elixir`
- `node` and `npm`
- `dhall` and `dhall-to-yaml`

## Setup
1. Sign up for an account at [Toggl Track](https://track.toggl.com/). Create a workspace with two projects in it: one will be for tracking free drawing, and the other will be for tracking tutorials.
2. Copy `config/secret.config.exs` to `config/secret.exs` and edit it accordingly. Also note the basic auth credentials in `config/config.exs`.
3. Add images to the `priv/images/` folder, or whichever folder was configured in `config.exs`. First, create some directories with the names of the major categories to use, and then create subfolders with the names of the minor categories to use inside each of them. After that, place the images you want to use in each subfolder. The categories will then be named like `<major_category>/<minor_category>`.
4. Edit `config/regimens.dhall` and specify what kinds of learning/drawing sessions to schedule. Afterwards, run `mix compile_regimens` to produce `config/regimens.yml`.
5. Build and run the application.

## Building

```bash
mix deps.get
mix ecto.setup
cd assets && npm install && cd ..
mix phx.server
```

## Caution

This web application was designed to be as simple as possible to manage and add content to, so some tradeoffs were made. One example is the fact that there can only be a single user/browser session active at a time for the time tracking not to break. I decided to make this a webapp regardless so that the same data can be shared between mobile phones and computers without much UI interaction or other manual setup required. Also, most of the data is loaded from a single YAML file, and the DB is basically only used to keep track of in-progress sessions. (Even then, the important parts are just some JSON saved to a text field.)

## License

MIT.
