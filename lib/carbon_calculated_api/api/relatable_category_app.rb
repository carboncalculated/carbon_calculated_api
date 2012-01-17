module CarbonCalculatedApi
  class RelatableCategoryApp < API::App
          
    get "/relatable_categories/related_objects.json" do
      @relatable_categories, @template_name = params[:relatable_category_ids], params[:template_name]
      if @relatable_categories && @template_name
        @related_objects = RelatableCategory.related_objects_from_relatable_category_ids(@template_name, @relatable_categories)
        {"related_objects" => @related_objects}.to_json
      else
        throw :halt, [412, "Params: either relatable_category_ids or template_name was not given"]
      end
    end
    
    get "/relatable_categories/:id.json" do |id|
      if relatable_category = RelatableCategory.find(id)
        relatable_category.attributes_for_api_resource.to_json
      else
        raise Sinatra::NotFound
      end
    end
    
    get "/relatable_categories.json" do
      relatable_categories = RelatableCategory.paginate({:per_page => @per_page, :page => @page})
      relatable_categories_hash = {"relatable_categories" => relatable_categories.map(&:attributes_for_api_resources)}
      relatable_categories_hash.merge!(paginate(relatable_categories))
      relatable_categories_hash.to_json
    end
    
    get "/relatable_categories/:id/related_categories.json" do |id|
      if @related_attribute = params[:related_attribute]
        if @relatable_category = RelatableCategory.find(id)
          if relatable_category_ids = params[:relatable_category_ids]
            @relatable_categories = RelatableCategory.relatable_categories_from_intersected(@relatable_category,@related_attribute, relatable_category_ids)
            {"related_categories" => @relatable_categories}.to_json
          else
            @relatable_categories = @relatable_category.related_categories[@related_attribute]
            {"related_categories" => @relatable_categories}.to_json
          end
        else
          raise Sinatra::NotFound
        end
      else
        throw :halt, [412, "Params: related_attribute was not given"]
      end
    end
    
  end
end
