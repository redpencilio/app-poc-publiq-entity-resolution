defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ]
  ]

  define_layers [ :static, :web_page, :services, :fall_back, :not_found ]

  ###############
  # STATIC
  ###############
  get "/assets/*path", %{ layer: :static } do
    forward conn, path, "http://frontend/assets/"
  end

  get "/favicon.ico", %{ layer: :static } do
    send_resp( conn, 404, "" )
  end

  #################
  # FRONTEND PAGES
  #################
  get "/*_path", %{ layer: :web_page, accept: %{ html: true } } do
    forward conn, [], "http://frontend/index.html"
  end

  #################
  # SERVICES
  #################

  match "/mappings/*path", %{ layer: :services, accept: %{ json: true } } do
    forward conn, path, "http://cache/mappings/"
  end

  match "/addresses/*path", %{ layer: :services, accept: %{ json: true } } do
    forward conn, path, "http://cache/addresses/"
  end

  match "/locations/*path", %{ layer: :services, accept: %{ json: true } } do
    forward conn, path, "http://cache/locations/"
  end

  get "/people/*path", %{ layer: :services, accept: %{ json: true } } do
    forward conn, path, "http://resource/people/"
  end

  get "/accounts/*path", %{ layer: :services, accept: %{ json: true } } do
    forward conn, path, "http://resource/accounts/"
  end

  match "/sessions/*path", %{ layer: :services, accept: %{ json: true } } do
    forward conn, path, "http://login/sessions/"
  end

  match "/*_", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
