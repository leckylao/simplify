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

# A InvoiceItem object.
#
class InvoiceItem < Hash

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


    # Creates an InvoiceItem object
    #
    # parms:: a hash of parameters; valid keys are:
    # * <code>amount</code>    Amount of the invoice item in the smallest unit of your currency. Example: 100 = $1.00USD [min value: 1, max value: 9999900] <b>required </b>
    # * <code>description</code>    Individual items of an invoice [max length: 1024]
    # * <code>invoice</code>    The ID of the invoice this item belongs to.
    # * <code>product</code>    Product ID this item relates to. <b>required </b>
    # * <code>quantity</code>    Quantity of the item.  This total amount of the invoice item is the amount * quantity. [min value: 1, max value: 999999, default: 1]
    # * <code>reference</code>    User defined reference field. [max length: 255]
    # * <code>tax</code>    The tax ID of the tax charge in the invoice item.
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns a InvoiceItem object.
    def self.create(parms, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("invoiceItem", 'create', parms, auth_obj)
        obj = InvoiceItem.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj
    end

    # Delete this object
    def delete()
        h = Simplify::PaymentsApi.execute("invoiceItem", 'delete', self, self.authentication)
        self.merge!(h)
        self
    end

    # Retrieve a InvoiceItem object from the API
    #
    # id:: ID of object to retrieve
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns a InvoiceItem object.
    def self.find(id, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("invoiceItem", 'show', {"id" => id}, auth_obj)
        obj = InvoiceItem.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj
    end

    # Updates this object
    #
    # The properties that can be updated:
    # * <code>amount</code> Amount of the invoice item in the smallest unit of your currency. Example: 100 = $1.00USD [min value: 1, max value: 9999900]
# * <code>description</code> Individual items of an invoice
# * <code>quantity</code> Quantity of the item.  This total amount of the invoice item is the amount * quantity. [min value: 1, max value: 999999]
# * <code>reference</code> User defined reference field.
# * <code>tax</code> The tax ID of the tax charge in the invoice item.
    def update()
          h = Simplify::PaymentsApi.execute("invoiceItem", 'update', self, self.authentication)
          self.merge!(h)
          self
    end

end
end
