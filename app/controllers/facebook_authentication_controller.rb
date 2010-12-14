class FacebookAuthenticationController < ApplicationController
  # Step 1.
  def request_access_grant
    redirect_to generate_access_grant_url
  end
    
  # Step 2.
  def callback_point
    authentication_code = params[:code]
    access_token = make_access_token_retrive_request(authentication_code)
    session[:access_token] = access_token
  end
  
  # Step 3-
  def verify_access_token
    @response = generate_verify_uri(session[:access_token]).get
  end

protected

  def generate_access_grant_url
    # Facebook graph api's base
    base_url = "https://graph.facebook.com".to_uri
    # Which rights are granted to application
    application_scope = "publish_stream"
    # Application ID which facebook provides
    application_id = "[FACEBOOK APP ID]"
    # Application Secret which facebook provides
    application_secret = "[FACEBOOK APP SECRET]"
    # Users is redirect to this url after access rights are granted to application
    # Facebook adds authentication code to the uri which is used to retrieve access token
    callback_uri = "http://localhost:3000/facebook_authentication/callback_point?"
    
    request_params = {
      :client_id => application_id,
      :redirect_uri => callback_uri,
      :scope => application_scope
    }
    
    "#{base_url['/oauth/authorize'].uri_string}?#{request_params.to_query}"
  end


  def make_access_token_retrieve_request(auth_code)
    # Facebook graph api's base
    base_url = "https://graph.facebook.com".to_uri
    # Which rights are granted to application
    application_scope = "publish_stream"
    # Application ID which facebook provides
    application_id = "[FACEBOOK APP ID]"
    # Application Secret which facebook provides
    application_secret = "[FACEBOOK APP SECRET]"
    # Users is redirect to this url after access rights are granted to application
    # Facebook adds authentication code to the uri which is used to retrieve access token
    callback_uri = "http://localhost:3000/facebook_authentication/callback_point?"
    
    request_params = {
      :client_id => application_id,
      :redirect_uri => callback_uri,
      :client_secret => application_secret,
      :code => auth_code
    }
    raw_request = base_url['/oauth/access_token'].post_form(request_params)
    parsed_request = Rack::Utils.parse_query(raw_request)
    parsed_request['access_token']
  end

  def generate_verify_uri(access_token)
    # Facebook graph api's base
    base_url = "https://graph.facebook.com".to_uri
    request_params = {
      :access_token => access_token
    }
    "#{base_url['/me'].uri_string}?#{request_params.to_query}".to_uri
  end

end

