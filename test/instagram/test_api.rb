
require 'rest-more/test'

describe RC::Instagram do
  after do
    WebMock.reset!
  end

  json = <<-JSON
    {"meta":{"code":200},
     "data":[{"username":"restmore",
              "profile_picture":"http://images.ak.instagram.com/profile.jpg",
              "full_name":"Rest More", "id":"123"}],
     "access_token":"A"}
  JSON

  client = RC::Instagram.new(:client_id => 'Z', :client_secret => 'S',
                             :access_token => 'X')

  should 'have correct authorize url' do
    client.authorize_url.should.eq \
      'https://api.instagram.com/oauth/authorize?' \
      'client_id=Z&response_type=code'
  end

  should 'authorize! and get the access token' do
    stub_request(:post, 'https://api.instagram.com/oauth/access_token').
      with(:body => {'client_id' => 'Z', 'client_secret' => 'S',
                     'grant_type' => 'authorization_code', 'code' => 'C'}).
      to_return(:body => json)

    begin
      client.authorize!(:code => 'C').should.kind_of?(Hash)
      client.access_token.            should.eq 'A'
    ensure
      client.data = nil
    end
  end

  should 'retrieve user profile based on username' do
    stub_request(:get, 'https://api.instagram.com/v1/users/search?' \
                       'client_id=Z&q=restmore').
      to_return(:body => json)

    client.get('v1/users/search', :q => 'restmore').should.eq(
      {'meta' => {'code' => 200},
       'data' => [{'username' => 'restmore',
                   'profile_picture' =>
                      'http://images.ak.instagram.com/profile.jpg',
                   'full_name' => 'Rest More',
                   'id' => '123'}],
       'access_token' => 'A'})
  end
end
