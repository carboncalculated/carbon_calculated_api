module CarbonCalculatedApi
  module API
    def self.app
      
      # == Build Version 1 Application
      @version1 ||= Rack::Builder.app do
        use CarbonCalculatedApi::GenericObjectApp
        use CarbonCalculatedApi::AnswerApp
        use CarbonCalculatedApi::ObjectTemplateApp
        run CarbonCalculatedApi::RelatableCategoryApp
      end
      
      @api_mapper ||= Rack::APIVersionMapper.new do |m|
        m.add_version 1, @version1
        m.current_version = 1
      end
    end
    
    class App < Sinatra::Base
      Rack::Mime::MIME_TYPES.delete(".xsl")
      use Rack::AcceptFormat
      
      set :raise_errors, false
      set :show_exceptions, false
      set :logging, true
      
      before do
        response['Content-Type'] = 'application/json'        
      end
      
      # == API KEY AUTHORIZATION
      # @todo refator as poooooo
      before do
        if api_key = params[:api_key] || request_headers["x_ccapikey"]
          if api_user = ApiUser.first(:model_state => "active", :api_key => api_key)
            case ENV["RACK_ENV"]
            when "development"
              
            when "staging"
              throw(:halt, [401, "Not authorized\n"]) unless api_user["staging"]
            when "production"
              throw(:halt, [401, "Not authorized\n"]) unless api_user["production"]
            end
          else
            throw(:halt, [401, "Not authorized\n"])
          end
        else
          throw(:halt, [401, "Not authorized\n"])
        end
      end
      
      # == PAGINATION
      before do
        if params
          @per_page = (params[:per_page] || 50) % 500
          @page = params[:page] || 1
        end
      end
          
      # == Helpers
      helpers do
        def request_headers
          env.inject({}){|acc, (k,v)| acc[$1.downcase] = v if k =~ /^http_(.*)/i; acc}
        end
        
        # @param <Array> resources if the resources can talk pagination then they get a pagination hash back
        # @return <Hash> pagination results 
        def paginate(resources = [])
          if resources.respond_to?(:total_entries)
            {:total_entries => resources.total_entries, :per_page => resources.per_page, :page => resources.current_page}
          else
            {}
          end
        end
      end
            
      # == Global errors
      not_found do
        {:errors => "Resource Not Found"}.to_json
      end
      
      error BSON::InvalidObjectId  do
        {:errors => "Resource Not Found; Invalid Resource Id Format"}.to_json
      end
      
    end 
  end
end



