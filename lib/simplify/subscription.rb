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

# A Subscription object.
#
class Subscription < Hash

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


    # Creates an Subscription object
    #
    # parms:: a hash of parameters; valid keys are:
    # * <code>amount</code>    Amount of the payment in the smallest unit of your currency. Example: 100 = $1.00USD [min value: 50, max value: 9999900]
    # * <code>coupon</code>    Coupon ID associated with the subscription
    # * <code>currency</code>    Currency code (ISO-4217). Must match the currency associated with your account. [default: USD]
    # * <code>customer</code>    Customer that is enrolling in the subscription.
    # * <code>frequency</code>    Frequency of payment for the plan. Example: Monthly
    # * <code>name</code>    Name describing subscription
    # * <code>plan</code>    The ID of the plan that should be used for the subscription.
    # * <code>quantity</code>    Quantity of the plan for the subscription. [min value: 1]
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns a Subscription object.
    def self.create(parms, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("subscription", 'create', parms, auth_obj)
        obj = Subscription.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj
    end

    # Delete this object
    def delete()
        h = Simplify::PaymentsApi.execute("subscription", 'delete', self, self.authentication)
        self.merge!(h)
        self
    end

    # Retrieve Subscription objects.
    # criteria:: a hash of parameters; valid keys are: 
    # * <code>filter</code>    Filters to apply to the list. 
    # * <code>max</code>    Allows up to a max of 50 list items to return. [max value: 50, default: 20] 
    # * <code>offset</code>    Used in paging of the list.  This is the start offset of the page. [default: 0] 
    # * <code>sorting</code>    Allows for ascending or descending sorting of the list. The value maps properties to the sort direction (either <code>asc</code> for ascending or <code>desc</code> for descending).  Sortable properties are: <code> id</code><code> plan</code>.
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns an object where the <code>list</code> property contains the list of Subscription objects and the <code>total</code>
    # property contains the total number of Subscription objects available for the given criteria.
    def self.list(criteria = nil, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("subscription", 'list', criteria, auth_obj)
        obj = Subscription.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj

    end

    # Retrieve a Subscription object from the API
    #
    # id:: ID of object to retrieve
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns a Subscription object.
    def self.find(id, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("subscription", 'show', {"id" => id}, auth_obj)
        obj = Subscription.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj
    end

    # Updates this object
    #
    # The properties that can be updated:
    # * <code>amount</code> Amount of the payment in the smallest unit of your currency. Example: 100 = $1.00USD [min value: 50, max value: 9999900]
# * <code>coupon</code> Coupon being assigned to this subscription
# * <code>currency</code> Currency code (ISO-4217). Must match the currency associated with your account. [default: USD]
# * <code>frequency</code> Frequency of payment for the plan. Example: Monthly
# * <code>name</code> Name describing subscription
# * <code>plan</code> Plan that should be used for the subscription.
# * <code>prorate</code> Whether to prorate existing subscription. [default: true] <b>(required)</b>
# * <code>quantity</code> Quantity of the plan for the subscription. [min value: 1]
    def update()
          h = Simplify::PaymentsApi.execute("subscription", 'update', self, self.authentication)
          self.merge!(h)
          self
    end

end
end
