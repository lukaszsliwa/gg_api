module GGApi

  class GGApiException < Exception
    def self.from(exception)
      if exception.respond_to?(:response)
        response = exception.response
      else
        return GGApiException.new(exception.to_s)
      end
      case response.status
        when 400
          GGApiBadRequestException.new(exception.to_s)
        when 401
          GGApiUnauthorizedException.new(exception.to_s)
        when 403
          GGApiUnauthorizedException.new(exception.to_s)
        when 404
          GGApiNotFoundException.new(exception.to_s)
        when 500
          GGApiInternalServerErrorException.new(exception.to_s)
      else
        GGApiException.new(exception.to_s)
      end
    end
  end

  class GGApiParseException < GGApiException; end
  class GGApiUnauthorizedException < GGApiException; end
  class GGApiForbiddenException < GGApiException; end
  class GGApiBadRequestException < GGApiException; end
  class GGApiNotFoundException < GGApiException; end
  class GGApiInternalServerErrorException < GGApiException; end
end
