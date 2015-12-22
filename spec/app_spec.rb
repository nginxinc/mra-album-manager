require 'spec_helper.rb'
require_relative '../models/album.rb'
require 'pp'

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

  it 'returns a 401 if no user id is passed' do
    get '/'

    expect(last_response).to be_unauthorized
  end

  it 'is up' do
    get '/', nil, auth_headers(a_user_id)

    expect(last_response).to be_ok
    expect(last_response.body).to include('Sinatra is up!')
  end

  it 'can create an album' do
    params = {
        album: {
            name: 'name'
        }
    }

    post '/albums', params, auth_headers(a_user_id)

    expect(last_response).to be_created

    album = JSON.parse(last_response.body)

    expect(album['user_id']).to eq(a_user_id)
    expect(album['name']).to eq('name')
  end

  it 'can get an album' do
    album = create(:album, user_id: a_user_id)

    get "/albums/#{album.id}", nil, auth_headers(a_user_id)

    expect(last_response).to be_ok

    parsed_body = JSON.parse(last_response.body)

    expect(parsed_body['id']).to eq(album.id)
    expect(parsed_body['user_id']).to eq(a_user_id)
  end

  it "cannot get another user's album" do
    album = create(:album, user_id: a_user_id)

    get "/albums/#{album.id}", nil, auth_headers(a_different_user_id)

    expect(last_response).to be_not_found
  end

  it 'can list the albums' do
    albums = create_list(:album, 5, user_id: a_user_id)

    get '/albums', nil, auth_headers(a_user_id)

    expect(last_response).to be_ok

    parsed_body = JSON.parse(last_response.body)

    expect(parsed_body.length).to eq 5
  end

  it "cannot list another user's albums" do
    albums = create_list(:album, 5, user_id: a_user_id)

    get '/albums', nil, auth_headers(a_different_user_id)

    expect(last_response).to be_ok

    parsed_body = JSON.parse(last_response.body)

    expect(parsed_body).to be_empty
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
