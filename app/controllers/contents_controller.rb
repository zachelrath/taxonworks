class ContentsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_content, only: [:show, :edit, :update, :destroy, :api_show]

  # GET /contents
  # GET /contents.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Content.where(project_id: sessions_current_project_id).recently_updated.limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @contents = Queries::Content::Filter.new(filter_params).all.page(params[:page]).per(params[:per])
      }
    end
  end

  # GET /contents/1
  # GET /contents/1.json
  def show
  end

  # GET /contents/new
  def new
    @content = Content.new
  end

  # GET /contents/1/edit
  def edit
  end

  # POST /contents
  # POST /contents.json
  def create
    @content = Content.new(content_params)

    respond_to do |format|
      if @content.save
        format.html { redirect_to url_for(@content), notice: 'Content was successfully created.' }
        format.json { render :show, status: :created, location: @content }
      else
        format.html { render :new }
        format.json { render json: @content.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contents/1
  # PATCH/PUT /contents/1.json
  def update
    respond_to do |format|
      if @content.update(content_params)
        format.html { redirect_to url_for(@content), notice: 'Content was successfully updated.' }
        format.json { render :show, status: :ok, location: @content }
      else
        format.html { render :edit }
        format.json { render json: @content.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contents/1
  # DELETE /contents/1.json
  def destroy
    @content.destroy!
    respond_to do |format|
      format.html { redirect_to contents_url }
      format.json { head :no_content }
    end
  end

  def list
    @contents = Content.with_project_id(sessions_current_project_id).order(:id).page(params[:page])
  end

  def search
    if params[:id].blank?
      redirect_to content_path,
        notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to content_path(params[:id])
    end
  end

  def autocomplete
    @contents = Content.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    data = @contents.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.taxon_works_content_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html: ApplicationController.helpers.taxon_works_content_tag(t)
      }
    end

    render json: data
  end

  # GET /contents/download
  def download
    send_data(
      Export::Download.generate_csv(Content.where(project_id: sessions_current_project_id)),
      type: 'text',
      filename: "contents_#{DateTime.now}.csv")
  end

  # GET /api/v1/content
  def api_index
    @contents = Queries::Content::Filter.new(api_params).all
      .includes(:topic)
      .order('otus.id, controlled_vocabulary_terms.name')
      .page(params[:page]).per(params[:per])
    render '/contents/api/v1/index'
  end

  # GET /api/v1/content/:id
  def api_show
    render '/contents/api/v1/show'
  end

  private

  def api_params
    params.permit(
      :otu_id,
      :topic_id,
      :text,
      :exact,
      :citations,
      :depictions,
      :user_date_end,
      :user_date_start,
      :user_id,
      :user_target,
      topic_id: [],
      otu_id: []
    ).to_h.merge(project_id: sessions_current_project_id)
  end

  def filter_params
    params.permit(
      :otu_id,
      :topic_id,
      :text,
      :exact,
      :citations,
      :depictions,
      :user_date_end,
      :user_date_start,
      :user_id,
      :user_target,
      topic_id: [],
      otu_id: []
    ).to_h.merge(project_id: sessions_current_project_id)
  end

  def set_content
    @content = Content.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @content
  end

  def content_params
    params.require(:content).permit(:text, :otu_id, :topic_id)
  end
end
