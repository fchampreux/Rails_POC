class Administration::GroupsController < AdministrationController
  include TerritoriesHelper, OrganisationsHelper
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_group, only: [:show, :edit, :update, :destroy, :activate]

    # Initialise breadcrumbs for the resulting view
    #before_action :set_breadcrumbs, only: [:show, :edit, :update]

    # GET /groups
    # GET /groups.json
    def index
      @groups = Group.joins(translated_groups).
                      where("groups.owner_id = ? or ? is null", params[:owner], params[:owner]).
                      visible.
                      select(index_fields).
                      order(order_by)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @groups }
      end
    end

  # GET /groups/1
  # GET /groups/1.json
  def show
    ### Retrieved by Callback function
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
    ### Retrieved by Callback function
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    @group.metadata_setup(current_user)

    respond_to do |format|
      if @group.save
        format.html { redirect_to [:administration, @group], notice: t('GroupCreated') } #'Group was successfully created.'
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    @group.updated_by = current_login

    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to [:administration, @group], notice: t('GroupUpdated') } #'Group was successfully updated.'
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /groups/1
  # POST /groups/1.json
  def activate
    ### Retrieved by Callback function
    @group.set_as_active(current_login)

    respond_to do |format|
      if @group.save
          format.html { redirect_to [:administration, @group], notice: t('GroupRecalled') } #'Business landsacpe was successfully recalled.'
          format.json { render json: @group, status: :created, location: @group }
        else
          format.html { redirect_to [:administration, @group], notice: t('GroupRecalledKO') } #'Business landsacpe  cannot be recalled.'
          format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.set_as_inactive(current_login)

    respond_to do |format|
      format.html { redirect_to administration_groups_url, notice: t('GroupDeleted') } #'Group was successfully destroyed.'
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = @group.name[current_language.to_s]
    end

    ### queries tayloring
    def owners
      User.arel_table.alias('owners')
    end

    def groups
      Group.arel_table
    end

    def organisations
      Organisation.arel_table
    end

    def territories
      Territory.arel_table
    end


    def translated_groups
      groups.
      join(owners).on(groups[:owner_id].eq(owners[:id])).
      join(organisations).on(groups[:organisation_id].eq(organisations[:id])).
      join(territories).on(groups[:territory_id].eq(territories[:id])).
      join_sources
    end

    def index_fields
      [ groups[:id], 
        groups[:code], 
        groups[:name], 
        groups[:description], 
        groups[:territory_id], 
        groups[:organisation_id], 
        organisations[:name].as("organisation_name"),
        territories[:name].as("territory_name"),
        groups[:status_id], 
        groups[:updated_by], 
        groups[:updated_at], 
        groups[:is_active],
        owners[:name].as("owner_name"),
        Arel::Nodes::SqlLiteral.new("case
          when not groups.is_active then '0'
          else '1'
          end").as("calculated_status")
      ]
    end

    def order_by
      [groups[:code].asc]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:role, 
                                    :territory_id, 
                                    :organisation_id, 
                                    :created_by, 
                                    :updated_by, 
                                    :code,
                                    name: {}, 
                                    description: {}, 
                                    role_ids: [])
    end
end
