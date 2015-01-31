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

module Simplify

require 'uri'

# An OAuth access token.
class AccessToken < Hash

    #
    # Construct a AccessToken from a hash.
    #
    def initialize(options = {})
        self.merge!(options)
    end


    # Creates an OAuth access token object.
    #
    # auth_code: The OAuth authentication code.
    # redirect_uri: The OAuth redirection URI.
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.
    #
    def self.create(auth_code, redirect_uri, *auth)

        props = {
                'grant_type' => 'authorization_code',
                'code' => auth_code,
                'redirect_uri' => redirect_uri
        }

        h = Simplify::PaymentsApi.send_auth_request(props, 'token', Simplify::PaymentsApi.create_auth_object(auth))

        obj = AccessToken.new()
        obj = obj.merge!(h)

        obj

    end


    # Refreshes the OAuth access token
    #
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.
    #
    def refresh(*auth)

        rt = self['refresh_token']
        if rt == nil || rt.empty?
            raise ArgumentError.new("Cannot refresh access token; refresh token is invalid.")
        end

        props = {
                'grant_type' => 'refresh_token',
                'refresh_token' => rt
        }

        h = Simplify::PaymentsApi.send_auth_request(props, 'token', Simplify::PaymentsApi.create_auth_object(auth))

        self.merge!(h)
        self
    end


    # Revokes the access token.
    #
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.
    #
    def revoke(*auth)

        token = self['access_token']
        if token == nil || token.empty?
            raise ArgumentError.new("Cannot revoke access token; access token is invalid.")
        end

        props = {
                'token' => token
        }

        h = Simplify::PaymentsApi.send_auth_request(props, 'revoke', Simplify::PaymentsApi.create_auth_object(auth))
        self.clear
        self
    end

end
end
