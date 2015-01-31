#
# Copyright (c) 2013, 2014 MasterCard International Incorporated
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are 
# permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice, this list of 
# conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of 
# conditions and the following disclaimer in the documentation and/or other materials 
# provided with the distribution.
# Neither the name of the MasterCard International Incorporated nor the names of its 
# contributors may be used to endorse or promote products derived from this software 
# without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING 
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
# SUCH DAMAGE.
#

require 'rest_client'
require 'base64'
require 'open-uri'
require 'json'
require 'hmac-sha2'
require 'securerandom'
require 'simplify/authentication'
require 'simplify/apiexception'
require 'simplify/constants'
require 'simplify/event'

module Simplify

  @@public_key = nil
  @@private_key = nil
  @@api_base_live_url = Constants::api_base_live_url
  @@api_base_sandbox_url = Constants::api_base_sandbox_url
  @@oauth_base_url = Constants::oauth_base_url
  @@user_agent = nil


  # Returns the value of the public API key.
  def self.public_key
    @@public_key
  end

  # Sets the value of the public API key.
  def self.public_key=(key)
    @@public_key = key
  end

  # Returns the value of the private API key.
  def self.private_key
    @@private_key
  end

  # Sets the value of the private API key.
  def self.private_key=(key)
    @@private_key = key
  end

  # Returns the base URL for the live API.
  def self.api_base_live_url
    @@api_base_live_url
  end

  # Sets the base URL for the live API.
  def self.api_base_live_url=(url)
    @@api_base_live_url = url
  end

  # Returns the base URL for the sandbox API.
  def self.api_base_sandbox_url
    @@api_base_sandbox_url
  end

  # Sets the base URL for the sandbox API.
  def self.api_base_sandbox_url=(url)
    @@api_base_sandbox_url = url
  end

  # Returns the base URL for the OAuth API.
  def self.oauth_base_url
    @@oauth_base_url
  end

  # Sets the base URL for the OAuth API.
  def self.oauth_base_url=(url)
    @@oauth_base_url = url
  end

  # Returns the user agent value sent in requests to the API.
  def self.user_agent
    @@user_agent
  end

  # Sets the value of the user agent sent in requests to the API.
  def self.user_agent=(ua)
    @@user_agent = ua
  end


  class PaymentsApi

    @@JWS_NUM_HEADERS = 7
    @@JWS_ALGORITHM   = 'HS256'
    @@JWS_TYPE        = 'JWS'
    @@JWS_HDR_UNAME   = 'uname'
    @@JWS_HDR_URI            = 'api.simplifycommerce.com/uri'
    @@JWS_HDR_TIMESTAMP      = 'api.simplifycommerce.com/timestamp'
    @@JWS_HDR_NONCE          = 'api.simplifycommerce.com/nonce'
    @@JWS_HDR_TOKEN          = "api.simplifycommerce.com/token";

    @@JWS_TIMESTAMP_MAX_DIFF = 1000 * 60 * 5   # 5 minutes

    @@HTTP_SUCCESS  = 200
    @@HTTP_REDIRECTED = 302
    @@HTTP_UNAUTHORIZED = 401
    @@HTTP_NOT_FOUND = 404
    @@HTTP_NOT_ALLOWED = 405
    @@HTTP_BAD_REQUEST = 400
    @@HTTP_SERVER_ERROR = 500

    def self.create_auth_object(auth)

      case auth.length
          when 0
              auth_obj = Authentication.new(:public_key => Simplify::public_key, :private_key => Simplify::private_key)
          when 1
              auth_obj = auth[0]
              if ! auth_obj.is_a? Authentication
                  raise ArgumentError.new("Invalid Authentication object passed")
              end
          when 2
              # Deprecated case where public and private keys are passed
              public_key = auth[0]
              if public_key == nil
                 public_key = Simplify::public_key
              end
              private_key = auth[1]
              if private_key == nil
                 private_key = Simplify::private_key
              end
              auth_obj = Authentication.new(:public_key => public_key, :private_key => private_key)
          else
              raise ArgumentError.new("Invalid authentication arguments passed")
      end

      return auth_obj
    end

    def self.check_auth(auth)
      if auth == nil
          raise ArgumentError.new("Missing authentication object")
      end

      if auth.public_key == nil
          raise ArgumentError.new("Must have a valid public key to connect to the API")
      end

      if auth.private_key == nil
          raise ArgumentError.new("Must have a valid private key to connect to the API")
      end
    end


    def self.execute(type, action, objectMap, auth)

      check_auth(auth)

      content_type = 'application/json'
      url = build_url(get_base_url(auth.public_key), type, action, objectMap)

      signature = jws_encode(auth, url, objectMap, action == 'update' || action == 'create')

      opts = case action
      when 'show', 'projections' then
      {
        :method => 'GET',
        :headers => { :authorization => "JWS #{signature}" }
      }
      when 'list' then
      {
        :method => 'GET',
        :headers => { :authorization => "JWS #{signature}" }
      }
      when 'update' then
      {
        :method => 'PUT',
        :payload => signature
      }
      when 'create' then
      {
        :method => 'POST',
        :payload => signature
      }
      when 'delete' then
      {
        :method => 'DELETE',
        :headers => { :authorization => "JWS #{signature}" }
      }
      end

      user_agent = "Ruby-SDK/#{Constants::version}"
      if Simplify::user_agent != nil
          user_agent = "#{user_agent} #{Simplify::user_agent}"
      end

      opts = opts.merge({
        :url => url,
        :headers => {
          'Content-Type' => content_type,
          'Accept' => 'application/json',
          'User-Agent' => user_agent
        }.merge(opts[:headers] || {})
      })

      begin
        response = RestClient::Request.execute(opts)
        JSON.parse(response.body)
      rescue RestClient::Exception => e

        begin
           errorData = JSON.parse(e.response.body)
        rescue JSON::ParserError => e2
           raise ApiException.new("Unknown error", nil, nil)
        end

        p "Error: #{e.inspect}"
        if e.response.code == @@HTTP_REDIRECTED
            raise BadRequestException.new("Unexpected response code returned from the API, have you got the correct URL?", e.response.code, errorData)
        elsif e.response.code == @@HTTP_BAD_REQUEST
            raise BadRequestException.new("Bad request", e.response.code, errorData)
        elsif e.response.code == @@HTTP_UNAUTHORIZED
            raise AuthenticationException.new("You are not authorized to make this request.  Are you using the correct API keys?", e.response.code, errorData)
        elsif e.response.code == @@HTTP_NOT_FOUND
            raise ObjectNotFoundException.new("Object not found", e.response.code, errorData)
        elsif e.response.code == @@HTTP_NOT_ALLOWED
            raise NotAllowedException.new("Operation not allowed", e.response.code, errorData)
        elsif e.response.code < @@HTTP_SERVER_ERROR
            raise BadRequestException.new("Bad request", e.response.code, errorData)
        else
            raise SystemException.new("An unexpected error has been raised.  Looks like there's something wrong at our end.", e.response.code, errorData)
        end
      end
    end


    def self.send_auth_request(props, context, auth)

      check_auth(auth)

      content_type = 'application/json'

      url = "#{Simplify::oauth_base_url}/#{context}"

      signature = oauth_jws_encode(auth, url, props)

      opts = {
        :method => 'POST',
        :payload => signature
      }

      user_agent = "Ruby-SDK/#{Constants::version}"
      if Simplify::user_agent != nil
          user_agent = "#{user_agent} #{Simplify::user_agent}"
      end

      opts = opts.merge({
        :url => url,
        :headers => {
          'Content-Type' => content_type,
          'Accept' => 'application/json',
          'User-Agent' => user_agent
        }.merge(opts[:headers] || {})
      })

      begin
        response = RestClient::Request.execute(opts)
        JSON.parse(response.body)
      rescue RestClient::Exception => e

        begin
           errorData = JSON.parse(e.response.body)
        rescue JSON::ParserError => e2
           raise ApiException.new("Unknown error", nil, nil)
        end

        if e.response.code == @@HTTP_REDIRECTED
            raise BadRequestException.new("Unexpected response code returned from the API, have you got the correct URL?", e.response.code, {})
        elsif e.response.code >= @@HTTP_BAD_REQUEST and e.response.code < @@HTTP_SERVER_ERROR
            error_code = errorData['error']
            error_desc = errorData['error_description']
            if (error_code == 'invalid_request')
                raise BadRequestException.new("", e.response.code, get_oauth_error("Error during OAuth request", error_code, error_desc))
            elsif (error_code == 'access_denied')
                raise AuthenticationException.new("", e.response.code, get_oauth_error("Access denied for OAuth request", error_code, error_desc))
            elsif (error_code == 'invalid_client')
                raise AuthenticationException.new("", e.response.code, get_oauth_error("Invalid client ID in OAuth request", error_code, error_desc))
            elsif (error_code == 'unauthorized_client')
                raise AuthenticationException.new("", e.response.code, get_oauth_error("Unauthorized client in OAuth request", error_code, error_desc))
            elsif (error_code == 'unsupported_grant_type')
                raise BadRequestException.new("", e.response.code, get_oauth_error("Unsupported grant type in OAuth request", error_code, error_desc))
            elsif (error_code == 'invalid_scope')
                raise BadRequestException.new("", e.response.code, get_oauth_error("Invalid scope in OAuth request", error_code, error_desc))
            else
                raise BadRequestException.new("", e.response.code, get_oauth_error("Unknown OAuth error", error_code, error_desc))
            end
        else
            raise SystemException.new("An unexpected error has been raised.  Looks like there's something wrong at our end.", e.response.code, nil)
        end
      end

    end

    def self.get_oauth_error(msg, error_code, error_desc)
        error_data = {'error' => {'code' => 'oauth_error', 'message' => "#{msg}, error code '#{error_code}', description '#{error_desc}'"}}
    end

    def self.build_url(base_url, type, action, objectMap)
      parts = []
      parts << base_url
      parts << type
      parts << case action
      when 'show', 'update', 'delete' then
        [URI::encode(objectMap["id"].to_s)]

      end
      url = parts.flatten().join('/')

      query = Array.new

      if action == "list" and objectMap != nil then

         if (objectMap['max'])
            query << "max=#{objectMap['max']}"
         end
         if (objectMap['offset'])
            query << "offset=#{objectMap['offset']}"
         end
         if (objectMap['sorting']) then
            objectMap['sorting'].each { |k, v|
               query << "sorting[#{URI::encode(k.to_s)}]=#{URI::encode(v.to_s)}"
            }
         end
         if (objectMap['filter']) then
            objectMap['filter'].each { |k, v|
               query << "filter[#{URI::encode(k.to_s)}]=#{URI::encode(v.to_s)}"
            }
         end
      end

      if query.size > 0 then
          url = url + "?" + query.join('&')
      end

      return url
    end

    def self.get_base_url(public_key)

        if live_key?(public_key)
            return Simplify::api_base_live_url
        end
        return Simplify::api_base_sandbox_url

    end

    def self.jws_encode(auth, url, objectMap, hasPayload)

        jws_hdr = {'typ' => @@JWS_TYPE,
                   'alg' => @@JWS_ALGORITHM,
                   'kid' => auth.public_key,
		            @@JWS_HDR_URI => url,
		            @@JWS_HDR_TIMESTAMP => Time.now.to_i * 1000,
       		        @@JWS_HDR_NONCE => SecureRandom.hex }

        token = auth.access_token
        if token != nil && !token.empty?
            jws_hdr[@@JWS_HDR_TOKEN] = token
        end

        hdr = urlsafe_encode64(jws_hdr.to_json)

        payload = ''
        if (hasPayload) then
            payload = urlsafe_encode64(objectMap.to_json)
        end

        msg = hdr + '.' + payload
        return msg + '.' + jws_sign(auth.private_key, msg)

    end

    def self.oauth_jws_encode(auth, url, props)

        jws_hdr = {'typ' => @@JWS_TYPE,
                   'alg' => @@JWS_ALGORITHM,
                   'kid' => auth.public_key,
		            @@JWS_HDR_URI => url,
		            @@JWS_HDR_TIMESTAMP => Time.now.to_i * 1000,
       		        @@JWS_HDR_NONCE => SecureRandom.hex }

        hdr = urlsafe_encode64(jws_hdr.to_json)

        msg = hdr + '.' + urlsafe_encode64(props.map{|k,v| "#{k}=#{v}"}.join('&'))

        return msg + '.' + jws_sign(auth.private_key, msg)

    end

    def self.jws_decode(params, auth)

      check_auth(auth)

      payload = params['payload']
      if payload == nil 
           raise ArgumentError.new("Event data is missing payload")
      end 

	  begin
      
        payload.strip!     
	    data = payload.split('.')
        if data.size != 3
            jws_auth_error("Incorrectly formatted JWS message");
        end

	    msg = "#{data[0]}.#{data[1]}"
	    header = urlsafe_decode64(data[0])
	    payload = urlsafe_decode64(data[1])

	    jws_verify_header(header, params['url'], auth.public_key)
	    if !jws_verify_signature(auth.private_key, msg, data[2])
	       jws_auth_error("JWS signature does not match")
	    end
	    
	    return JSON.parse(payload)

	  resue Exception => e
	      jws_auth_error("Exception during JWS decoding: #{e}")
	  end

	  jws_auth_error("JWS decode failed")
    end

    def self.jws_sign(private_key, msg)
        urlsafe_encode64(HMAC::SHA256.digest(Base64.decode64(private_key), msg))
    end


    def self.jws_verify_header(header, url, public_key)

	    hdr = JSON.parse(header)

	    if hdr.size != @@JWS_NUM_HEADERS
		    jws_auth_error("Incorrect number of JWS header parameters - found #{hdr.size} required #{@@JWS_NUM_HEADERS}")
	    end

	    if hdr['alg'] != @@JWS_ALGORITHM
		    jws_auth_error("Incorrect algorithm - found #{hdr['alg']} required #{@@JWS_ALGORITHM}")
	    end

	    if hdr['typ'] != @@JWS_TYPE
		    jws_auth_error("Incorrect type - found #{hdr['typ']} required #{@@JWS_TYPE}")
	    end

	    if hdr['kid'] == nil
		    jws_auth_error("Missing Key ID")
	    end

	    if hdr['kid'] != public_key
	        if live_key?(public_key)
	            jws_auth_error("Invalid Key ID")
 		    end
	    end

	    if hdr[@@JWS_HDR_URI] == nil
		    jws_auth_error("Missing URI")
	    end

	    if url != nil && hdr[@@JWS_HDR_URI] != url
	        jws_auth_error("Incorrect URL - found #{hdr[@@JWS_HDR_URI]} required #{url}")
	    end

	    if hdr[@@JWS_HDR_TIMESTAMP] == nil
		    jws_auth_error("Missing timestamp")
	    end

	    if !jws_verify_timestamp(hdr[@@JWS_HDR_TIMESTAMP])
		    jws_auth_error("Invalid timestamp")
	    end

	    if hdr[@@JWS_HDR_NONCE] == nil
		    jws_auth_error("Missing nonce")
	    end

	    if hdr[@@JWS_HDR_UNAME] == nil
		    jws_auth_error("Missing username header")
	    end
    end

    def self.jws_verify_signature(private_key, msg, crypto)
        return crypto == jws_sign(private_key, msg)
    end


    def self.jws_verify_timestamp(ts)
    	return (Time.now.to_i * 1000 - ts.to_i).abs < @@JWS_TIMESTAMP_MAX_DIFF
    end

    def self.jws_auth_error(reason)
	    raise AuthenticationException.new("JWS authentication failure: #{reason}", nil, nil)
    end

    def self.live_key?(public_key)
    	return public_key.start_with?("lvpb")
    end

    # Base64.urlsafe_encode64()/urlsafe_decode64() is not available in ruby 1.8
    def self.urlsafe_encode64(s)
        return Base64::encode64(s).gsub(/\n/, '').gsub('+', '-').gsub('/', '_').gsub('=', '')
    end

    def self.urlsafe_decode64(s)
    	# Put back padding
    	case (s.size % 4)
	       when 0
	       when 2
            s = s + "=="
	       when 3
	        s = s + "="
	       else raise ArgumentError.new("Webhook event data incorrectly formatted", nil, nil)
	    end
        return Base64::decode64(s.gsub('-','+').gsub('_','/'))
    end

  end
end
