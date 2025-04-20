# frozen_string_literal: true

Janus::Engine.routes.draw do
  resource :database, only: [] do
    post 'switch', on: :collection
    get 'current', on: :collection
  end
end
