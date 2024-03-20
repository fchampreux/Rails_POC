class Administration::ParametersListsController < AdministrationController
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current list
  before_action :set_parameters_list, only: [:show, :edit, :update, :export, :destroy]


  before_action :set_statuses_list, only: [:new, :edit, :update, :create]

  # Initialise breadcrumbs for the resulting view
  #before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /parameters_list
  # GET /parameters_list.json
  def index
    @parameters_lists = ParametersList.joins(translated_parameters_lists).
                                        where("parameters_lists.owner_id = ? or ? is null", params[:owner], params[:owner]).
                                        visible.
                                        select(index_fields).
                                        order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @parameters_lists }
      format.csv { send_data @parameters_lists.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /parameters_list/1
  # GET /parameters_list/1.json
  # GET /parameters_list/1.csv
  # GET /parameters_list/1.xlsx
  def show
    ### Retrieved by Callback function

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @parameters_list.parameters }
      format.csv { send_data @parameters_list.parameters.to_csv }
      format.xlsx {render xlsx: "show", filename: "#{@parameters_list.code}_parameters.xlsx", disposition: 'inline'} # uses specific template to generate the a file
    end
  end

  # GET /parameters_list/new
  def new
    @parameters_list = ParametersList.new
    @parameters = @parameters_list.parameters.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
  end

  # GET /parameters_list/1/edit
  def edit
    ### Retrieved by Callback function
    #check_translations(@parameters_list)
  end

  # POST /parameters_list
  # POST /parameters_list.json
  def create
    @parameters_list = ParametersList.new(parameters_list_params)
    @parameters_list.metadata_setup(current_user)
    # Build translated json fields
    all_translations(@parameters_list)

    respond_to do |format|
      if @parameters_list.save
        format.html { redirect_to [:administration, @parameters_list], notice: t('PLCreated') } #'List of parameters was successfully created.'
        format.json { render action: 'show', status: :created, location: @parameters_list }
      else
        format.html { render action: 'new' }
        format.json { render json: @parameters_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parameters_list/1
  # PATCH/PUT /parameters_list/1.json
  def update
    ### Retrieved by Callback function
    @parameters_list.updated_by = current_login
    # Build translated json fields
    all_translations(@parameters_list)

    respond_to do |format|
      if @parameters_list.update(parameters_list_params)
        format.html { redirect_to [:administration, @parameters_list], notice: t('PLUpdated') } #'List of parameters was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @parameters_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # Reactivate deleted parameters_list
  def activate
    ### Retrieved by Callback function
    @parameters_list.set_as_active(current_login)
    respond_to do |format|
      format.html { redirect_to [:administration, @parameters_list], notice: t('PLRecalled')  }
      format.json { head :no_content }
    end
  end

  # DELETE /parameters_list/1
  # DELETE /parameters_list/1.json
  def destroy
    ### Retrieved by Callback function
    @parameters_list.set_as_inactive(current_login)
    respond_to do |format|
      format.html { redirect_to administration_parameters_lists_url, notice: t('PLDeleted') } #'Parameters List was successfully deleted.'
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_parameters_list
      @parameters_list = ParametersList.includes(:owner, :status).find(params[:id])
      @parameters_export = Parameter.visible.where("parameters_lists.id = ?", @parameters_list.id)
      @parameters = @parameters_list.parameters.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@parameters_list)
    end

    ### queries tayloring
    def owners
      User.arel_table.alias('owners')
    end

   def parameters_lists
      ParametersList.arel_table
    end

    def parameters
      Parameter.arel_table
    end

    def translated_parameters_lists
      parameters_lists.
      join(owners).on(parameters_lists[:owner_id].eq(owners[:id])).
      join_sources
    end

    def translated_parameters
      parameters.
      join(parameters_lists).on(parameters[:parameters_list_id].eq(parameters_lists[:id])).
      join_sources
    end

    def index_fields
      [ parameters_lists[:id], 
        parameters_lists[:owner_id], 
        parameters_lists[:code], 
        parameters_lists[:name], 
        parameters_lists[:description], 
        parameters_lists[:status_id], 
        parameters_lists[:updated_by], 
        parameters_lists[:updated_at], 
        parameters_lists[:is_active],
        owners[:name].as("owner_name"),
        Arel::Nodes::SqlLiteral.new("case
          when not parameters_lists.is_active then '0'
          else '1'
          end").as("calculated_status")
      ]
    end

    def order_by
      [parameters_lists[:code].asc]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def parameters_list_params
      params.require(:parameters_list).permit(:code, :status_id, :sort_code, name: {}, description: {}, 
      parameters_attributes: [:code, :property, :scope, :active_from, :active_to, :_destroy, :id, name: {}, description: {}])
    end
end
