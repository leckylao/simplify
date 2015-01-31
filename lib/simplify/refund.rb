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

# A Refund object.
#
class Refund < Hash

    # Authentication object used to access the API (See Simplify::Authentication for details)
    attr_accessor :authentication

    # Returns the public key used when accessing this object. <b>Deprecated: please use 'authentication' instead.</b>
    def public_key
        return self.authentication.public_key
    end

    # Sets the public key used when accessing this object. <b>Deprecated: please use 'authentication' instead.</b>
    def public_key=(k)
        return self.authentication.public_key = k
    end

    # Returns the private key used when accessing this object. <b>Deprecated: please use 'authentication' instead.</b>
    def private_key
        return self.authentication.private_key
    end

    # Sets the private key used when accessing this object. <b>Deprecated: please use 'authentication' instead.</b>
    def private_key=(k)
        return self.authentication.private_key = k
    end


    # Creates an Refund object
    #
    # parms:: a hash of parameters; valid keys are:
    # * <code>amount</code>    Amount of the refund in the smallest unit of your currency. Example: 100 = $1.00USD [min value: 1, max value: 9999900] <b>required </b>
    # * <code>payment</code>    ID of the payment for the refund <b>required </b>
    # * <code>reason</code>    Reason for the refund
    # * <code>reference</code>    Custom reference field to be used with outside systems.
    # * <code>replayId</code>    An identifier that can be sent to uniquely identify a refund request to facilitate retries due to I/O related issues. This identifier must be unique for your account (sandbox or live) across all of your refunds. If supplied, we will check for a refund on your account that matches this identifier. If found we will return an identical response to that of the original request. [max length: 50, min length: 1]
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns a Refund object.
    def self.create(parms, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("refund", 'create', parms, auth_obj)
        obj = Refund.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj
    end

    # Retrieve Refund objects.
    # criteria:: a hash of parameters; valid keys are: 
    # * <code>filter</code>    Filters to apply to the list. 
    # * <code>max</code>    Allows up to a max of 50 list items to return. [max value: 50, default: 20] 
    # * <code>offset</code>    Used in paging of the list.  This is the start offset of the page. [default: 0] 
    # * <code>sorting</code>    Allows for ascending or descending sorting of the list. The value maps properties to the sort direction (either <code>asc</code> for ascending or <code>desc</code> for descending).  Sortable properties are: <code> id</code><code> amount</code><code> description</code><code> dateCreated</code><code> paymentDate</code>.
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns an object where the <code>list</code> property contains the list of Refund objects and the <code>total</code>
    # property contains the total number of Refund objects available for the given criteria.
    def self.list(criteria = nil, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("refund", 'list', criteria, auth_obj)
        obj = Refund.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj

    end

    # Retrieve a Refund object from the API
    #
    # id:: ID of object to retrieve
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns a Refund object.
    def self.find(id, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("refund", 'show', {"id" => id}, auth_obj)
        obj = Refund.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj
    end

end
end
