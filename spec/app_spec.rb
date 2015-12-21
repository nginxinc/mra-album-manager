require 'spec_helper.rb'

describe 'User manager' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def user_id
    'this-is-my-uuid'
  end

  it 'returns a 401 if no user id is passed' do
    get '/'

    expect(last_response.unauthorized?).to be true
  end

  it 'is up' do
    get '/', nil, {'HTTP_AUTH_ID' => user_id}

    expect(last_response.ok?)
    expect(last_response.body).to include('Sinatra is up!')
  end
end
