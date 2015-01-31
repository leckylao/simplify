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


  # Base class for all API exceptions.
  class ApiException < Exception

      # HTML status code (or nil if there is no status code)
      attr_reader :status

      # Error data returned from the API represented as a map.
      attr_reader :errorData

      # Unique reference ID for the API error.
      attr_reader :reference

      # API code for the error.
      attr_reader :errorCode

      # Description of the error.
      attr_reader :errorMessage

      def initialize(message, status, errorData)
        super(message)

        @status = status
        @errorMessage = message        
        @fieldErrors = []
        if errorData != nil
          @errorData = errorData
          @reference = errorData.has_key?('reference') ? errorData['reference'] : nil

          if errorData.has_key?('error')
              error = errorData['error']
              @errorCode = error['code']
              if error.has_key?('message')
                  message = error['message']
              end
          end
        end
        super(message)
      end

      # Returns a string descrption of the error.
      def describe()
        return "#{self.class}: \"#{self.to_s()}\" (status: #{@status}, error code #{@errorCode}, reference: #{@reference})"
      end
    
    end

    # Exception representing API authentication errors.
    class AuthenticationException < ApiException
    end


    # Exception representing invalid requests made to the API.
    class BadRequestException < ApiException 


      # A single error on a field of an API request.
      class FieldError 


        # The name of the field with the error.
        attr_reader :fieldName

        # The code for the field error.
        attr_reader :errorCode

        # Description of the error.
        attr_reader :message

        def initialize(errorData)
            @fieldName = errorData['field']
            @errorCode = errorData['code']
            @message = errorData['message']        
        end

        # Returns string representation of the error.
        def to_s()
            return "Field error: #{@fieldName} \"#{@message}\" (#{@errorCode})"
        end
      end

      # List of field errors associatied with this error (empty if there are no field errors).
      attr_reader :fieldErrors

      alias :super_describe :describe

      def initialize(message, status, errorData)

        super(message, status, errorData)

        @fieldErrors = []
        if errorData.has_key?('error')
            error = errorData['error']
            if error.has_key?('fieldErrors')
                fieldErrors = error['fieldErrors']
                fieldErrors.each do |fieldError|
                    @fieldErrors << FieldError.new(fieldError)
                end
            end
        end
      end

      # Returns boolean indicating if there are field errors associated with this API error.
      def hasFieldErrors?
          return @fieldErrors.length > 1
      end

      # Returns a string description of the error including any field errors.
      def describe()      
        s = super_describe()
        @fieldErrors.each do |fieldError|
            s = s + "\n" + fieldError.to_s
        end
        return s + "\n"
      end

    end

    # Exception representing a object not found for an API request.
    class ObjectNotFoundException < ApiException
    end

    # Exception representing an invalid operation request.
    class NotAllowedException < ApiException
    end

    # Exception representing a system error during processing of an API request.
    class SystemException < ApiException
    end

end