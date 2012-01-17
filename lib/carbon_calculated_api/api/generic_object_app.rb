module CarbonCalculatedApi
  class GenericObjectApp < API::App
    
    get '/generic_objects.json' do
      generic_objects = GenericObject.paginate(
        :per_page => @per_page,
        :page => @page
      ) 
      generic_objects_hash = {"generic_objects" => generic_objects.map(&:attributes_for_api_resources)}
      generic_objects_hash.merge!(paginate(generic_objects))
      generic_objects_hash.to_json
    end
        
    get "/generic_objects/:id.json" do |id|
      if generic_object = GenericObject.find(id)
        generic_object.attributes_for_api_resource.to_json
      else
        raise Sinatra::NotFound
      end
    end
  
    get "/generic_objects/:id/formula_inputs.json" do |id|
      if generic_object = GenericObject.find(id)
        {"formula_inputs" => generic_object.formula_inputs}.to_json
      else
        raise Sinatra::NotFound
      end
    end
          
  end
end
