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

#
# app.rb
# AlbumManager
# Unicorn based application which stores and retrieves information about a the
# albums that an user has created
#
# Copyright © 2017 NGINX Inc. All rights reserved.
#

#
# set the bind variable to this host
#
set :bind, '0.0.0.0'

#
# For development mode use the BetterErrors library
#
configure :development do
	use BetterErrors::Middleware
	BetterErrors.application_root = __dir__
end

#
# Create helper methods
#
helpers do

  #
  # Read the request HTTP_AUTH_ID parameter in to a variable and return it
  #
  def user_id
    @user_id ||= request.env['HTTP_AUTH_ID']
  end

  #
  # Retrieve the album specified by tne ID
  #
  def album
    @album ||= Album.includes(:images, :poster_image)
                   .where(id: params[:id], user_id: user_id)
                   .take || halt(404)
	end

  #
  # Retrieve the album specified by tne ID
  #
  def public
    @public ||= Album.includes(:images, :poster_image)
                   .where(id: params[:id], public: true)
                   .take || halt(404)
  end

  #
  # Retrieve the image specified by the id parameter
  #
  def image
		@image ||= Image.joins(:album)
                   .where(id: params[:id], :albums => {:user_id => user_id})
                   .take || halt(404)
	end

  #
  # Create a logger object to use throught the system. It is initialized in the `before do` process
  # with a setting of WARN unless the env var DEBUG=true has been passed
  #
  def log
		@log = Logger.new(STDOUT)
	end
end

#
# Before any request is processed, check that the path is "/" and that the
# user_id is set from the helper method
#
before do
	content_type 'application/json'
	log.level = Logger::WARN
	if ENV['DEBUG'] == 'true'
		log.level = Logger::DEBUG
	end
	paramsString = ""
	params.each{|param| paramsString += "#{param} "}
	log.debug("The request path: #{ request.path_info } and params #{ paramsString } and header #{ request.env['HTTP_AUTH_ID'] }")

	pass if (request.path_info == '/' || request.path_info =~ /^\/public\//)
	halt 401, 'Auth-ID header is really required' if user_id.nil?
end

#
# Handle get requests for the path "/".
# This is used for health checks
#
get '/' do
	'Sinatra is up!' + "\n"
end

#
# Handle get requests for the path "/public"
# Find all pending albums in tne database and delete any older than
# 15 minutes
#
# Then query for albums with a poster image and return their data as JSON
#
 get '/public/:id' do
   public.to_json(:include => [:images, :poster_image])
 end

#
# Handles a patch request to "/albums/XXX/public/boolean" where XXX is the unique ID of an album and public/boolean
# Updates the album with the data in the request payload
#
 patch '/albums/:id/public/:public' do
   album.update(public: params[:public])
   album.save!

   status 202
 end


# Handle get requests for the path "/albums"
# Find all pending albums in tne database and delete any older than
# 15 minutes
#
# Then query for albums with a poster image and return their data as JSON
#
get '/albums' do
  time = Time.now

  pending_albums = Album.where(state: 'pending')
	pending_albums.each {|album|
		if album.created_at.to_i < (time.to_i - 900)
			Album.destroy(album.id)
		end
	}

	albums = Album.includes(:poster_image).where(user_id: user_id)
  albums.to_json(:include => :poster_image, :methods => :url)
end

#
# Handle a post request to "/albums"
# Create an album from the request body parameter named albums for the specified
# user
#
# There are 3 albums that are created for each user (Profile, Cover and Article) and are created with an "active"
# parameter passed in the album JSON. If this is passed, then the albums are set to active automatically
#
post '/albums' do
	album = Album.new(params['album'])

  album.user_id = user_id
  unless album.state == 'active'
		album.state = 'pending'
  end

  if album.poster_image.blank? && album.images.any?
  	album.poster_image = album.images.first
  end

	album.save!

  status 201
	album.to_json(:include => [:images, :poster_image])
end

#
# Handle get requests for "/albums/XXX" where XXX is the unique ID of an album
# in the database
#
get '/albums/:id' do
	album.to_json(:include => [:images, :poster_image])
end

#
# Handles a put request to "/albums/XXX" where XXX is the unique ID of an album
# Updates the album with the data in the request payload
#
put '/albums/:id' do
	album.update(params['album'])
	album.save!

	status 202
  album.to_json(:include => [:images, :poster_image])
end

#
# Handles a delete request for "/albums?xxx" where XXX is the unique ID of an album
# Delete the album with the specified ID
#
delete '/albums/:id' do
  halt 405, 'Albums associated with Posts are Public and cannot be deleted' if album.public?
  Album.destroy(album.id)
	status 202
end

#
# Handles a get request to "/images"
# Retrieves all the images for a user and returns their data as JSON
#
get '/images' do
	images = Image.joins(:album).where(:albums => {:user_id => user_id})
  images.to_json
end

#
# Handles a post request for "/images"
# Creates a new Image using the data in the request body and returns the data as JSON
#
post '/images' do
	image = Image.new(params['image'])

	halt 401 if image.album.user_id != user_id

	image.save!

	album = Album.find_by(id: image.album_id)
	album.state = 'active'
	album.save!

	status 201
	image.to_json
end

#
# Handles a get request to "/images/XXX" where XXX is the ID of an image
# Retrieves an image using the image helper and returns its data as JSON
#
get '/images/:id' do
	image.to_json
end

#
# Handles a PUT request for "/images/XXX" where XXX is the ID of an image
# Uses the image helper to retrieve an image and updates it using the parameters
# in the request payload
#
put '/images/:id' do
	image.update(params['image'])

	halt 401 if image.album.user_id != user_id

	image.save!

	status 202
  image.to_json
end

#
# Handles a DELETE request for "/images/XXX/YYY" where YYY is the UUID of an image
# Removes an image from S3 and from the database
#
delete '/images/:id/:uuid' do
	header = {
		"auth-id"  => user_id,
	}
	response = HTTParty.delete(ENV['UPLOADER_PHOTO'] + params[:uuid], :header => header)
	response.to_json
	Image.destroy(image.id)
	status 202
end
