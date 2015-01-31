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

# A Invoice object.
#
class Invoice < Hash

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


    # Creates an Invoice object
    #
    # parms:: a hash of parameters; valid keys are:
    # * <code>currency</code>    Currency code (ISO-4217). Must match the currency associated with your account. [max length: 3, min length: 3, default: USD]
    # * <code>customer</code>    The customer ID of the customer we are invoicing.  This is optional is a name and email are provided
    # * <code>discountRate</code>    The discount percent as a decimal e.g. 12.5.  This is used to calculate the discount amount which is subtracted from the total amount due before any tax is applied. [max length: 6]
    # * <code>dueDate</code>    The date invoice payment is due.  If a late fee is provided this will be added to the invoice total is the due date has past.
    # * <code>email</code>    The email of the customer we are invoicing.  This is optional if a customer id is provided.  A new customer will be created using the the name and email.
    # * <code>invoiceId</code>    User defined invoice id. If not provided the system will generate a numeric id. [max length: 255]
    # * <code>items => amount</code>    Amount of the invoice item (the smallest unit of your currency). Example: 100 = $1.00USD [min value: 1, max value: 9999900] <b>required </b>
    # * <code>items => description</code>    The description of the invoice item. [max length: 1024]
    # * <code>items => invoice</code>    The ID of the invoice this item belongs to.
    # * <code>items => product</code>    The product this invoice item refers to. <b>required </b>
    # * <code>items => quantity</code>    Quantity of the item.  This total amount of the invoice item is the amount * quantity. [min value: 1, max value: 999999, default: 1]
    # * <code>items => reference</code>    User defined reference field. [max length: 255]
    # * <code>items => tax</code>    The tax ID of the tax charge in the invoice item.
    # * <code>lateFee</code>    The late fee amount that will be added to the invoice total is the due date is past due.  Value provided must be in the smallest unit of your currency. Example: 100 = $1.00USD [max value: 9999900]
    # * <code>memo</code>    A memo that is displayed to the customer on the invoice payment screen. [max length: 4000]
    # * <code>name</code>    The name of the customer we are invoicing.  This is optional if a customer id is provided.  A new customer will be created using the the name and email. [max length: 50, min length: 2]
    # * <code>note</code>    This field can be used to store a note that is not displayed to the customer. [max length: 4000]
    # * <code>reference</code>    User defined reference field. [max length: 255]
    # * <code>shippingAddressLine1</code>    Address Line 1 where the product should be shipped. [max length: 255]
    # * <code>shippingAddressLine2</code>    Address Line 2 where the product should be shipped. [max length: 255]
    # * <code>shippingCity</code>    City where the product should be shipped. [max length: 255, min length: 2]
    # * <code>shippingCountry</code>    Country where the product should be shipped. [max length: 2, min length: 2]
    # * <code>shippingState</code>    State where the product should be shipped. [max length: 2, min length: 2]
    # * <code>shippingZip</code>    ZIP code where the product should be shipped. [max length: 9, min length: 5]
    # * <code>type</code>    The type of invoice.  One of WEB or MOBILE. [valid values: WEB, MOBILE, default: WEB]
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns a Invoice object.
    def self.create(parms, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("invoice", 'create', parms, auth_obj)
        obj = Invoice.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj
    end

    # Delete this object
    def delete()
        h = Simplify::PaymentsApi.execute("invoice", 'delete', self, self.authentication)
        self.merge!(h)
        self
    end

    # Retrieve Invoice objects.
    # criteria:: a hash of parameters; valid keys are: 
    # * <code>filter</code>    Filters to apply to the list. 
    # * <code>max</code>    Allows up to a max of 50 list items to return. [max value: 50, default: 20] 
    # * <code>offset</code>    Used in paging of the list.  This is the start offset of the page. [default: 0] 
    # * <code>sorting</code>    Allows for ascending or descending sorting of the list. The value maps properties to the sort direction (either <code>asc</code> for ascending or <code>desc</code> for descending).  Sortable properties are: <code> id</code><code> invoiceDate</code><code> dueDate</code><code> datePaid</code><code> customer</code><code> status</code>.
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns an object where the <code>list</code> property contains the list of Invoice objects and the <code>total</code>
    # property contains the total number of Invoice objects available for the given criteria.
    def self.list(criteria = nil, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("invoice", 'list', criteria, auth_obj)
        obj = Invoice.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj

    end

    # Retrieve a Invoice object from the API
    #
    # id:: ID of object to retrieve
    # auth:: Authentication information used for the API call.  If no value is passed the global keys Simplify::public_key and Simplify::private_key are used.  For backwards compatibility the public and private keys may be passed instead of the authentication object.
    # Returns a Invoice object.
    def self.find(id, *auth)

        auth_obj = Simplify::PaymentsApi.create_auth_object(auth)
        h = Simplify::PaymentsApi.execute("invoice", 'show', {"id" => id}, auth_obj)
        obj = Invoice.new()
        obj.authentication = auth_obj
        obj = obj.merge!(h)
        obj
    end

    # Updates this object
    #
    # The properties that can be updated:
    # * <code>datePaid</code> This is the date the invoice was PAID in UTC millis.
# * <code>discountRate</code> The discount percent as a decimal e.g. 12.5.  This is used to calculate the discount amount which is subtracted from the total amount due before any tax is applied. [max length: 6]
# * <code>dueDate</code> The date invoice payment is due.  If a late fee is provided this will be added to the invoice total is the due date has past.
# * <code>items => amount</code> Amount of the invoice item in the smallest unit of your currency. Example: 100 = $1.00USD [min value: 1, max value: 9999900] <b>(required)</b>
# * <code>items => description</code> The description of the invoice item. [max length: 1024]
# * <code>items => invoice</code> The ID of the invoice this item belongs to.
# * <code>items => product</code> The Id of the product this item refers to. <b>(required)</b>
# * <code>items => quantity</code> Quantity of the item.  This total amount of the invoice item is the amount * quantity. [min value: 1, max value: 999999, default: 1]
# * <code>items => reference</code> User defined reference field. [max length: 255]
# * <code>items => tax</code> The tax ID of the tax charge in the invoice item.
# * <code>lateFee</code> The late fee amount that will be added to the invoice total is the due date is past due.  Value provided must be in the smallest unit of your currency. Example: 100 = $1.00USD
# * <code>memo</code> A memo that is displayed to the customer on the invoice payment screen. [max length: 4000]
# * <code>note</code> This field can be used to store a note that is not displayed to the customer. [max length: 4000]
# * <code>payment</code> The ID of the payment.  Use this ID to query the /payment API. [max length: 255]
# * <code>reference</code> User defined reference field. [max length: 255]
# * <code>shippingAddressLine1</code> The shipping address line 1 for the product. [max length: 255]
# * <code>shippingAddressLine2</code> The shipping address line 2 for the product. [max length: 255]
# * <code>shippingCity</code> The shipping city for the product. [max length: 255, min length: 2]
# * <code>shippingCountry</code> The shipping country for the product. [max length: 2, min length: 2]
# * <code>shippingState</code> The shipping state for the product. [max length: 2, min length: 2]
# * <code>shippingZip</code> The shipping ZIP code for the product. [max length: 9, min length: 5]
# * <code>status</code> New status of the invoice.
    def update()
          h = Simplify::PaymentsApi.execute("invoice", 'update', self, self.authentication)
          self.merge!(h)
          self
    end

end
end
