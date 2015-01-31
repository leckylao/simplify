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

require 'simplify/paymentsapi'

module Simplify

# An Event object
class Event < Hash

    # Creates a webhook Event object
    #
    # params:: a hash of parameters; valid keys are:
    # * <code>payload</code>  The raw JWS message payload.  <b>required</b>
    # * <code>url</code> The URL for the webhook.  If present it must match the URL registered for the webhook.
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    #
    def self.create(params, *auth)

  	    h = Simplify::PaymentsApi.jws_decode(params, Simplify::PaymentsApi.create_auth_object(auth))

	    if !h['event']
	        raise ApiException.new("Incorrect data in webhook event", nil, nil)
	    end

	    obj = Event.new()
	    obj = obj.merge!(h['event'])

	    obj
    end

end
end
