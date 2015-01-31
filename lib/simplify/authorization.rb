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

# A Authorization object.
#
class Authorization < Hash

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


    # Creates an Authorization object
    #
    # parms:: a hash of parameters; valid keys are:
    # * <code>amount</code>    Amount of the payment (in the smallest unit of your currency). Example: 100 = $1.00USD [min value: 50, max value: 9999900] <b>required </b>
    # * <code>card => addressCity</code>    City of the cardholder. [max length: 50, min length: 2]
    # * <code>card => addressCountry</code>    Country code (ISO-3166-1-alpha-2 code) of residence of the cardholder. [max length: 2, min length: 2]
    # * <code>card => addressLine1</code>    Address of the cardholder. [max length: 255]
    # * <code>card => addressLine2</code>    Address of the cardholder if needed. [max length: 255]
    # * <code>card => addressState</code>    State code (USPS code) of residence of the cardholder. [max length: 2, min length: 2]
    # * <code>card => addressZip</code>    Postal code of the cardholder. The postal code size is between 5 and 9 characters in length and only contains numbers or letters. [max length: 9, min length: 3]
    # * <code>card => cvc</code>    CVC security code of the card. This is the code on the back of the card. Example: 123
    # * <code>card => expMonth</code>    Expiration month of the card. Format is MM. Example: January = 01 [min value: 1, max value: 12] <b>required </b>
    # * <code>card => expYear</code>    Expiration year of the card. Format is YY. Example: 2013 = 13 [max value: 99] <b>required </b>
    # * <code>card => name</code>    Name as it appears on the card. [max length: 50, min length: 2]
    # * <code>card => number</code>    Card number as it appears on the card. [max length: 19, min length: 13] <b>required </b>
    # * <code>currency</code>    Currency code (ISO-4217) for the transaction. Must match the currency associated with your account. [default: USD] <b>required </b>
    # * <code>customer</code>    ID of customer. If specified, card on file of customer will be used.
    # * <code>description</code>    Free form text field to be used as a description of the payment. This field is echoed back with the payment on any find or list operations. [max length: 1024]
    # * <code>reference</code>    Custom reference field to be used with outside systems.
    # * <code>replayId</code>    An identifier that can be sent to uniquely identify a payment request to facilitate retries due to I/O related issues. This identifier must be unique for your account (sandbox or live) across all of your payments. If supplied, we will check for a payment on your account that matches this identifier, and if one is found we will attempt to return an identical response of the original request. [max length: 50, min length: 1]
    # * <code>token</code>    If specified, card associated with card token will be used. [max length: 255]
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns a Authorization object.
    def self.create(parms, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("authorization", 'create', parms, auth_obj)
        obj = Authorization.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj
    end

    # Delete this object
    def delete()
        h = Simplify::PaymentsApi.execute("authorization", 'delete', self, self.authentication)
        self.merge!(h)
        self
    end

    # Retrieve Authorization objects.
    # criteria:: a hash of parameters; valid keys are: 
    # * <code>filter</code>    Filters to apply to the list. 
    # * <code>max</code>    Allows up to a max of 50 list items to return. [max value: 50, default: 20] 
    # * <code>offset</code>    Used in pagination of the list. This is the start offset of the page. [default: 0] 
    # * <code>sorting</code>    Allows for ascending or descending sorting of the list. The value maps properties to the sort direction (either <code>asc</code> for ascending or <code>desc</code> for descending).  Sortable properties are: <code> dateCreated</code><code> amount</code><code> id</code><code> description</code><code> paymentDate</code>.
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns an object where the <code>list</code> property contains the list of Authorization objects and the <code>total</code>
    # property contains the total number of Authorization objects available for the given criteria.
    def self.list(criteria = nil, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("authorization", 'list', criteria, auth_obj)
        obj = Authorization.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj

    end

    # Retrieve a Authorization object from the API
    #
    # id:: ID of object to retrieve
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns a Authorization object.
    def self.find(id, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("authorization", 'show', {"id" => id}, auth_obj)
        obj = Authorization.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj
    end

end
end
