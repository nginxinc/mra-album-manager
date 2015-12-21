require 'spec_helper.rb'
require_relative '../models/album.rb'

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

    expect(last_response.unauthorized?).to be true
  end

  it 'is up' do
    get '/', nil, auth_headers(a_user_id)

    expect(last_response.ok?)
    expect(last_response.body).to include('Sinatra is up!')
  end

  it 'can create an album' do
    params = {
        album: {
            name: 'name'
        }
    }

    post '/albums', params, auth_headers(a_user_id)

    expect(last_response.ok?)

    album = JSON.parse(last_response.body)

    expect(album['user_id']).to eq(a_user_id)
    expect(album['name']).to eq('name')
  end

  it 'can get an album' do
    album = Album.new
    album.user_id = a_user_id
    album.save!

    get "/albums/#{album.id}", nil, auth_headers(a_user_id)

    expect(last_response.ok?)

    parsed_body = JSON.parse(last_response.body)

    expect(parsed_body['id']).to eq(album.id)
    expect(parsed_body['user_id']).to eq(a_user_id)
  end
end
