#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'json'

require './models/album.rb'
require './models/image.rb'

set :bind, '0.0.0.0'
set :dump_errors, true
set :show_exceptions, true

before do
	content_type 'application/json'
end

get '/' do
	"Sinatra is up!"
end

# list all
get '/albums' do
	albums = Album.includes(:poster_image).all.to_json(:include => :poster_image, :methods => :url)
end

# view one
get '/albums/:id' do
	album = Album.includes(:images, :poster_image).find(params[:id])
	return status 404 if @album.nil?
	album.to_json(:include => [:images, :poster_image])
end

# create
post '/albums' do
	# json = JSON.parse(request.body.read)
	# album = Album.new(json['album'])
	album = Album.new(params['album'])
	album.save!
	album.to_json(:include => [:images, :poster_image])
end

# update
put '/albums/:id' do
	album = Album.find(params[:id])
	return status 404 if album.nil?
	album.update(params['album'])
	album.save!
	album.to_json
end

delete '/albums/:id' do
	album = Album.find(params[:id])
	return status 404 if album.nil?
	album.delete!
	status 202
end

# list all
get '/images' do
	Image.all.to_json
end

# view one
get '/images/:id' do
	image = Image.find(params[:id])
	return status 404 if image.nil?
	image.to_json
end

# create
post '/images' do
	image = Image.new(params['image'])
	image.save!
	status 201
end

# update
put '/images/:id' do
	image = Image.find(params[:id])
	return status 404 if image.nil?
	image.update(params['image'])
	image.save!
	status 202
end

delete '/images/:id' do
	image = Image.find(params[:id])
	return status 404 if image.nil?
	image.delete!
	status 202
end