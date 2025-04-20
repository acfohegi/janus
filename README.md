# Janus

Ruby gem for dynamic database switching in Rails applications and Sidekiq,
especially useful for end-to-end testing with tools like [IntegreSQL](https://github.com/allaboutapps/integresql).

> [Janus](https://en.wikipedia.org/wiki/Janus) is an ancient Roman god of transitions, duality, doorways, and change. He is often depicted with two faces, symbolizing looking to the past and the future, or managing two paths at once.

## Features

- Switches the ActiveRecord connection in your Rails application
- Automatically switches all new Sidekiq jobs to the current database
- Supports managing multiple interconnected Rails applications by sharing the same Redis namespace

## Installation

1. Add to your `Gemfile`:

```ruby
gem 'janus', github: 'acfohegi/janus'
```

2. Install:

```sh
bundle
```

3. Add to your `config/routes.rb`:

```ruby
mount Janus::Engine, at: '/janus'
```

4. Set the environment variables:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `JANUS_REDIS_HOST` | Host address of the Redis server | `localhost` |
| `JANUS_REDIS_PASS` | Redis password | None |
| `JANUS_NAMESPACE` | Separate Redis namespace to isolate Janus data. Allows using the same Redis instance for multiple applications and safely resetting namespaces per app. | `janus` |
| `JANUS_APP_NAME` | Redis key name for storing the current database name | `current_db_name` |
| `JANUS_ENABLED` | Enables database switching, Sidekiq middlewares and API endpoints. Set to `true` to enable. | None |


## Usage

Janus allows you to choose how to group different test runs. You can do this either by using different namespaces with persistent application names, or within the same namespace populated with unique names for each app instance.

For a single Rails + Sidekiq application, you will need to perform two actions:

- Set the current database name in Redis
- Then send a POST request to `/janus/database/switch`
