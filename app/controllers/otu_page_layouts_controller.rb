class OtuPageLayoutsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_otu_page_layout, only: [:show, :edit, :update, :destroy]

  # GET /otu_page_layouts
  # GET /otu_page_layouts.json
  def index
    @recent_objects = OtuPageLayout.where(project_id: sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /otu_page_layouts/1
  # GET /otu_page_layouts/1.json
  def show
  end

  # GET /otu_page_layouts/new
  def new
    @otu_page_layout = OtuPageLayout.new
    # generate an empty ActiveRecord::Relation
    @topics = ControlledVocabularyTerm.where(type: 'Topic', name: nil)
  end

  # GET /otu_page_layouts/1/edit
  def edit
  end

  # POST /otu_page_layouts
  # POST /otu_page_layouts.json
  def create
    @otu_page_layout = OtuPageLayout.new(otu_page_layout_params)

    respond_to do |format|
      if @otu_page_layout.save
        format.html { redirect_to @otu_page_layout, notice: 'Otu page layout was successfully created.' }
        format.json { render :show, status: :created, location: @otu_page_layout }
      else
        format.html { render :new }
        format.json { render json: @otu_page_layout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /otu_page_layouts/1
  # PATCH/PUT /otu_page_layouts/1.json
  def update
    respond_to do |format|
      if @otu_page_layout.update(otu_page_layout_params)
        format.html { redirect_to @otu_page_layout, notice: 'Otu page layout was successfully updated.' }
        format.json { render :show, status: :ok, location: @otu_page_layout }
      else
        format.html { render :edit }
        format.json { render json: @otu_page_layout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /otu_page_layouts/1
  # DELETE /otu_page_layouts/1.json
  def destroy
    @otu_page_layout.destroy
    respond_to do |format|
      format.html { redirect_to otu_page_layouts_url }
      format.json { head :no_content }
    end
  end

  def list
    @otu_page_layouts = OtuPageLayout.with_project_id(sessions_current_project_id).order(:name).page(params[:page]) #.per(10) 
  end



  def autocomplete
    @otu_page_layouts = OtuPageLayout.find_for_autocomplete(params)

    data = @otu_page_layouts.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.otu_page_layout_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html: ApplicationController.helpers.otu_page_layout_tag(t)
      }

      render json: data
    end
  end

  private 

  def set_otu_page_layout
    @otu_page_layout = OtuPageLayout.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @otu_page_layout
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def otu_page_layout_params
    params.require(:otu_page_layout).permit(
      :name,
      standard_sections_attributes: [:topic_id, :_destroy, :type, :id, :position]
    )
  end
end

