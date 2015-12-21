require 'spec_helper.rb'

describe 'User manager' do
  def a_user_id
    'a_user_id'
  end

  def a_different_user_id
    'a_different_user_id'
  end

  it 'returns a 401 if no user id is passed' do
    get '/'

    expect(last_response.unauthorized?).to be true
  end

  it 'is up' do
    get '/', nil, {'HTTP_AUTH_ID' => a_user_id}

    expect(last_response.ok?)
    expect(last_response.body).to include('Sinatra is up!')
  end
end
