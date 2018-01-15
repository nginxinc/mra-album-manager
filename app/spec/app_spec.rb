require 'spec_helper.rb'
require_relative '../models/album.rb'
require 'pp'

#
#  app_spec.rb
#  AlbumManager
#
#  Copyright © 2017 NGINX Inc. All rights reserved.
#

describe 'User manager' do
  def a_user_id
    'a_user_id'
  end

  def a_different_user_id
    'a_different_user_id'
  end

  def auth_headers(user_id)
    return {'HTTP_AUTH_ID' => user_id}
  end

  it 'passes a healthcheck' do
    get '/'

    expect(last_response).to be_ok
    expect(last_response.body).to include('Sinatra is up!')
  end

  it 'returns a 401 if no user id is passed' do
    get '/albums'

    expect(last_response).to be_unauthorized
  end

  it 'can list the albums' do
    albums = create_list(:album_with_images, 5, user_id: a_user_id)

    get '/albums', nil, auth_headers(a_user_id)

    expect(last_response).to be_ok

    parsed_body = JSON.parse(last_response.body)

    expect(parsed_body.length).to eq 5

    parsed_body.each do |album|
      expect(album).to have_key('poster_image')
      expect(album['url']).to eq("/albums/#{album['id']}")
    end
  end

  it "cannot list another user's albums" do
    albums = create_list(:album, 5, user_id: a_user_id)

    get '/albums', nil, auth_headers(a_different_user_id)

    expect(last_response).to be_ok

    parsed_body = JSON.parse(last_response.body)

    expect(parsed_body).to be_empty
  end

  it 'can get an album' do
    album = create(:album_with_images, user_id: a_user_id)

    get "/albums/#{album.id}", nil, auth_headers(a_user_id)

    expect(last_response).to be_ok

    parsed_body = JSON.parse(last_response.body)

    expect(parsed_body['id']).to eq(album.id)
    expect(parsed_body['user_id']).to eq(a_user_id)
    expect(parsed_body).to have_key('poster_image')
    expect(parsed_body['images'].length).to eq(5)
  end

  it "cannot get another user's album" do
    album = create(:album, user_id: a_user_id)

    get "/albums/#{album.id}", nil, auth_headers(a_different_user_id)

    expect(last_response).to be_not_found
  end

  it 'can create an album' do
    album_name = 'name'

    params = {
        album: {
            name: album_name
        }
    }

    post '/albums', params, auth_headers(a_user_id)

    expect(last_response).to be_created

    parsed_body = JSON.parse(last_response.body)

    expect(parsed_body['user_id']).to eq(a_user_id)
    expect(parsed_body['name']).to eq(album_name)
    expect(parsed_body['state']).to eq('pending')
  end

  it 'can update an album' do
    album = create(:album_with_images, user_id: a_user_id)

    new_poster_image_id = album.images.last.id

    params = {
        album: {
            poster_image_id: new_poster_image_id
        }
    }

    put "/albums/#{album.id}", params, auth_headers(a_user_id)

    expect(last_response).to be_accepted

    parsed_body = JSON.parse(last_response.body)

    expect(parsed_body['poster_image_id']).to eq(new_poster_image_id)
  end

  it "cannot update another user's album" do
    album = create(:album_with_images, user_id: a_user_id)

    put "/albums/#{album.id}", nil, auth_headers(a_different_user_id)

    expect(last_response).to be_not_found
  end

  it 'can delete an album' do
    album = create(:album_with_images, user_id: a_user_id)

    delete "/albums/#{album.id}", nil, auth_headers(a_user_id)

    expect(last_response).to be_accepted
  end

  it "cannot delete another user's album" do
    album = create(:album, user_id: a_user_id)

    delete "/albums/#{album.id}", nil, auth_headers(a_different_user_id)

    expect(last_response).to be_not_found
  end

  it 'can add an image to an album' do
    album = create(:album, user_id: a_user_id)

    params = {
        image: {
            album_id: album.id
        }
    }

    post "/images", params, auth_headers(a_user_id)

    expect(last_response).to be_created

    parsed_body = JSON.parse(last_response.body)

    expect(parsed_body['album_id']).to eq(album.id)
  end

  it "cannot add an image to another user's album" do
    album = create(:album, user_id: a_user_id)

    params = {
        image: {
            album_id: album.id
        }
    }

    post "/images", params, auth_headers(a_different_user_id)

    expect(last_response).to be_unauthorized
  end
end
