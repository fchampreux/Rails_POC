class Administration::ParametersController < AdministrationController
  # Check for active session
    before_action :authenticate_user!
    load_and_authorize_resource

  # Retrieve current parameter
    before_action :set_parameter, only: [:show, :edit, :update, :destroy]

  def new
    # If the parameteris created as the child of another parameter, then the parent parameteris assigned as superior
    @parameters_list = ParametersList.find(params[:parameters_list_id])
    @parameter= @parameters_list.parameters.build()
    render layout: false
  end

  def edit
    # parameter retrieved by callback
    render layout: false
  end

  def create
    @parameters_list = ParametersList.find(params[:parameters_list_id])
    @parameter= @parameters_list.parameters.build(parameter_params)

    respond_to do |format|
      if @parameter.save
        format.html { redirect_back fallback_location: root_path, notice: t('.Success') } #'Variable was successfully updated.'
        format.json { head :no_content }
      else
        format.html { redirect_back fallback_location: root_path, notice: "#{t('.Failure')}: #{@parameter.errors.full_messages.join(',')}" }
        format.json { render json: @parameter.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # parameter retrieved by callback
    @parameters_list = ParametersList.find(@parameter.parameters_list_id)

    respond_to do |format|
      if @parameter.update_attributes(parameter_params)
        format.html { redirect_back fallback_location: root_path, notice: t('.Success') } #'Variable was successfully updated.'
        format.json { head :no_content }
      else
        format.html { redirect_back fallback_location: root_path, notice: "#{t('.Failure')}: #{@parameter.errors.full_messages.join(',')}" }
        format.json { render json: @parameter.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    # parameterretrieved by callback
    render layout: false

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @parameter}
      format.csv { send_data @parameter.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  def destroy
    # parameterretrieved by callback
    @parameter.destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: t('.Success') } # 'Parameter was successfully deleted.'
      format.json { head :no_content }
    end
  end

  ### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current parameter
    def set_parameter
      @parameter= Parameter.find(params[:id])
      @parameters_list = ParametersList.find(@parameter.parameters_list_id)
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@parameter)
    end

    ### queries tayloring

    def parameters
      Parameter.arel_table
    end

    def index_fields
      [ parameters[:id], 
        parameters[:code], 
        parameters[:sort_code], 
        # Arel::Nodes::SqlLiteral.new("(name -> '#{current_language.to_s}') as name"), 
        # Arel::Nodes::SqlLiteral.new("(description -> '#{current_language.to_s}') as description"), 
        parameters[:name],
        parameters[:description],
        parameters[:property], 
        parameters[:scope], 
        parameters[:active_to], 
        parameters[:active_from]
      ]
    end

    def order_by
      [parameters[:sort_code].asc]
    end

  ### strong parameters
  def parameter_params
    params.require(:parameter).permit(:playground_id, :parameters_list_id, :code, :property, :scope, :active_from, :active_to, name: {}, description: {})
  end

end
