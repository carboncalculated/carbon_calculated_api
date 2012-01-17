module CarbonCalculatedApi
  class ObjectTemplateApp < API::App
    
    get "/object_templates/:id.json" do |id|
      if object_template = ObjectTemplate.find(id)
        object_template.attributes_for_api_resource.to_json
      else
        raise Sinatra::NotFound
      end
    end
    
    get "/object_templates.json" do
      object_templates = ObjectTemplate.paginate(:per_page => @per_page, :page => @page)
      object_template_hash = {"object_templates" => object_templates.map(&:attributes_for_api_resources)}
      object_template_hash.merge!(paginate(object_templates))
      object_template_hash.to_json
    end
    
    get "/object_templates/:name/generic_objects.json" do |name|
      name = name.downcase
      if @template = ObjectTemplate.first(:name => name)
        if !params[:filter_attribute] && !params[:filter_value]
        @generic_objects = @template.generic_objects.paginate(
          :per_page => @per_page, :page => @page)
        else
          @generic_objects = @template.generic_objects.paginate(
            :per_page => @per_page, :page => @page,
            "relatable_characteristics" => {"$elemMatch" => {:attribute => params[:filter_attribute], :value => params[:filter_value]}}
          )
        end
        template_hash = @template.attributes_for_api_resource
        template_hash["object_template"]["generic_objects"] = @generic_objects.map(&:attributes_for_api_resources)
        template_hash.merge!(paginate(@generic_objects))
        template_hash.to_json
      else
        raise Sinatra::NotFound
      end
    end
    
    get "/object_templates/:name/relatable_categories.json" do |name|
      if @related_attribute = params[:related_attribute]
        name = name.downcase
        if @template = ObjectTemplate.first(:name => name)
          @related_categories = @template.relatable_categories_by_related_attribute(@related_attribute, @per_page, @page)
          template_hash = @template.attributes_for_api_resource
          template_hash["object_template"]["relatable_categories"] = @related_categories.map(&:attributes_for_api_resources)
          template_hash.merge!(paginate(@related_categories))
          template_hash.to_json
        else
          raise Sinatra::NotFound
        end
      else
        throw :halt, [412, "Params: related_attribute was not given"]
      end
    end
    
    get "/object_templates/:name/generic_objects/filter.json" do |template_name|
      template_name = template_name.downcase
      if @template = ObjectTemplate.first(:name => template_name)
        filter = params[:filter] || ""      
        relatable_category_values = (params[:relatable_category_values].blank? ? [] : params[:relatable_category_values])
        @generic_objects = GenericObject.filter_with_template_name(template_name, filter, @per_page, @page, relatable_category_values)
        template_hash = @template.attributes_for_api_resource
        template_hash["object_template"]["generic_objects"] = @generic_objects.map(&:attributes_for_api_resources)
        template_hash.merge!(paginate(@generic_objects))
        template_hash.to_json
      else
        raise Sinatra::NotFound
      end
    end

  end
end
