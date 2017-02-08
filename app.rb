#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/base'
require 'newrelic_rpm'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'json'
require 'better_errors'
require 'httparty'

require './models/album.rb'
require './models/image.rb'

set :bind, '0.0.0.0'

configure :development do
	use BetterErrors::Middleware
	BetterErrors.application_root = __dir__
end

helpers do
  def user_id
		@user_id ||= request.env["HTTP_AUTH_ID"]
	end

  def album
		@album ||= Album
									 .includes(:images, :poster_image)
									 .where(id: params[:id], user_id: user_id)
									 .take || halt(404)
	end

  def image
		@image ||= Image
									 .joins(:album)
									 .where(id: params[:id], :albums => {:user_id => user_id})
									 .take || halt(404)
	end
end

before do
	pass if request.path_info == "/"
	halt 401, 'Auth-ID header is really required' if user_id.nil?
	content_type 'application/json'
end

get '/' do
	"Sinatra is up!"
end

# list all
get '/albums' do
	albums = Album.includes(:poster_image).where(user_id: user_id)
  albums.to_json(:include => :poster_image, :methods => :url)
end

# create
post '/albums' do
	album = Album.new(params['album'])

  album.user_id = user_id

  if album.poster_image.blank? && album.images.any?
  	album.poster_image = album.images.first
  end

	album.save!

  status 201
	album.to_json(:include => [:images, :poster_image])
end

# view one
get '/albums/:id' do
	album.to_json(:include => [:images, :poster_image])
end

# update
put '/albums/:id' do
	album.update(params['album'])
	album.save!

	status 202
  album.to_json(:include => [:images, :poster_image])
end

delete '/albums/:id' do
	Album.destroy(album.id)
	status 202
end

# list all
get '/images' do
	images = Image.joins(:album).where(:albums => {:user_id => user_id})
  images.to_json
end

# create
post '/images' do
	image = Image.new(params['image'])

  halt 401 if image.album.user_id != user_id

	image.save!

	status 201
  image.to_json
end

# view one
get '/images/:id' do
	image.to_json
end

# update
put '/images/:id' do
	image.update(params['image'])

	halt 401 if image.album.user_id != user_id

	image.save!

	status 202
  image.to_json
end

delete '/images/:id/:uuid' do
	response = HTTParty.delete("http://localhost/uploader/image/uploads/photos/" + params[:uuid])
  response.to_json
	Image.destroy(image.id)
	status 202
end
