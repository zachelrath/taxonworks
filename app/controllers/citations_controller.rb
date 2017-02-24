class CitationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :require_sign_in_and_project_selection
  before_action :set_citation, only: [:update, :destroy, :show]

  # GET /citations
  # GET /citations.json
  def index
    respond_to do |format|
     format.html {
        @recent_objects = Citation.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @citations = Citation.where(project_id: sessions_current_project_id).where(filter_params)
      }
    end
  end

  def new
    @citation = Citation.new(citation_params)
    # @citation.citation_topics.build
  end

  def edit
    @citation = Citation.find_by_id(params[:id]).metamorphosize
  end

  # Presently only used in autocomplete
  def show
    redirect_to @citation.annotated_object.metamorphosize
  end


  # POST /citations
  # POST /citations.json
  def create
    @citation = Citation.new(citation_params)

    respond_to do |format|
      if @citation.save
        format.html { redirect_to @citation.citation_object.metamorphosize, notice: 'Citation was successfully created.' }
        format.json { render json: @citation, status: :created, location: @citation }
      else
        format.html { redirect_to :back, notice: 'Citation was NOT successfully created.' }
        format.json { render json: @citation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /citations/1
  # PATCH/PUT /citations/1.json
  def update
    respond_to do |format|
      if @citation.update(citation_params)
        format.html { redirect_to @citation.citation_object.metamorphosize, notice: 'Citation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: 'Citation was NOT successfully updated.' }
        format.json { render json: @citation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /citations/1
  # DELETE /citations/1.json
  def destroy
    @citation.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Citation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @citations = Citation.with_project_id(sessions_current_project_id).order(:citation_object_type).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id].blank?
      redirect_to citations_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to citation_path(params[:id])
    end
  end

  def autocomplete
    @citations = Citation.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    data = @citations.collect do |t|
      lbl = render_to_string(partial: 'tag', locals: {citation: t})
      {id: t.id,
       label: lbl,
       response_values: {
           params[:method] => t.id
       },
       label_html: lbl
      }
    end

    render :json => data
  end

  # GET /citations/download
  def download
    send_data Citation.generate_download( Citation.where(project_id: sessions_current_project_id) ), type: 'text', filename: "citations_#{DateTime.now.to_s}.csv"
  end

  private

  def filter_params
    # we should only ever get here from a shallow resource
    h = params.permit(
      :content_id,
      # add other polymorphic references here as implementd, e.g. taxon_name_id for citations on TaxonNames
    ).to_h 

    if h.size > 1 
      respond_to do |format|
        format.html { render plain: '404 Not Found', status: :unprocessable_entity and return }
        format.json { render json: {success: false}, status: :unprocessable_entity and return }
      end
    end

    model = h.keys.first.split('_').first.classify
    return {citation_object_type: model, citation_object_id: h.values.first}
  end

  def set_citation
    @citation = Citation.with_project_id(sessions_current_project_id).find(params[:id])
  end

  def citation_params
    params.require(:citation).permit(
      :citation_object_type, :citation_object_id, :source_id, :pages, :is_original,
      citation_topics_attributes: [:id, :_destroy, :pages, :topic_id,
                                   topic_attributes: [:id, :_destroy, :name, :definition]]
    )
  end
end
